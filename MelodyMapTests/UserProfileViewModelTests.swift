import XCTest
@testable import MelodyMap

@MainActor
final class UserProfileViewModelTests: XCTestCase {
    var viewModel: UserProfileViewModel!
    
    override func setUpWithError() throws {
        viewModel = UserProfileViewModel()
    }
    
    override func tearDownWithError() throws {
        viewModel = nil
    }
    
    // MARK: - Initialization Tests
    
    func testInitializationSetsDefaultValues() {
        XCTAssertEqual(viewModel.dailyUsesRemaining, 0)
        XCTAssertFalse(viewModel.isSubscribed)
    }
    
    // MARK: - Property Updates Tests
    
    func testDailyUsesRemainingCanBeUpdated() {
        // Given
        let newValue = 5
        
        // When
        viewModel.dailyUsesRemaining = newValue
        
        // Then
        XCTAssertEqual(viewModel.dailyUsesRemaining, newValue)
    }
    
    func testIsSubscribedCanBeUpdated() {
        // Given
        let newValue = true
        
        // When
        viewModel.isSubscribed = newValue
        
        // Then
        XCTAssertTrue(viewModel.isSubscribed)
    }
    
    // MARK: - ObservableObject Tests
    
    func testViewModelIsObservableObject() {
        // Test that the view model can be observed
        let expectation = XCTestExpectation(description: "Property change observed")
        
        // Create a simple observer
        let cancellable = viewModel.$dailyUsesRemaining
            .dropFirst() // Skip initial value
            .sink { _ in
                expectation.fulfill()
            }
        
        // Trigger a change
        viewModel.dailyUsesRemaining = 3
        
        // Wait for the change to be observed
        wait(for: [expectation], timeout: 1.0)
        cancellable.cancel()
    }
    
    func testSubscriptionStatusChangeIsObservable() {
        // Test that subscription status changes are observable
        let expectation = XCTestExpectation(description: "Subscription change observed")
        
        // Create a simple observer
        let cancellable = viewModel.$isSubscribed
            .dropFirst() // Skip initial value
            .sink { _ in
                expectation.fulfill()
            }
        
        // Trigger a change
        viewModel.isSubscribed = true
        
        // Wait for the change to be observed
        wait(for: [expectation], timeout: 1.0)
        cancellable.cancel()
    }
    
    // MARK: - Edge Cases
    
    func testDailyUsesRemainingHandlesNegativeValues() {
        // Given
        let negativeValue = -1
        
        // When
        viewModel.dailyUsesRemaining = negativeValue
        
        // Then
        XCTAssertEqual(viewModel.dailyUsesRemaining, negativeValue)
    }
    
    func testDailyUsesRemainingHandlesLargeValues() {
        // Given
        let largeValue = 999999
        
        // When
        viewModel.dailyUsesRemaining = largeValue
        
        // Then
        XCTAssertEqual(viewModel.dailyUsesRemaining, largeValue)
    }
    
    // MARK: - Integration Tests
    
    func testViewModelWithUsageTrackerService() {
        // Given
        let mockUsageTracker = MockUsageTrackerService()
        mockUsageTracker.mockRemaining = 2
        
        // When
        viewModel.dailyUsesRemaining = mockUsageTracker.remaining
        
        // Then
        XCTAssertEqual(viewModel.dailyUsesRemaining, 2)
    }
    
    func testViewModelWithPurchaseService() {
        // Given
        let mockPurchaseService = MockPurchaseService()
        mockPurchaseService.mockIsSubscriber = true
        
        // When
        viewModel.isSubscribed = mockPurchaseService.isSubscriber
        
        // Then
        XCTAssertTrue(viewModel.isSubscribed)
    }
} 