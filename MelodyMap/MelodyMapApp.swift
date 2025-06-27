//
//  MelodyMapApp.swift
//  MelodyMap
//
//  Created by Nathan Fisher on 6/13/25.
//

import SwiftUI
import Combine

@main
struct MelodyMapApp: App {
    @StateObject private var appState = AppState(contentService: .shared)
    @State private var showPixieBurst = false
    @State private var pixieBurstDone = false
    @State private var showingFavorites = false

    var body: some Scene {
        WindowGroup {
            let favorites = FavoritesService.shared
            let content = ContentService.shared
            ZStack {
                // White background to prevent dark mode
                Color.white
                    .ignoresSafeArea()
                
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
                                    // Find the movie index for navigation from ContentService
                                    let movies = content.movies.sorted { $0.sortOrder < $1.sortOrder }
                                    if let movieIndex = movies.firstIndex(where: { $0.id == indexedSong.movie.id }) {
                                        withAnimation(.easeInOut(duration: 0.6)) {
                                            appState.navigateToTimeline(movieIndex: movieIndex, song: indexedSong.song)
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

                            // Unified Floating Action Buttons (FABs) Overlay
                            ZStack {
                                // Top right: Profile or X button (never both)
                                HStack {
                                    Spacer()
                                    if !appState.showingProfile && !appState.showingTimeline {
                                        DailyUsesCounterButton {
                                            appState.showingProfile = true
                                        }
                                        .environmentObject(UsageTrackerService.shared)
                                    } else if appState.showingTimeline {
                                        FloatingActionButton(
                                            systemName: "xmark.circle.fill",
                                            color: .secondary,
                                            action: {
                                                withAnimation(.easeInOut(duration: 0.6)) {
                                                    appState.showingTimeline = false
                                                }
                                            },
                                            accessibilityLabel: "Close Timeline",
                                            size: 36
                                        )
                                    }
                                }
                                .padding([.trailing, .top], 32)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)

                                // Bottom left: Upgrade FAB
                                HStack {
                                    FloatingActionButton(
                                        systemName: "plus.circle.fill",
                                        color: .yellow,
                                        action: { appState.showPaywall = true },
                                        accessibilityLabel: "Upgrade",
                                        size: 36
                                    )
                                    .padding([.leading, .bottom], 24)
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)

                                // Bottom right: Favorites FAB
                                HStack {
                                    Spacer()
                                    if !favorites.favoritedSongIDs.isEmpty {
                                        FloatingActionButton(
                                            systemName: "star.circle.fill",
                                            color: .yellow,
                                            action: { showingFavorites = true },
                                            accessibilityLabel: "Show Favorites",
                                            size: 36
                                        )
                                        .padding([.trailing, .bottom], 24)
                                    }
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                            }
                            .ignoresSafeArea(.container, edges: .top)
                            .zIndex(1000)
                        }
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
                    .sheet(isPresented: $appState.showPaywall) {
                        PaywallView(onClose: { appState.showPaywall = false })
                    }
                    .sheet(isPresented: $showingFavorites) {
                        FavoritesView(onDone: { showingFavorites = false })
                            .environmentObject(appState)
                            .environmentObject(favorites)
                    }
                    .sheet(isPresented: $appState.showingProfile) {
                        ProfileView(onClose: { appState.showingProfile = false })
                            .environmentObject(UsageTrackerService.shared)
                            .environmentObject(AdService.shared)
                            .environmentObject(favorites)
                    }
                    .environmentObject(UsageTrackerService.shared)
                    .environmentObject(AdService.shared)
                    .environmentObject(favorites)
                    .environmentObject(ContentService.shared)
                    .environmentObject(MusicKitService.shared)
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
    private var cancellables = Set<AnyCancellable>()
    private let contentService: ContentService

    init(contentService: ContentService = .shared) {
        self.contentService = contentService
        
        // Subscribe to content service updates
        contentService.$movies
            .combineLatest(contentService.$songs)
            .debounce(for: .milliseconds(100), scheduler: RunLoop.main) // Small debounce
            .sink { [weak self] movies, songs in
                if !movies.isEmpty || !songs.isEmpty {
                    print("🎬 AppState: Content loaded from ContentService.")
                    self?.contentLoaded = true
                    self?.checkIfReady()
                }
            }
            .store(in: &cancellables)
    }

    func loadData() {
        print("🎬 AppState: loadData called")
        // Start timer
        timerDone = false
        // contentLoaded will be set by the sink subscriber
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
            print("🎬 AppState: Triggering content refresh")
            await contentService.refreshIfNeeded()
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
