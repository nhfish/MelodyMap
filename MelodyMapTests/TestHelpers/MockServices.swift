import Foundation
import Combine
import UIKit
@testable import MelodyMap

// MARK: - Mock Content Service

class MockContentService: ObservableObject {
    @Published var movies: [Movie] = []
    @Published var songs: [Song] = []
    @Published var isLoading = false
    @Published var lastRefreshDate: Date?
    
    var shouldFail = false
    var failError: Error = NSError(domain: "MockContentService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Mock error"])
    
    func refreshIfNeeded() async {
        isLoading = true
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        if shouldFail {
            isLoading = false
            throw failError
        }
        
        // Simulate successful data loading
        await MainActor.run {
            self.lastRefreshDate = Date()
            self.isLoading = false
        }
    }
    
    func loadMockData() {
        movies = MockData.sampleMovies
        songs = MockData.sampleSongs
    }
    
    func clearData() {
        movies = []
        songs = []
        lastRefreshDate = nil
    }
}

// MARK: - Mock Ad Service

class MockAdService: AdService {
    var shouldSucceed = true
    var presentAdCalled = false
    var loadAdCalled = false
    var adLoadDelay: TimeInterval = 0.1
    
    override func loadAd() async {
        loadAdCalled = true
        try? await Task.sleep(nanoseconds: UInt64(adLoadDelay * 1_000_000_000))
    }
    
    override func presentAd(from rootVC: UIViewController, onEarned: @escaping (Bool) -> Void) {
        presentAdCalled = true
        
        // Simulate ad presentation delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            onEarned(self.shouldSucceed)
        }
    }
    
    func reset() {
        shouldSucceed = true
        presentAdCalled = false
        loadAdCalled = false
        adLoadDelay = 0.1
    }
}

// MARK: - Mock Purchase Service

class MockPurchaseService: PurchaseService {
    var shouldSucceed = true
    var purchaseMonthlyCalled = false
    var restorePurchasesCalled = false
    var mockIsSubscriber = false
    
    override var isSubscriber: Bool {
        get { return mockIsSubscriber }
        set { mockIsSubscriber = newValue }
    }
    
    override func purchaseMonthly() {
        purchaseMonthlyCalled = true
        
        if shouldSucceed {
            mockIsSubscriber = true
        }
    }
    
    override func restorePurchases() {
        restorePurchasesCalled = true
        
        if shouldSucceed {
            mockIsSubscriber = true
        }
    }
    
    func reset() {
        shouldSucceed = true
        purchaseMonthlyCalled = false
        restorePurchasesCalled = false
        mockIsSubscriber = false
    }
}

// MARK: - Mock Usage Tracker Service

class MockUsageTrackerService: UsageTrackerService {
    var mockRemaining: Int = 3
    var mockQuota: Int = 3
    var consumeUseCalled = false
    var addRewardedCalled = false
    var canViewSongCalled = false
    
    override var remaining: Int {
        get { return mockRemaining }
        set { mockRemaining = newValue }
    }
    
    override var quota: Int {
        return mockQuota
    }
    
    override func consumeUse(forSongId songId: String) {
        consumeUseCalled = true
        if mockRemaining > 0 {
            mockRemaining -= 1
        }
    }
    
    override func addRewarded(_ bonus: Int) {
        addRewardedCalled = true
        mockRemaining += bonus
    }
    
    override func canViewSong(withId songId: String) -> Bool {
        canViewSongCalled = true
        return mockRemaining > 0
    }
    
    func reset() {
        mockRemaining = 3
        mockQuota = 3
        consumeUseCalled = false
        addRewardedCalled = false
        canViewSongCalled = false
    }
}

// MARK: - Mock Favorites Service

class MockFavoritesService: FavoritesService {
    var mockFavoritedSongIDs: Set<String> = []
    var addFavoriteCalled = false
    var removeFavoriteCalled = false
    var isFavoritedCalled = false
    
    override var favoritedSongIDs: Set<String> {
        get { return mockFavoritedSongIDs }
        set { mockFavoritedSongIDs = newValue }
    }
    
    override func addFavorite(_ songId: String) {
        addFavoriteCalled = true
        mockFavoritedSongIDs.insert(songId)
    }
    
    override func removeFavorite(_ songId: String) {
        removeFavoriteCalled = true
        mockFavoritedSongIDs.remove(songId)
    }
    
    override func isFavorited(_ songId: String) -> Bool {
        isFavoritedCalled = true
        return mockFavoritedSongIDs.contains(songId)
    }
    
    func reset() {
        mockFavoritedSongIDs = []
        addFavoriteCalled = false
        removeFavoriteCalled = false
        isFavoritedCalled = false
    }
}

// MARK: - Mock MusicKit Service

/*
// MockMusicKitService temporarily disabled for migration
class MockMusicKitService: MusicKitService {
    var mockIsAuthorized = false
    var mockAuthorizationStatus: MusicAuthorization.Status = .notDetermined
    var searchSongCalled = false
    var requestAuthorizationCalled = false
    var shouldReturnSong = true
    var mockSong: MockMusicKitSong?
    
    override var isAuthorized: Bool {
        get { return mockIsAuthorized }
        set { mockIsAuthorized = newValue }
    }
    
    override var authorizationStatus: MusicAuthorization.Status {
        get { return mockAuthorizationStatus }
        set { mockAuthorizationStatus = newValue }
    }
    
    override func requestAuthorization() async -> Bool {
        requestAuthorizationCalled = true
        mockIsAuthorized = shouldReturnSong
        mockAuthorizationStatus = shouldReturnSong ? .authorized : .denied
        return shouldReturnSong
    }
    
    override func searchSong(movieTitle: String, songTitle: String) async -> MusicKit.Song? {
        searchSongCalled = true
        
        if !mockIsAuthorized || !shouldReturnSong {
            return nil
        }
        
        return mockSong ?? MockMusicKitSong(title: songTitle)
    }
    
    func reset() {
        mockIsAuthorized = false
        mockAuthorizationStatus = .notDetermined
        searchSongCalled = false
        requestAuthorizationCalled = false
        shouldReturnSong = true
        mockSong = nil
    }
}
*/

// MARK: - Mock App State

class MockAppState: AppState {
    var mockShowSplash = true
    var mockIsSubscribed = false
    var mockDailyUses = 0
    var mockShowPaywall = false
    var mockShowingProfile = false
    var mockDataReady = false
    var mockShowingTimeline = false
    var mockSelectedMovieIndex = 0
    var mockPreSelectedSong: Song?
    
    override var showSplash: Bool {
        get { return mockShowSplash }
        set { mockShowSplash = newValue }
    }
    
    override var isSubscribed: Bool {
        get { return mockIsSubscribed }
        set { mockIsSubscribed = newValue }
    }
    
    override var dailyUses: Int {
        get { return mockDailyUses }
        set { mockDailyUses = newValue }
    }
    
    override var showPaywall: Bool {
        get { return mockShowPaywall }
        set { mockShowPaywall = newValue }
    }
    
    override var showingProfile: Bool {
        get { return mockShowingProfile }
        set { mockShowingProfile = newValue }
    }
    
    override var dataReady: Bool {
        get { return mockDataReady }
        set { mockDataReady = newValue }
    }
    
    override var showingTimeline: Bool {
        get { return mockShowingTimeline }
        set { mockShowingTimeline = newValue }
    }
    
    override var selectedMovieIndex: Int {
        get { return mockSelectedMovieIndex }
        set { mockSelectedMovieIndex = newValue }
    }
    
    override var preSelectedSong: Song? {
        get { return mockPreSelectedSong }
        set { mockPreSelectedSong = newValue }
    }
    
    func reset() {
        mockShowSplash = true
        mockIsSubscribed = false
        mockDailyUses = 0
        mockShowPaywall = false
        mockShowingProfile = false
        mockDataReady = false
        mockShowingTimeline = false
        mockSelectedMovieIndex = 0
        mockPreSelectedSong = nil
    }
}

// MARK: - Mock View Models

class MockSearchViewModel: SearchViewModel {
    var mockQuery = ""
    var mockResults: [IndexedSong] = []
    var mockIndexedSongs: [IndexedSong] = []
    var mockNavigateToTimeline = false
    var mockSelectedIndexedSong: IndexedSong?
    var mockShouldShowQuotaSheet = false
    
    override var query: String {
        get { return mockQuery }
        set { mockQuery = newValue }
    }
    
    override var results: [IndexedSong] {
        get { return mockResults }
        set { mockResults = newValue }
    }
    
    override var indexedSongs: [IndexedSong] {
        get { return mockIndexedSongs }
        set { mockIndexedSongs = newValue }
    }
    
    override var navigateToTimeline: Bool {
        get { return mockNavigateToTimeline }
        set { mockNavigateToTimeline = newValue }
    }
    
    override var selectedIndexedSong: IndexedSong? {
        get { return mockSelectedIndexedSong }
        set { mockSelectedIndexedSong = newValue }
    }
    
    override var shouldShowQuotaSheet: Bool {
        get { return mockShouldShowQuotaSheet }
        set { mockShouldShowQuotaSheet = newValue }
    }
    
    func reset() {
        mockQuery = ""
        mockResults = []
        mockIndexedSongs = []
        mockNavigateToTimeline = false
        mockSelectedIndexedSong = nil
        mockShouldShowQuotaSheet = false
    }
}

// MARK: - Test Utilities

struct TestUtilities {
    
    static func createMockViewController() -> UIViewController {
        let viewController = UIViewController()
        viewController.view = UIView()
        return viewController
    }
    
    static func waitForAsyncOperation(timeout: TimeInterval = 1.0) async {
        try? await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
    }
    
    static func createMockWindow() -> UIWindow {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = createMockViewController()
        window.makeKeyAndVisible()
        return window
    }
    
    static func clearUserDefaults() {
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
    }
    
    static func setupUserDefaults(with data: [String: Any]) {
        for (key, value) in data {
            UserDefaults.standard.set(value, forKey: key)
        }
    }
} 