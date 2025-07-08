import Foundation
import SwiftUI

// MARK: - Custom Error Types

enum MelodyMapError: LocalizedError {
    case networkError(underlying: Error)
    case serverError(statusCode: Int)
    case cacheError(underlying: Error)
    case decodingError(underlying: Error)
    case quotaExceeded
    case musicKitError(underlying: Error)
    case purchaseError(underlying: Error)
    case adError(underlying: Error)
    case unknownError(underlying: Error)
    
    var errorDescription: String? {
        switch self {
        case .networkError:
            return "Network connection failed"
        case .serverError(let statusCode):
            return "Server error (\(statusCode))"
        case .cacheError:
            return "Failed to load cached data"
        case .decodingError:
            return "Failed to process data"
        case .quotaExceeded:
            return "Daily usage limit reached"
        case .musicKitError:
            return "Music preview unavailable"
        case .purchaseError:
            return "Purchase failed"
        case .adError:
            return "Ad loading failed"
        case .unknownError:
            return "An unexpected error occurred"
        }
    }
    
    var failureReason: String? {
        switch self {
        case .networkError(let error):
            return "Network request failed: \(error.localizedDescription)"
        case .serverError(let statusCode):
            return "Server returned status code: \(statusCode)"
        case .cacheError(let error):
            return "Cache operation failed: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Data parsing failed: \(error.localizedDescription)"
        case .quotaExceeded:
            return "You've reached your daily limit. Upgrade to continue."
        case .musicKitError(let error):
            return "Music service error: \(error.localizedDescription)"
        case .purchaseError(let error):
            return "Purchase processing failed: \(error.localizedDescription)"
        case .adError(let error):
            return "Ad loading failed: \(error.localizedDescription)"
        case .unknownError(let error):
            return "Unexpected error: \(error.localizedDescription)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .networkError:
            return "Please check your internet connection and try again."
        case .serverError:
            return "Please try again later. If the problem persists, contact support."
        case .cacheError:
            return "Try refreshing the app or restarting it."
        case .decodingError:
            return "The app data may be corrupted. Try refreshing."
        case .quotaExceeded:
            return "Watch an ad or upgrade to continue using the app."
        case .musicKitError:
            return "Make sure you have an active Apple Music subscription."
        case .purchaseError:
            return "Please try again or contact Apple Support."
        case .adError:
            return "Ad may be temporarily unavailable. Try again later."
        case .unknownError:
            return "Please restart the app and try again."
        }
    }
    
    var isRetryable: Bool {
        switch self {
        case .networkError, .serverError, .adError:
            return true
        case .quotaExceeded, .purchaseError:
            return false
        case .cacheError, .decodingError, .musicKitError, .unknownError:
            return false
        }
    }
    
    var shouldShowToUser: Bool {
        switch self {
        case .quotaExceeded, .purchaseError, .musicKitError:
            return true
        case .networkError, .serverError, .adError:
            return true
        case .cacheError, .decodingError, .unknownError:
            return false
        }
    }
}

// MARK: - Error Handling Service

@MainActor
final class ErrorHandlingService: ObservableObject {
    static let shared = ErrorHandlingService()
    
    @Published var currentError: MelodyMapError?
    @Published var showingErrorAlert = false
    @Published var errorAlertMessage = ""
    
    private var errorCounts: [String: Int] = [:]
    private let maxRetries = 3
    
    private init() {}
    
    func handle(_ error: Error, context: String = "Unknown") {
        let melodyMapError = convertToMelodyMapError(error)
        
        // Log the error
        logError(melodyMapError, context: context)
        
        // Check if we should show to user
        if melodyMapError.shouldShowToUser {
            showErrorToUser(melodyMapError)
        }
        
        // Track error for analytics
        trackError(melodyMapError, context: context)
    }
    
    func handle(_ error: MelodyMapError, context: String = "Unknown") {
        // Log the error
        logError(error, context: context)
        
        // Check if we should show to user
        if error.shouldShowToUser {
            showErrorToUser(error)
        }
        
        // Track error for analytics
        trackError(error, context: context)
    }
    
    private func convertToMelodyMapError(_ error: Error) -> MelodyMapError {
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
        case _ as DecodingError:
            return .decodingError(underlying: error)
        case let melodyMapError as MelodyMapError:
            return melodyMapError
        default:
            return .unknownError(underlying: error)
        }
    }
    
    private func showErrorToUser(_ error: MelodyMapError) {
        currentError = error
        errorAlertMessage = error.errorDescription ?? "An error occurred"
        showingErrorAlert = true
    }
    
    private func logError(_ error: MelodyMapError, context: String) {
        let errorKey = "\(context)_\(error.errorDescription ?? "unknown")"
        errorCounts[errorKey, default: 0] += 1
        
        print("🚨 [\(context)] Error: \(error.errorDescription ?? "Unknown")")
        print("   Reason: \(error.failureReason ?? "No reason provided")")
        print("   Recovery: \(error.recoverySuggestion ?? "No suggestion")")
        print("   Retryable: \(error.isRetryable)")
        print("   Count: \(errorCounts[errorKey] ?? 0)")
    }
    
    private func trackError(_ error: MelodyMapError, context: String) {
        // TODO: Integrate with analytics service
        // AnalyticsService.shared.trackError(error, context: context)
    }
    
    func clearError() {
        currentError = nil
        showingErrorAlert = false
        errorAlertMessage = ""
    }
    
    func shouldRetry(for error: MelodyMapError, context: String) -> Bool {
        guard error.isRetryable else { return false }
        
        let errorKey = "\(context)_\(error.errorDescription ?? "unknown")"
        let count = errorCounts[errorKey] ?? 0
        return count < maxRetries
    }
    
    func getRetryCount(for error: MelodyMapError, context: String) -> Int {
        let errorKey = "\(context)_\(error.errorDescription ?? "unknown")"
        return errorCounts[errorKey] ?? 0
    }
}

// MARK: - Error Alert View

struct ErrorAlertView: View {
    let error: MelodyMapError
    let onDismiss: () -> Void
    let onRetry: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundColor(.orange)
            
            Text(error.errorDescription ?? "Error")
                .font(.headline)
                .multilineTextAlignment(.center)
            
            if let reason = error.failureReason {
                Text(reason)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            if let suggestion = error.recoverySuggestion {
                Text(suggestion)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            HStack(spacing: 12) {
                Button("OK") {
                    onDismiss()
                }
                .buttonStyle(.bordered)
                
                if error.isRetryable, let onRetry = onRetry {
                    Button("Retry") {
                        onRetry()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .padding()
    }
}

// MARK: - Error Handling View Modifier

struct ErrorHandlingModifier: ViewModifier {
    @ObservedObject var errorService = ErrorHandlingService.shared
    
    func body(content: Content) -> some View {
        content
            .alert("Error", isPresented: $errorService.showingErrorAlert) {
                Button("OK") {
                    errorService.clearError()
                }
            } message: {
                Text(errorService.errorAlertMessage)
            }
    }
}

extension View {
    func errorHandling() -> some View {
        modifier(ErrorHandlingModifier())
    }
}

// MARK: - Result Extension

extension Result {
    func handleError(context: String = "Unknown") {
        switch self {
        case .success:
            break
        case .failure(let error):
            Task { @MainActor in
                ErrorHandlingService.shared.handle(error, context: context)
            }
        }
    }
    
    func handleError<T>(context: String = "Unknown", transform: (Failure) -> T) -> Result<Success, T> {
        switch self {
        case .success(let value):
            return .success(value)
        case .failure(let error):
            let transformedError = transform(error)
            Task { @MainActor in
                ErrorHandlingService.shared.handle(transformedError, context: context)
            }
            return .failure(transformedError)
        }
    }
}

// MARK: - Async Error Handling

extension Task where Failure == Never {
    static func withErrorHandling<T>(
        context: String = "Unknown",
        priority: TaskPriority? = nil,
        operation: @Sendable @escaping () async throws -> T
    ) -> Task<T?, Never> {
        Task<T?, Never>(priority: priority) {
            do {
                return try await operation()
            } catch {
                await MainActor.run {
                    ErrorHandlingService.shared.handle(error, context: context)
                }
                return nil
            }
        }
    }
    
    static func withErrorHandling<T>(
        context: String = "Unknown",
        priority: TaskPriority? = nil,
        defaultValue: T,
        operation: @Sendable @escaping () async throws -> T
    ) -> Task<T, Never> {
        Task<T, Never>(priority: priority) {
            do {
                return try await operation()
            } catch {
                await MainActor.run {
                    ErrorHandlingService.shared.handle(error, context: context)
                }
                return defaultValue
            }
        }
    }
}

// MARK: - Async Error Handling for Void Operations

extension Task where Failure == Never {
    static func withErrorHandling(
        context: String = "Unknown",
        priority: TaskPriority? = nil,
        operation: @Sendable @escaping () async throws -> Void
    ) -> Task<Void, Never> {
        Task<Void, Never>(priority: priority) {
            do {
                try await operation()
            } catch {
                await MainActor.run {
                    ErrorHandlingService.shared.handle(error, context: context)
                }
            }
        }
    }
} 