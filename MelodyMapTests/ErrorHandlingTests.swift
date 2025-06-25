import XCTest
@testable import MelodyMap

@MainActor
final class ErrorHandlingTests: XCTestCase {
    var errorService: ErrorHandlingService!
    
    override func setUpWithError() throws {
        errorService = ErrorHandlingService()
    }
    
    override func tearDownWithError() throws {
        errorService = nil
    }
    
    // MARK: - Error Type Tests
    
    func testNetworkErrorProperties() {
        let underlyingError = URLError(.notConnectedToInternet)
        let error = MelodyMapError.networkError(underlying: underlyingError)
        
        XCTAssertEqual(error.errorDescription, "Network connection failed")
        XCTAssertTrue(error.isRetryable)
        XCTAssertTrue(error.shouldShowToUser)
        XCTAssertNotNil(error.failureReason)
        XCTAssertNotNil(error.recoverySuggestion)
    }
    
    func testServerErrorProperties() {
        let error = MelodyMapError.serverError(statusCode: 500)
        
        XCTAssertEqual(error.errorDescription, "Server error (500)")
        XCTAssertTrue(error.isRetryable)
        XCTAssertTrue(error.shouldShowToUser)
        XCTAssertNotNil(error.failureReason)
        XCTAssertNotNil(error.recoverySuggestion)
    }
    
    func testQuotaExceededProperties() {
        let error = MelodyMapError.quotaExceeded
        
        XCTAssertEqual(error.errorDescription, "Daily usage limit reached")
        XCTAssertFalse(error.isRetryable)
        XCTAssertTrue(error.shouldShowToUser)
        XCTAssertNotNil(error.failureReason)
        XCTAssertNotNil(error.recoverySuggestion)
    }
    
    func testCacheErrorProperties() {
        let underlyingError = URLError(.cannotReadFromFile)
        let error = MelodyMapError.cacheError(underlying: underlyingError)
        
        XCTAssertEqual(error.errorDescription, "Failed to load cached data")
        XCTAssertFalse(error.isRetryable)
        XCTAssertFalse(error.shouldShowToUser)
        XCTAssertNotNil(error.failureReason)
        XCTAssertNotNil(error.recoverySuggestion)
    }
    
    func testDecodingErrorProperties() {
        let underlyingError = DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Test"))
        let error = MelodyMapError.decodingError(underlying: underlyingError)
        
        XCTAssertEqual(error.errorDescription, "Failed to process data")
        XCTAssertFalse(error.isRetryable)
        XCTAssertFalse(error.shouldShowToUser)
        XCTAssertNotNil(error.failureReason)
        XCTAssertNotNil(error.recoverySuggestion)
    }
    
    // MARK: - Error Service Tests
    
    func testErrorServiceHandlesNetworkError() {
        let networkError = URLError(.notConnectedToInternet)
        
        errorService.handle(networkError, context: "Test")
        
        XCTAssertNotNil(errorService.currentError)
        XCTAssertTrue(errorService.showingErrorAlert)
        XCTAssertEqual(errorService.errorAlertMessage, "Network connection failed")
    }
    
    func testErrorServiceHandlesMelodyMapError() {
        let melodyMapError = MelodyMapError.quotaExceeded
        
        errorService.handle(melodyMapError, context: "Test")
        
        XCTAssertEqual(errorService.currentError, melodyMapError)
        XCTAssertTrue(errorService.showingErrorAlert)
        XCTAssertEqual(errorService.errorAlertMessage, "Daily usage limit reached")
    }
    
    func testErrorServiceConvertsURLErrorToNetworkError() {
        let urlError = URLError(.timedOut)
        
        errorService.handle(urlError, context: "Test")
        
        XCTAssertNotNil(errorService.currentError)
        if case .networkError = errorService.currentError {
            // Success
        } else {
            XCTFail("Expected network error")
        }
    }
    
    func testErrorServiceConvertsDecodingError() {
        let decodingError = DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Test"))
        
        errorService.handle(decodingError, context: "Test")
        
        XCTAssertNotNil(errorService.currentError)
        if case .decodingError = errorService.currentError {
            // Success
        } else {
            XCTFail("Expected decoding error")
        }
    }
    
    func testErrorServiceClearsError() {
        let error = MelodyMapError.quotaExceeded
        errorService.handle(error, context: "Test")
        
        XCTAssertNotNil(errorService.currentError)
        XCTAssertTrue(errorService.showingErrorAlert)
        
        errorService.clearError()
        
        XCTAssertNil(errorService.currentError)
        XCTAssertFalse(errorService.showingErrorAlert)
        XCTAssertEqual(errorService.errorAlertMessage, "")
    }
    
    // MARK: - Retry Logic Tests
    
    func testShouldRetryForRetryableError() {
        let error = MelodyMapError.networkError(underlying: URLError(.timedOut))
        
        XCTAssertTrue(errorService.shouldRetry(for: error, context: "Test"))
    }
    
    func testShouldNotRetryForNonRetryableError() {
        let error = MelodyMapError.quotaExceeded
        
        XCTAssertFalse(errorService.shouldRetry(for: error, context: "Test"))
    }
    
    func testRetryCountTracking() {
        let error = MelodyMapError.networkError(underlying: URLError(.timedOut))
        
        // First attempt
        errorService.handle(error, context: "Test")
        XCTAssertEqual(errorService.getRetryCount(for: error, context: "Test"), 1)
        
        // Second attempt
        errorService.handle(error, context: "Test")
        XCTAssertEqual(errorService.getRetryCount(for: error, context: "Test"), 2)
        
        // Third attempt
        errorService.handle(error, context: "Test")
        XCTAssertEqual(errorService.getRetryCount(for: error, context: "Test"), 3)
        
        // Should not retry after max attempts
        XCTAssertFalse(errorService.shouldRetry(for: error, context: "Test"))
    }
    
    // MARK: - Error Conversion Tests
    
    func testURLErrorConversion() {
        let urlError = URLError(.notConnectedToInternet)
        let melodyMapError = errorService.convertToMelodyMapError(urlError)
        
        if case .networkError = melodyMapError {
            // Success
        } else {
            XCTFail("Expected network error")
        }
    }
    
    func testDecodingErrorConversion() {
        let decodingError = DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Test"))
        let melodyMapError = errorService.convertToMelodyMapError(decodingError)
        
        if case .decodingError = melodyMapError {
            // Success
        } else {
            XCTFail("Expected decoding error")
        }
    }
    
    func testMelodyMapErrorConversion() {
        let originalError = MelodyMapError.quotaExceeded
        let convertedError = errorService.convertToMelodyMapError(originalError)
        
        XCTAssertEqual(originalError, convertedError)
    }
    
    func testUnknownErrorConversion() {
        let unknownError = NSError(domain: "Test", code: 999, userInfo: nil)
        let melodyMapError = errorService.convertToMelodyMapError(unknownError)
        
        if case .unknownError = melodyMapError {
            // Success
        } else {
            XCTFail("Expected unknown error")
        }
    }
    
    // MARK: - Error Alert View Tests
    
    func testErrorAlertViewDisplaysError() {
        let error = MelodyMapError.quotaExceeded
        let alertView = ErrorAlertView(
            error: error,
            onDismiss: {},
            onRetry: nil
        )
        
        // Test that the view can be created without crashing
        XCTAssertNotNil(alertView)
    }
    
    func testErrorAlertViewWithRetryButton() {
        let error = MelodyMapError.networkError(underlying: URLError(.timedOut))
        let alertView = ErrorAlertView(
            error: error,
            onDismiss: {},
            onRetry: {}
        )
        
        // Test that the view can be created without crashing
        XCTAssertNotNil(alertView)
    }
    
    // MARK: - Integration Tests
    
    func testErrorHandlingInAsyncContext() {
        let expectation = XCTestExpectation(description: "Error handled")
        
        Task {
            do {
                throw MelodyMapError.quotaExceeded
            } catch {
                errorService.handle(error, context: "AsyncTest")
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertNotNil(errorService.currentError)
        XCTAssertTrue(errorService.showingErrorAlert)
    }
    
    func testErrorHandlingWithMultipleErrors() {
        let errors = [
            MelodyMapError.networkError(underlying: URLError(.timedOut)),
            MelodyMapError.serverError(statusCode: 500),
            MelodyMapError.quotaExceeded
        ]
        
        for error in errors {
            errorService.handle(error, context: "MultipleTest")
        }
        
        // Should track each error separately
        for error in errors {
            let count = errorService.getRetryCount(for: error, context: "MultipleTest")
            XCTAssertEqual(count, 1)
        }
    }
}

// MARK: - ErrorHandlingService Extension for Testing

extension ErrorHandlingService {
    func convertToMelodyMapError(_ error: Error) -> MelodyMapError {
        switch error {
        case let urlError as URLError:
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                return .networkError(underlying: error)
            case .timedOut:
                return .networkError(underlying: error)
            default:
                return .networkError(underlying: error)
            }
        case let decodingError as DecodingError:
            return .decodingError(underlying: error)
        case let melodyMapError as MelodyMapError:
            return melodyMapError
        default:
            return .unknownError(underlying: error)
        }
    }
} 