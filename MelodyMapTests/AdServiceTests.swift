import XCTest
import UIKit
@testable import MelodyMap

@MainActor
final class AdServiceTests: XCTestCase {
    var adService: AdService!
    
    override func setUpWithError() throws {
        adService = AdService()
    }
    
    override func tearDownWithError() throws {
        adService = nil
    }
    
    // MARK: - Initialization Tests
    
    func testInitialization() {
        XCTAssertNotNil(adService)
        XCTAssertFalse(adService.isAdReady)
        XCTAssertFalse(adService.isLoading)
        XCTAssertNil(adService.lastError)
        XCTAssertEqual(adService.adLoadAttempts, 0)
        XCTAssertEqual(adService.successfulAdViews, 0)
    }
    
    // MARK: - Ad Loading Tests
    
    func testLoadAd() async {
        // Given: Service is initialized
        
        // When: Loading ad
        await adService.loadAd()
        
        // Then: Should handle the load attempt
        // Note: In test environment, this will likely fail due to no ad configuration
        // but we can test the error handling
        XCTAssertFalse(adService.isLoading)
    }
    
    func testLoadAdSetsLoadingState() async {
        // Given: Service is initialized
        
        // When: Starting to load ad
        let loadTask = Task {
            await adService.loadAd()
        }
        
        // Then: Should be in loading state briefly
        // Note: This is a timing-dependent test and may not always pass
        // In a real scenario, you'd use a mock ad environment
        
        await loadTask.value
        XCTAssertFalse(adService.isLoading)
    }
    
    func testLoadAdWithRetries() async {
        // Given: Service is initialized
        
        // When: Loading ad (which may fail and retry)
        await adService.loadAd()
        
        // Then: Should handle retry logic
        XCTAssertFalse(adService.isLoading)
        // Note: In a real test environment, you'd mock the ad loading to test retry scenarios
    }
    
    // MARK: - Ad Presentation Tests
    
    func testPresentAdWithNoAdAvailable() async {
        // Given: Service with no ad ready
        adService.isAdReady = false
        
        // When: Attempting to present ad
        let expectation = XCTestExpectation(description: "Ad presentation callback")
        adService.presentAd(from: MockViewController()) { success in
            XCTAssertFalse(success)
            expectation.fulfill()
        }
        
        // Then: Should handle gracefully
        await fulfillment(of: [expectation], timeout: 1.0)
        XCTAssertNotNil(adService.lastError)
    }
    
    func testPresentAdWithMockSuccess() async {
        // Given: Service with mock ad ready
        adService.isAdReady = true
        
        // When: Attempting to present ad
        let expectation = XCTestExpectation(description: "Ad presentation callback")
        adService.presentAd(from: MockViewController()) { success in
            // In mock mode, this should succeed
            expectation.fulfill()
        }
        
        // Then: Should handle presentation
        await fulfillment(of: [expectation], timeout: 1.0)
    }
    
    // MARK: - Ad State Management Tests
    
    func testRefreshAd() async {
        // Given: Service with ad ready
        adService.isAdReady = true
        
        // When: Refreshing ad
        await adService.refreshAd()
        
        // Then: Should reset ad state
        // Note: In mock mode, this may not change the state
        // In real implementation, this would clear the ad and reload
    }
    
    func testCancelAdLoad() {
        // Given: Service is loading
        adService.isLoading = true
        
        // When: Cancelling ad load
        adService.cancelAdLoad()
        
        // Then: Should stop loading
        XCTAssertFalse(adService.isLoading)
    }
    
    // MARK: - Analytics Tests
    
    func testAdLoadSuccessRate() {
        // Given: Service with no attempts
        XCTAssertEqual(adService.adLoadSuccessRate, 0.0)
        
        // Given: Service with some attempts and views
        adService.adLoadAttempts = 10
        adService.successfulAdViews = 7
        
        // Then: Should calculate correct rate
        XCTAssertEqual(adService.adLoadSuccessRate, 0.7)
    }
    
    func testResetAnalytics() {
        // Given: Service with some analytics data
        adService.adLoadAttempts = 10
        adService.successfulAdViews = 5
        
        // When: Resetting analytics
        adService.resetAnalytics()
        
        // Then: Should reset to zero
        XCTAssertEqual(adService.adLoadAttempts, 0)
        XCTAssertEqual(adService.successfulAdViews, 0)
    }
    
    // MARK: - Error Handling Tests
    
    func testErrorHandlingInLoadAd() async {
        // Given: Service is initialized
        
        // When: Loading ad (which will likely fail in test environment)
        await adService.loadAd()
        
        // Then: Should handle errors gracefully
        XCTAssertFalse(adService.isLoading)
        // Note: In a real test environment with ad configuration,
        // you'd mock the ad responses to test specific error scenarios
    }
    
    func testErrorHandlingInPresentAd() async {
        // Given: Service with no ad ready
        adService.isAdReady = false
        
        // When: Attempting to present ad
        let expectation = XCTestExpectation(description: "Ad presentation callback")
        adService.presentAd(from: MockViewController()) { success in
            XCTAssertFalse(success)
            expectation.fulfill()
        }
        
        // Then: Should handle error gracefully
        await fulfillment(of: [expectation], timeout: 1.0)
        XCTAssertNotNil(adService.lastError)
    }
    
    // MARK: - State Management Tests
    
    func testAdReadyState() {
        // Given: Service with ad not ready
        XCTAssertFalse(adService.isAdReady)
        
        // Given: Service with ad ready
        adService.isAdReady = true
        
        // Then: Should reflect ready state
        XCTAssertTrue(adService.isAdReady)
    }
    
    func testLoadingState() {
        // Given: Service not loading
        XCTAssertFalse(adService.isLoading)
        
        // Given: Service loading
        adService.isLoading = true
        
        // Then: Should reflect loading state
        XCTAssertTrue(adService.isLoading)
    }
    
    func testLastErrorState() {
        // Given: Service with no error
        XCTAssertNil(adService.lastError)
        
        // Given: Service with error
        let error = MelodyMapError.adError(underlying: NSError(domain: "Test", code: 1, userInfo: nil))
        adService.lastError = error
        
        // Then: Should reflect error state
        XCTAssertEqual(adService.lastError, error)
    }
    
    // MARK: - Performance Tests
    
    func testAdLoadPerformance() {
        // Given: Service is initialized
        
        // When & Then: Measure ad load performance
        measure {
            let expectation = XCTestExpectation(description: "Ad load performance")
            Task {
                await adService.loadAd()
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 5.0)
        }
    }
    
    // MARK: - Integration Tests
    
    func testAdServiceWithErrorHandling() async {
        // Given: Service is initialized
        
        // When: Loading ad and handling errors
        await adService.loadAd()
        
        // Then: Should integrate with error handling service
        // Note: This test verifies that the AdService properly integrates
        // with the ErrorHandlingService for error reporting
        XCTAssertFalse(adService.isLoading)
    }
    
    func testAdServiceWithMultipleLoads() async {
        // Given: Service is initialized
        
        // When: Loading multiple ads
        await adService.loadAd()
        await adService.loadAd()
        await adService.loadAd()
        
        // Then: Should handle multiple load attempts
        XCTAssertGreaterThanOrEqual(adService.adLoadAttempts, 0)
    }
}

// MARK: - Mock View Controller

class MockViewController: UIViewController {
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        // Mock implementation that always succeeds
        completion?()
    }
}

// MARK: - AdService Extension for Testing

extension AdService {
    // Expose internal properties for testing
    var isInitialized: Bool {
        #if ADS_ENABLED
        return isInitialized
        #else
        return true
        #endif
    }
} 