//
//  MelodyMapApp.swift
//  MelodyMap
//
//  Created by Nathan Fisher on 6/13/25.
//

import SwiftUI

@main
struct MelodyMapApp: App {
    @StateObject private var appState = AppState()
    @State private var showPixieBurst = false
    @State private var pixieBurstDone = false

    var body: some Scene {
        WindowGroup {
            ZStack {
                if appState.showSplash {
                    SplashView()
                        .transition(.opacity)
                        .zIndex(2)
                        .onAppear {
                            print("🎬 MelodyMapApp: Showing splash screen")
                        }
                } else {
                    // Main UI
                    NavigationView {
                        ZStack {
                            if appState.showingTimeline {
                                TimelineView(viewModel: appState.timelineViewModel)
                                    .environmentObject(appState)
                                    .transition(.asymmetric(
                                        insertion: .move(edge: .trailing).combined(with: .opacity),
                                        removal: .move(edge: .leading).combined(with: .opacity)
                                    ))
                                    .zIndex(1)
                                    .onAppear {
                                        print("🎬 MelodyMapApp: Showing TimelineView")
                                    }
                            } else {
                                SearchView(onNavigateToTimeline: { indexedSong in
                                    // Find the movie index for navigation
                                    Task {
                                        let movies = try await APIService.shared.fetchMovies()
                                        let sortedMovies = movies.sorted { $0.sortOrder < $1.sortOrder }
                                        if let movieIndex = sortedMovies.firstIndex(where: { $0.id == indexedSong.movie.id }) {
                                            await MainActor.run {
                                                withAnimation(.easeInOut(duration: 0.6)) {
                                                    appState.navigateToTimeline(movieIndex: movieIndex, song: indexedSong.song)
                                                }
                                            }
                                        }
                                    }
                                })
                                .navigationBarHidden(true)
                                .transition(.asymmetric(
                                    insertion: .move(edge: .leading).combined(with: .opacity),
                                    removal: .move(edge: .trailing).combined(with: .opacity)
                                ))
                                .zIndex(1)
                                .onAppear {
                                    print("🎬 MelodyMapApp: Showing SearchView")
                                }
                            }
                            
                            // Overlay buttons - always on top
                            if !appState.isSubscribed {
                                VStack {
                                    Spacer()
                                    HStack {
                                        UpgradeButton {
                                            appState.showPaywall = true
                                        }
                                        .padding([.leading, .bottom], 16)
                                        Spacer()
                                    }
                                }
                                .zIndex(3)
                            }
                            
                            // Profile button - uniform placement across all screens
                            VStack {
                                HStack {
                                    Spacer()
                                    if !appState.showingProfile {
                                        DailyUsesCounterButton {
                                            appState.showingProfile = true
                                        }
                                        .environmentObject(UsageTrackerService.shared)
                                        .padding([.trailing, .top], 16)
                                    }
                                }
                                Spacer()
                            }
                            .zIndex(3)
                        }
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
                    .sheet(isPresented: $appState.showPaywall) {
                        PaywallView(onClose: { appState.showPaywall = false })
                    }
                    .sheet(isPresented: $appState.showingProfile) {
                        ProfileView(onClose: { appState.showingProfile = false })
                            .environmentObject(UsageTrackerService.shared)
                            .environmentObject(AdService.shared)
                    }
                    .environmentObject(UsageTrackerService.shared)
                    .environmentObject(AdService.shared)
                    .opacity(showPixieBurst ? 0 : 1)
                    .onAppear {
                        print("🎬 MelodyMapApp: Showing main UI")
                    }
                }
                // Pixie burst overlay
                if showPixieBurst && !pixieBurstDone {
                    PixieBurstTransitionView(onComplete: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            pixieBurstDone = true
                        }
                    })
                    .zIndex(10)
                }
            }
            .onAppear {
                print("🎬 MelodyMapApp: onAppear called")
                appState.loadData()
            }
            .onChange(of: appState.showSplash) { newValue in
                print("🎬 MelodyMapApp: showSplash changed to \(newValue)")
                if !newValue {
                    // Splash just finished, trigger pixie burst
                    showPixieBurst = true
                    pixieBurstDone = false
                    // Hide burst after animation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showPixieBurst = false
                        }
                    }
                }
            }
        }
    }
}

@MainActor
class AppState: ObservableObject {
    @Published var showSplash = true
    @Published var isSubscribed = false
    @Published var dailyUses = 0
    @Published var showPaywall = false
    @Published var showingProfile = false
    @Published var dataReady = false
    
    // Navigation state for Search -> Timeline transition
    @Published var showingTimeline = false
    @Published var selectedMovieIndex = 0
    @Published var preSelectedSong: Song? = nil
    @Published var timelineViewModel = TimelineViewModel()

    private var timerDone = false
    private var contentLoaded = false

    func loadData() {
        print("🎬 AppState: loadData called")
        // Start timer
        timerDone = false
        contentLoaded = false
        showSplash = true
        dataReady = false

        // Start minimum splash timer
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            print("🎬 AppState: Timer done")
            self.timerDone = true
            self.checkIfReady()
        }

        // Start loading data (songs and movies)
        Task {
            print("🎬 AppState: Starting data loading")
            let songs = try? await APIService.shared.fetchSongs()
            let movies = try? await APIService.shared.fetchMovies()
            await MainActor.run {
                if let movies = movies, let songs = songs {
                    print("🎬 AppState: Data loaded successfully - \(movies.count) movies, \(songs.count) songs")
                    self.timelineViewModel.movies = movies.sorted { $0.sortOrder < $1.sortOrder }
                    self.timelineViewModel.songs = songs
                } else {
                    print("🎬 AppState: Data loading failed")
                }
                self.contentLoaded = true
                self.checkIfReady()
            }
        }
    }

    private func checkIfReady() {
        print("🎬 AppState: checkIfReady - timerDone: \(timerDone), contentLoaded: \(contentLoaded)")
        if timerDone && contentLoaded {
            print("🎬 AppState: Both conditions met, hiding splash")
            self.showSplash = false
            self.dataReady = true
        } else {
            print("🎬 AppState: Conditions not met yet")
        }
    }
    
    func navigateToTimeline(movieIndex: Int, song: Song?) {
        print("🎬 AppState: navigateToTimeline called with movieIndex: \(movieIndex)")
        selectedMovieIndex = movieIndex
        preSelectedSong = song
        timelineViewModel.currentMovieIndex = movieIndex
        timelineViewModel.preSelectedSong = song
        showingTimeline = true
    }
}

enum AppNav: Hashable {
    case profile
}
