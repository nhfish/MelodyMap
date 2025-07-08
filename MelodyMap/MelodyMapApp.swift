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
    @State private var showPageCurlTransition = false
    @State private var pageCurlTransitionDone = false
    @State private var showingFavorites = false
    @State private var splashSnapshot: UIImage? = nil

    var body: some Scene {
        WindowGroup {
            let favorites = FavoritesService.shared
            let content = ContentService.shared
            ZStack {
                // App background color
                Color.appBackground
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
                    ZStack {
                        NavigationView {
                            SearchView(onNavigateToTimeline: { indexedSong in
                                // Find the movie index for navigation from ContentService
                                let movies = content.movies.sorted { $0.sortOrder < $1.sortOrder }
                                if let movieIndex = movies.firstIndex(where: { $0.id == indexedSong.movie.id }) {
                                    appState.navigateToTimeline(movieIndex: movieIndex, song: indexedSong.song)
                                }
                            })
                            .navigationBarHidden(true)
                            .environmentObject(appState)
                            .onAppear {
                                print("🎬 MelodyMapApp: Showing SearchView")
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
                        .sheet(isPresented: $appState.showingTimelineSheet) {
                            TimelineView(viewModel: appState.timelineViewModel, onClose: { appState.dismissTimelineSheet() })
                                .environmentObject(appState)
                                .environmentObject(UsageTrackerService.shared)
                                .environmentObject(AdService.shared)
                                .environmentObject(favorites)
                                .environmentObject(ContentService.shared)
                                .environmentObject(MusicKitService.shared)
                        }
                        .environmentObject(UsageTrackerService.shared)
                        .environmentObject(AdService.shared)
                        .environmentObject(favorites)
                        .environmentObject(ContentService.shared)
                        .environmentObject(MusicKitService.shared)

                        // Unified Floating Action Buttons (FABs) Overlay
                        ZStack {
                            // Top right: Profile button
                            HStack {
                                Spacer()
                                DailyUsesCounterButton {
                                    appState.showingProfile = true
                                }
                                .environmentObject(UsageTrackerService.shared)
                            }
                            .padding(.trailing, 24)
                            .padding(.top, 48)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)

                            // Bottom left: Upgrade FAB
                            HStack {
                                FloatingActionButton(
                                    systemName: "plus.circle.fill",
                                    color: .appAccent,
                                    action: { appState.showPaywall = true },
                                    accessibilityLabel: "Upgrade",
                                    size: 36
                                )
                                .padding([.leading, .bottom], 24)
                                Spacer()
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                            .opacity(appState.isKeyboardVisible ? 0 : 1)

                            // Bottom right: Favorites FAB
                            HStack {
                                Spacer()
                                if !favorites.favoritedSongIDs.isEmpty {
                                    FloatingActionButton(
                                        systemName: "star.circle.fill",
                                        color: .appAccent,
                                        action: { showingFavorites = true },
                                        accessibilityLabel: "Show Favorites",
                                        size: 36
                                    )
                                    .padding([.trailing, .bottom], 24)
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                            .opacity(appState.isKeyboardVisible ? 0 : 1)
                        }
                        .ignoresSafeArea(.container, edges: .top)
                        .zIndex(1000)
                    }
                    .opacity(showPageCurlTransition ? 0 : 1)
                    .onAppear {
                        print("🎬 MelodyMapApp: Showing main UI")
                    }
                }
                // Page curl transition overlay
                if showPageCurlTransition && !pageCurlTransitionDone, let splashSnapshot = splashSnapshot {
                    PageCurlTransitionView(snapshotImage: Image(uiImage: splashSnapshot), onComplete: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            pageCurlTransitionDone = true
                            showPageCurlTransition = false
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
                    // Splash just finished, capture snapshot and trigger page curl transition
                    let window = UIApplication.shared.connectedScenes
                        .compactMap { $0 as? UIWindowScene }
                        .flatMap { $0.windows }
                        .first { $0.isKeyWindow }
                    let hosting = UIHostingController(rootView: SplashSnapshotView())
                    hosting.view.frame = window?.bounds ?? .zero
                    if let view = hosting.view {
                        splashSnapshot = view.snapshot()
                    }
                    showPageCurlTransition = true
                    pageCurlTransitionDone = false
                    // Hide transition after animation (handled by onComplete in PageCurlTransitionView)
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
    @Published var isKeyboardVisible = false
    
    // Navigation state for Search -> Timeline transition
    @Published var showingTimelineSheet = false
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
        
        // Setup keyboard notifications
        setupKeyboardNotifications()
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
        
        // Force FABs to show when transitioning to timeline (keyboard will be dismissed)
        withAnimation(.easeInOut(duration: 0.3)) {
            isKeyboardVisible = false
        }
        
        showingTimelineSheet = true
    }
    
    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                withAnimation(.easeInOut(duration: 0.3)) {
                    self?.isKeyboardVisible = true
                }
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                withAnimation(.easeInOut(duration: 0.3)) {
                    self?.isKeyboardVisible = false
                }
            }
        }
    }
    
    func dismissTimelineSheet() {
        showingTimelineSheet = false
        // Don't force keyboard state here - let the natural keyboard notifications handle it
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

enum AppNav: Hashable {
    case profile
}
