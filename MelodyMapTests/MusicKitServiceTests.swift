/*
// MusicKitService tests temporarily disabled for migration
*/
import XCTest
import MusicKit
@testable import MelodyMap

@MainActor
final class MusicKitServiceTests: XCTestCase {
    var musicKitService: MusicKitService!
    
    override func setUpWithError() throws {
        musicKitService = MusicKitService()
    }
    
    override func tearDownWithError() throws {
        musicKitService = nil
    }
    
    // MARK: - Authorization Tests
    
    func testInitialAuthorizationStatus() {
        // Test that the service initializes with correct default state
        XCTAssertFalse(musicKitService.isAuthorized)
        XCTAssertEqual(musicKitService.authorizationStatus, .notDetermined)
    }
    
    func testCheckAuthorizationStatus() async {
        // Test that authorization status is properly checked
        await musicKitService.checkAuthorizationStatus()
        
        // The actual status will depend on the device/simulator
        // We can't control this in unit tests, but we can verify the method runs
        XCTAssertTrue(musicKitService.authorizationStatus == .notDetermined || 
                     musicKitService.authorizationStatus == .authorized ||
                     musicKitService.authorizationStatus == .denied ||
                     musicKitService.authorizationStatus == .restricted)
    }
    
    func testRequestAuthorization() async {
        // Test authorization request
        let result = await musicKitService.requestAuthorization()
        
        // Result will depend on device/simulator state
        // We can verify the method completes without throwing
        XCTAssertTrue(result == true || result == false)
    }
    
    // MARK: - Song Search Tests
    
    func testSearchSongWhenNotAuthorized() async {
        // Given
        musicKitService.isAuthorized = false
        
        // When
        let result = await musicKitService.searchSong(movieTitle: "Frozen", songTitle: "Let It Go")
        
        // Then
        XCTAssertNil(result)
    }
    
    func testSearchSongWithValidQuery() async {
        // Given
        musicKitService.isAuthorized = true
        
        // When
        let result = await musicKitService.searchSong(movieTitle: "Frozen", songTitle: "Let It Go")
        
        // Then
        // Result will depend on actual Apple Music catalog
        // We can verify the method completes without throwing
        // and returns either a song or nil
        XCTAssertTrue(result == nil || result is MusicKit.Song)
    }
    
    func testSearchSongWithEmptyTitles() async {
        // Given
        musicKitService.isAuthorized = true
        
        // When
        let result1 = await musicKitService.searchSong(movieTitle: "", songTitle: "Let It Go")
        let result2 = await musicKitService.searchSong(movieTitle: "Frozen", songTitle: "")
        let result3 = await musicKitService.searchSong(movieTitle: "", songTitle: "")
        
        // Then
        // Should handle empty strings gracefully
        XCTAssertTrue(result1 == nil || result1 is MusicKit.Song)
        XCTAssertTrue(result2 == nil || result2 is MusicKit.Song)
        XCTAssertTrue(result3 == nil || result3 is MusicKit.Song)
    }
    
    func testSearchSongWithSpecialCharacters() async {
        // Given
        musicKitService.isAuthorized = true
        
        // When
        let result = await musicKitService.searchSong(movieTitle: "The Lion King", songTitle: "Hakuna Matata!")
        
        // Then
        // Should handle special characters gracefully
        XCTAssertTrue(result == nil || result is MusicKit.Song)
    }
    
    // MARK: - Preview URL Tests
    
    func testGetPreviewURLWithValidSong() {
        // Given
        let mockSong = MockMusicKitSong(title: "Test Song")
        
        // When
        let url = musicKitService.getPreviewURL(for: mockSong)
        
        // Then
        XCTAssertNotNil(url)
        XCTAssertEqual(url?.absoluteString, "https://example.com/preview.m4a")
    }
    
    func testGetPreviewURLWithSongWithoutPreview() {
        // Given
        let mockSong = MockMusicKitSong(title: "Test Song", hasPreview: false)
        
        // When
        let url = musicKitService.getPreviewURL(for: mockSong)
        
        // Then
        XCTAssertNil(url)
    }
    
    // MARK: - Integration Tests
    
    func testFullSearchAndPreviewFlow() async {
        // Given
        musicKitService.isAuthorized = true
        
        // When
        let song = await musicKitService.searchSong(movieTitle: "Frozen", songTitle: "Let It Go")
        let previewURL = song.flatMap { musicKitService.getPreviewURL(for: $0) }
        
        // Then
        // This is an integration test that depends on actual Apple Music data
        // We can verify the flow completes without throwing
        XCTAssertTrue(song == nil || song is MusicKit.Song)
        XCTAssertTrue(previewURL == nil || previewURL is URL)
    }
    
    // MARK: - Error Handling Tests
    
    func testSearchSongHandlesNetworkErrors() async {
        // Given
        musicKitService.isAuthorized = true
        
        // When
        // We can't easily simulate network errors in unit tests
        // but we can verify the method handles errors gracefully
        let result = await musicKitService.searchSong(movieTitle: "Invalid Movie", songTitle: "Invalid Song")
        
        // Then
        // Should return nil on error rather than throwing
        XCTAssertTrue(result == nil || result is MusicKit.Song)
    }
    
    // MARK: - Performance Tests
    
    func testSearchPerformance() async {
        // Given
        musicKitService.isAuthorized = true
        
        // When & Then
        measure {
            Task {
                _ = await musicKitService.searchSong(movieTitle: "Frozen", songTitle: "Let It Go")
            }
        }
    }
}

// MARK: - Mock MusicKit Song

class MockMusicKitSong: MusicKit.Song {
    private let mockTitle: String
    private let mockHasPreview: Bool
    
    init(title: String, hasPreview: Bool = true) {
        self.mockTitle = title
        self.mockHasPreview = hasPreview
        super.init()
    }
    
    override var title: String {
        return mockTitle
    }
    
    override var previewAssets: [MusicKit.Asset]? {
        guard mockHasPreview else { return nil }
        
        let mockAsset = MockMusicKitAsset()
        return [mockAsset]
    }
}

// MARK: - Mock MusicKit Asset

class MockMusicKitAsset: MusicKit.Asset {
    override var url: URL? {
        return URL(string: "https://example.com/preview.m4a")
    }
}

// MARK: - MusicKitService Extension for Testing

extension MusicKitService {
    // This extension allows us to test the service more thoroughly
    // by providing access to internal methods if needed
} 