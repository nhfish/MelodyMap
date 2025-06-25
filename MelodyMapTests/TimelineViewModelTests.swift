import XCTest
@testable import MelodyMap

@MainActor
final class TimelineViewModelTests: XCTestCase {
    var viewModel: TimelineViewModel!
    var mockUsageTracker: MockUsageTrackerService!
    
    override func setUpWithError() throws {
        viewModel = TimelineViewModel()
        mockUsageTracker = MockUsageTrackerService()
        UsageTrackerService.shared = mockUsageTracker
    }
    
    override func tearDownWithError() throws {
        viewModel = nil
        mockUsageTracker = nil
    }
    
    func testNavigateToMovieWithSongSetsCorrectIndexAndSong() {
        let movies = MockData.sampleMovies
        let indexedSong = MockData.sampleIndexedSongs[2] // Lion King song
        
        viewModel.navigateToMovieWithSong(indexedSong, movies: movies)
        
        XCTAssertEqual(viewModel.currentMovieIndex, 2)
        XCTAssertEqual(viewModel.preSelectedSong?.id, indexedSong.song.id)
    }
    
    func testNavigateToMovieWithSongWithMissingMovieDoesNothing() {
        let movies = MockData.sampleMovies
        let fakeMovie = Movie(id: "fake", title: "Fake", imageURL: "", releaseYear: 2020, sortOrder: 99)
        let fakeSong = Song(id: "fake-song", movieId: "fake", title: "Fake Song", percent: 0, startTime: "00:00:00", singers: [], releaseYear: 2020, movieRuntimeMinutes: 90, streamingLinks: [], purchaseLinks: [], keywords: [], blurb: "")
        let indexedSong = IndexedSong(song: fakeSong, movie: fakeMovie)
        
        viewModel.navigateToMovieWithSong(indexedSong, movies: movies)
        
        XCTAssertNotEqual(viewModel.currentMovieIndex, 99)
        XCTAssertNil(viewModel.preSelectedSong)
    }
    
    func testPresentSongDetailWithQuotaAvailable() {
        let song = MockData.sampleSongs[0]
        mockUsageTracker.mockRemaining = 3
        
        viewModel.presentSongDetail(for: song)
        
        XCTAssertEqual(viewModel.selectedSong?.id, song.id)
        XCTAssertFalse(viewModel.showQuotaSheet)
        XCTAssertTrue(mockUsageTracker.consumeUseCalled)
    }
    
    func testPresentSongDetailWithNoQuotaShowsSheet() {
        let song = MockData.sampleSongs[0]
        mockUsageTracker.mockRemaining = 0
        
        viewModel.presentSongDetail(for: song)
        
        XCTAssertNil(viewModel.selectedSong)
        XCTAssertTrue(viewModel.showQuotaSheet)
        XCTAssertFalse(mockUsageTracker.consumeUseCalled)
    }
    
    func testHandleWatchAdAddsRewardAndHidesSheet() {
        viewModel.showQuotaSheet = true
        
        viewModel.handleWatchAd()
        
        XCTAssertFalse(viewModel.showQuotaSheet)
        XCTAssertTrue(mockUsageTracker.addRewardedCalled)
    }
    
    func testHandleUpgradeHidesSheet() {
        viewModel.showQuotaSheet = true
        
        viewModel.handleUpgrade()
        
        XCTAssertFalse(viewModel.showQuotaSheet)
    }
} 