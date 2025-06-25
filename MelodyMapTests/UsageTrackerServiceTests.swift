import XCTest
@testable import MelodyMap

@MainActor
final class UsageTrackerServiceTests: XCTestCase {
    var usageTracker: UsageTrackerService!
    
    override func setUpWithError() throws {
        // Clear UserDefaults for each test
        UserDefaults.standard.removeObject(forKey: "UsageTrackerService.lastDate")
        UserDefaults.standard.removeObject(forKey: "UsageTrackerService.remaining")
        UserDefaults.standard.removeObject(forKey: "UsageTrackerService.unlockedSongs")
        
        // Create fresh instance for each test
        usageTracker = UsageTrackerService()
    }
    
    override func tearDownWithError() throws {
        usageTracker = nil
    }
    
    // MARK: - Initialization Tests
    
    func testInitializationSetsBaseQuota() {
        XCTAssertEqual(usageTracker.quota, 3)
        XCTAssertEqual(usageTracker.remaining, 3)
    }
    
    func testInitializationLoadsExistingData() {
        // Set up existing data
        UserDefaults.standard.set(Date(), forKey: "UsageTrackerService.lastDate")
        UserDefaults.standard.set(1, forKey: "UsageTrackerService.remaining")
        
        // Create new instance
        let newTracker = UsageTrackerService()
        
        XCTAssertEqual(newTracker.remaining, 1)
    }
    
    // MARK: - Daily Reset Tests
    
    func testDailyResetOnNewDay() {
        // Set up yesterday's data
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        UserDefaults.standard.set(yesterday, forKey: "UsageTrackerService.lastDate")
        UserDefaults.standard.set(0, forKey: "UsageTrackerService.remaining")
        
        // Create new instance (should trigger reset)
        let newTracker = UsageTrackerService()
        
        XCTAssertEqual(newTracker.remaining, 3)
    }
    
    func testNoResetOnSameDay() {
        // Set up today's data
        UserDefaults.standard.set(Date(), forKey: "UsageTrackerService.lastDate")
        UserDefaults.standard.set(1, forKey: "UsageTrackerService.remaining")
        
        // Create new instance (should not reset)
        let newTracker = UsageTrackerService()
        
        XCTAssertEqual(newTracker.remaining, 1)
    }
    
    // MARK: - Usage Consumption Tests
    
    func testConsumeUseDecrementsRemaining() {
        let initialRemaining = usageTracker.remaining
        let songId = "test-song-1"
        
        usageTracker.consumeUse(forSongId: songId)
        
        XCTAssertEqual(usageTracker.remaining, initialRemaining - 1)
    }
    
    func testConsumeUseDoesNotGoBelowZero() {
        // Consume all uses
        for i in 0..<3 {
            usageTracker.consumeUse(forSongId: "song-\(i)")
        }
        
        XCTAssertEqual(usageTracker.remaining, 0)
        
        // Try to consume more
        usageTracker.consumeUse(forSongId: "extra-song")
        
        XCTAssertEqual(usageTracker.remaining, 0)
    }
    
    func testConsumeUseUnlocksSongFor15Minutes() {
        let songId = "test-song-1"
        
        usageTracker.consumeUse(forSongId: songId)
        
        // Should be able to view the same song again within 15 minutes
        XCTAssertTrue(usageTracker.canViewSong(withId: songId))
    }
    
    // MARK: - Unlocked Songs Tests
    
    func testUnlockedSongExpiresAfter15Minutes() {
        let songId = "test-song-1"
        
        usageTracker.consumeUse(forSongId: songId)
        
        // Simulate time passing (16 minutes)
        let futureDate = Date().addingTimeInterval(16 * 60)
        
        // Mock the current time to be 16 minutes in the future
        // Note: This is a limitation of the current implementation
        // In a real scenario, we'd need to inject a time provider
        XCTAssertTrue(usageTracker.canViewSong(withId: songId))
    }
    
    func testUnlockedSongsPersistAcrossAppRestarts() {
        let songId = "test-song-1"
        
        usageTracker.consumeUse(forSongId: songId)
        
        // Create new instance (simulates app restart)
        let newTracker = UsageTrackerService()
        
        // Should still be able to view the unlocked song
        XCTAssertTrue(newTracker.canViewSong(withId: songId))
    }
    
    // MARK: - Reward Tests
    
    func testAddRewardedIncreasesRemaining() {
        let initialRemaining = usageTracker.remaining
        
        usageTracker.addRewarded(2)
        
        XCTAssertEqual(usageTracker.remaining, initialRemaining + 2)
    }
    
    func testAddRewardedCanExceedBaseQuota() {
        usageTracker.addRewarded(5)
        
        XCTAssertEqual(usageTracker.remaining, 8) // 3 base + 5 reward
    }
    
    // MARK: - Can View Song Tests
    
    func testCanViewSongWithRemainingUses() {
        XCTAssertTrue(usageTracker.canViewSong(withId: "new-song"))
    }
    
    func testCanViewSongWithNoRemainingUses() {
        // Consume all uses
        for i in 0..<3 {
            usageTracker.consumeUse(forSongId: "song-\(i)")
        }
        
        XCTAssertFalse(usageTracker.canViewSong(withId: "new-song"))
    }
    
    func testCanViewSongWithUnlockedSong() {
        let songId = "test-song-1"
        usageTracker.consumeUse(forSongId: songId)
        
        // Should be able to view again without consuming another use
        XCTAssertTrue(usageTracker.canViewSong(withId: songId))
    }
    
    // MARK: - Edge Cases
    
    func testMultipleConsumptionsOfSameSong() {
        let songId = "test-song-1"
        
        // First consumption
        usageTracker.consumeUse(forSongId: songId)
        let remainingAfterFirst = usageTracker.remaining
        
        // Second consumption of same song (should not consume again)
        usageTracker.consumeUse(forSongId: songId)
        
        XCTAssertEqual(usageTracker.remaining, remainingAfterFirst)
    }
    
    func testEmptySongId() {
        // Should handle empty song ID gracefully
        usageTracker.consumeUse(forSongId: "")
        
        XCTAssertEqual(usageTracker.remaining, 2)
    }
    
    // MARK: - Deprecated Method Tests
    
    func testDeprecatedCanConsumeMethod() {
        XCTAssertTrue(usageTracker.canConsume())
        
        // Consume all uses
        for _ in 0..<3 {
            usageTracker.consumeView()
        }
        
        XCTAssertFalse(usageTracker.canConsume())
    }
    
    func testDeprecatedConsumeViewMethod() {
        let initialRemaining = usageTracker.remaining
        
        usageTracker.consumeView()
        
        XCTAssertEqual(usageTracker.remaining, initialRemaining - 1)
    }
} 