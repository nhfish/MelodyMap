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
                } else {
                    // Main UI
                    NavigationView {
                        ZStack {
                            if appState.showingTimeline {
                                TimelineView(viewModel: TimelineViewModel())
                                    .environmentObject(appState)
                                    .transition(.asymmetric(
                                        insertion: .move(edge: .trailing).combined(with: .opacity),
                                        removal: .move(edge: .leading).combined(with: .opacity)
                                    ))
                                    .zIndex(1)
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
                            
                            VStack {
                                HStack {
                                    Spacer()
                                    if !appState.showingProfile {
                                        DailyUsesCounterButton(uses: appState.dailyUses) {
                                            appState.showingProfile = true
                                        }
                                        .padding([.trailing, .top], 16)
                                    }
                                }
                                Spacer()
                            }
                            .zIndex(3)
                        }
                        .background(
                            NavigationLink(
                                destination: ProfileView(onClose: { appState.showingProfile = false }),
                                isActive: $appState.showingProfile
                            ) { EmptyView() }
                            .hidden()
                        )
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
                    .sheet(isPresented: $appState.showPaywall) {
                        PaywallView(onClose: { appState.showPaywall = false })
                    }
                    .environmentObject(UsageTrackerService.shared)
                    .environmentObject(AdService.shared)
                    .opacity(showPixieBurst ? 0 : 1)
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
                appState.loadData()
            }
            .onChange(of: appState.showSplash) { newValue in
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

    private var timerDone = false
    private var contentLoaded = false

    func loadData() {
        // Start timer
        timerDone = false
        contentLoaded = false
        showSplash = true
        dataReady = false

        // Start minimum splash timer
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            self.timerDone = true
            self.checkIfReady()
        }

        // Start loading data (songs and movies)
        SearchViewModel.loadForAppState { [weak self] in
            guard let self = self else { return }
            self.contentLoaded = true
            self.checkIfReady()
        }
    }

    private func checkIfReady() {
        if timerDone && contentLoaded {
            self.showSplash = false
            self.dataReady = true
        }
    }
    
    func navigateToTimeline(movieIndex: Int, song: Song?) {
        selectedMovieIndex = movieIndex
        preSelectedSong = song
        showingTimeline = true
    }
}

enum AppNav: Hashable {
    case profile
}
