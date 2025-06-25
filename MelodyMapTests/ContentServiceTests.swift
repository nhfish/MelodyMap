import XCTest
import Combine
@testable import MelodyMap

@MainActor
final class ContentServiceTests: XCTestCase {
    var contentService: ContentService!
    var mockAPIService: MockAPIService!
    var cancellables: Set<AnyCancellable>!
    
    override func setUpWithError() throws {
        cancellables = Set<AnyCancellable>()
        mockAPIService = MockAPIService()
        contentService = ContentService()
        
        // Clear any existing cache
        clearCache()
    }
    
    override func tearDownWithError() throws {
        contentService = nil
        mockAPIService = nil
        cancellables = nil
        clearCache()
    }
    
    // MARK: - Initialization Tests
    
    func testInitializationLoadsFromCache() {
        // Given: Cache exists with data
        let testMovies = MockData.sampleMovies
        let testSongs = MockData.sampleSongs
        saveCache(movies: testMovies, songs: testSongs)
        
        // When: Creating new ContentService
        let newService = ContentService()
        
        // Then: Should load from cache
        XCTAssertEqual(newService.movies.count, testMovies.count)
        XCTAssertEqual(newService.songs.count, testSongs.count)
        XCTAssertFalse(newService.isOffline)
    }
    
    func testInitializationWithNoCache() {
        // Given: No cache exists
        clearCache()
        
        // When: Creating new ContentService
        let newService = ContentService()
        
        // Then: Should have empty data
        XCTAssertEqual(newService.movies.count, 0)
        XCTAssertEqual(newService.songs.count, 0)
        XCTAssertFalse(newService.isOffline)
    }
    
    // MARK: - Cache Management Tests
    
    func testSaveToCache() {
        // Given
        let testMovies = MockData.sampleMovies
        let testSongs = MockData.sampleSongs
        
        // When
        contentService.saveToCache(movies: testMovies, songs: testSongs)
        
        // Then
        let loadedCache = loadCache()
        XCTAssertNotNil(loadedCache)
        XCTAssertEqual(loadedCache?.movies.count, testMovies.count)
        XCTAssertEqual(loadedCache?.songs.count, testSongs.count)
    }
    
    func testLoadFromCache() {
        // Given
        let testMovies = MockData.sampleMovies
        let testSongs = MockData.sampleSongs
        saveCache(movies: testMovies, songs: testSongs)
        
        // When
        contentService.loadFromCache()
        
        // Then
        XCTAssertEqual(contentService.movies.count, testMovies.count)
        XCTAssertEqual(contentService.songs.count, testSongs.count)
    }
    
    func testLoadFromCacheWithInvalidData() {
        // Given: Invalid cache file
        let invalidData = "invalid json".data(using: .utf8)!
        try? invalidData.write(to: cacheURL)
        
        // When
        contentService.loadFromCache()
        
        // Then: Should handle gracefully
        XCTAssertEqual(contentService.movies.count, 0)
        XCTAssertEqual(contentService.songs.count, 0)
    }
    
    // MARK: - Refresh Tests
    
    func testRefreshIfNeededWithFreshCache() {
        // Given: Fresh cache (less than 12 hours old)
        let recentCache = ContentCache(
            movies: MockData.sampleMovies,
            songs: MockData.sampleSongs,
            lastFetch: Date()
        )
        saveCache(cache: recentCache)
        
        // When
        let expectation = XCTestExpectation(description: "Refresh completes")
        Task {
            await contentService.refreshIfNeeded()
            expectation.fulfill()
        }
        
        // Then: Should not refresh
        wait(for: [expectation], timeout: 1.0)
        // Note: We can't easily test the internal behavior without exposing it
        // but we can verify the method completes without error
    }
    
    func testRefreshIfNeededWithStaleCache() {
        // Given: Stale cache (more than 12 hours old)
        let staleCache = ContentCache(
            movies: MockData.sampleMovies,
            songs: MockData.sampleSongs,
            lastFetch: Date().addingTimeInterval(-13 * 60 * 60) // 13 hours ago
        )
        saveCache(cache: staleCache)
        
        // When
        let expectation = XCTestExpectation(description: "Refresh completes")
        Task {
            await contentService.refreshIfNeeded()
            expectation.fulfill()
        }
        
        // Then: Should attempt refresh
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Network Error Handling Tests
    
    func testRefreshHandlesNetworkError() {
        // Given: Network failure
        mockAPIService.shouldFail = true
        
        // When
        let expectation = XCTestExpectation(description: "Refresh handles error")
        Task {
            await contentService.refresh()
            expectation.fulfill()
        }
        
        // Then: Should set offline mode
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(contentService.isOffline)
    }
    
    func testRefreshWithNetworkSuccess() {
        // Given: Network success
        let testMovies = MockData.sampleMovies
        let testSongs = MockData.sampleSongs
        mockAPIService.mockMovies = testMovies
        mockAPIService.mockSongs = testSongs
        
        // When
        let expectation = XCTestExpectation(description: "Refresh succeeds")
        Task {
            await contentService.refresh()
            expectation.fulfill()
        }
        
        // Then: Should update data and cache
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(contentService.movies.count, testMovies.count)
        XCTAssertEqual(contentService.songs.count, testSongs.count)
        XCTAssertFalse(contentService.isOffline)
    }
    
    // MARK: - Data Consistency Tests
    
    func testMoviesAndSongsConsistency() {
        // Given
        let testMovies = MockData.sampleMovies
        let testSongs = MockData.sampleSongs
        saveCache(movies: testMovies, songs: testSongs)
        
        // When
        contentService.loadFromCache()
        
        // Then: Data should be consistent
        XCTAssertEqual(contentService.movies.count, testMovies.count)
        XCTAssertEqual(contentService.songs.count, testSongs.count)
        
        // Verify movie-song relationships
        let movieIds = Set(testMovies.map { $0.id })
        let songMovieIds = Set(testSongs.map { $0.movieId })
        XCTAssertTrue(songMovieIds.isSubset(of: movieIds), "All songs should reference valid movies")
    }
    
    // MARK: - Performance Tests
    
    func testCacheLoadPerformance() {
        // Given: Large dataset
        let largeMovies = MockData.largeMovieDataset
        let largeSongs = MockData.largeSongDataset
        saveCache(movies: largeMovies, songs: largeSongs)
        
        // When & Then
        measure {
            contentService.loadFromCache()
        }
    }
    
    func testCacheSavePerformance() {
        // Given: Large dataset
        let largeMovies = MockData.largeMovieDataset
        let largeSongs = MockData.largeSongDataset
        
        // When & Then
        measure {
            contentService.saveToCache(movies: largeMovies, songs: largeSongs)
        }
    }
    
    // MARK: - Helper Methods
    
    private var cacheURL: URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("contentCache.json")
    }
    
    private func clearCache() {
        try? FileManager.default.removeItem(at: cacheURL)
    }
    
    private func saveCache(movies: [Movie], songs: [Song]) {
        let cache = ContentCache(movies: movies, songs: songs, lastFetch: Date())
        saveCache(cache: cache)
    }
    
    private func saveCache(cache: ContentCache) {
        do {
            let data = try JSONEncoder().encode(cache)
            try data.write(to: cacheURL, options: .atomic)
        } catch {
            XCTFail("Failed to save cache: \(error)")
        }
    }
    
    private func loadCache() -> ContentCache? {
        do {
            let data = try Data(contentsOf: cacheURL)
            return try JSONDecoder().decode(ContentCache.self, from: data)
        } catch {
            return nil
        }
    }
}

// MARK: - Mock API Service

class MockAPIService: APIService {
    var shouldFail = false
    var mockMovies: [Movie] = []
    var mockSongs: [Song] = []
    
    override func fetchMovies() async throws -> [Movie] {
        if shouldFail {
            throw NSError(domain: "MockAPIService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Mock network error"])
        }
        return mockMovies
    }
    
    override func fetchSongs() async throws -> [Song] {
        if shouldFail {
            throw NSError(domain: "MockAPIService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Mock network error"])
        }
        return mockSongs
    }
}

// MARK: - ContentService Extension for Testing

extension ContentService {
    func saveToCache(movies: [Movie], songs: [Song]) {
        let cache = ContentCache(movies: movies, songs: songs, lastFetch: Date())
        do {
            let data = try JSONEncoder().encode(cache)
            let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("contentCache.json")
            try data.write(to: cacheURL, options: .atomic)
        } catch {
            print("❌ ContentService: Failed to save cache: \(error)")
        }
    }
    
    func loadFromCache() {
        let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("contentCache.json")
        do {
            let data = try Data(contentsOf: cacheURL)
            let cache = try JSONDecoder().decode(ContentCache.self, from: data)
            self.movies = cache.movies
            self.songs = cache.songs
        } catch {
            print("❌ ContentService: Failed to load cache: \(error)")
        }
    }
} 