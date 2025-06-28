import Foundation
import Combine
import UIKit

#if ADS_ENABLED
import GoogleMobileAds
#endif

@MainActor
final class AdService: NSObject, ObservableObject {
    @MainActor
    static let shared = AdService()

    // MARK: - Published Properties
    @Published var isAdReady = false
    @Published var isLoading = false
    @Published var lastError: MelodyMapError?
    @Published var adLoadAttempts = 0
    @Published var successfulAdViews = 0
    
    #if ADS_ENABLED
    // Production AdMob ad unit ID
    private let adUnitID = "ca-app-pub-6529806187401992/5730777125"
    private var rewardedAd: GADRewardedAd?
    private var adLoadTask: Task<Void, Never>?
    private let maxRetries = 3
    private let retryDelay: TimeInterval = 5.0
    #endif
    
    private var rewardCompletion: ((Bool) -> Void)?
    private var isInitialized = false

    private override init() {
        super.init()
        
        #if ADS_ENABLED
        initializeAds()
        #else
        print("Google Ads disabled - using mock implementation")
        #endif
    }
    
    deinit {
        #if ADS_ENABLED
        adLoadTask?.cancel()
        #endif
    }

    // MARK: - Initialization
    
    #if ADS_ENABLED
    private func initializeAds() {
        guard !isInitialized else { return }
        
        // Google Mobile Ads initialization
        GADMobileAds.sharedInstance().start { [weak self] status in
            Task { @MainActor in
                print("Google Mobile Ads initialization status: \(status)")
                self?.isInitialized = true
                
                // Load initial ad after initialization
                await self?.loadAd()
            }
        }
    }
    #endif

    // MARK: - Ad Loading
    
    func loadAd() async {
        #if ADS_ENABLED
        guard isInitialized else {
            print("⚠️ Ads not initialized yet")
            return
        }
        
        // Cancel any existing load task
        adLoadTask?.cancel()
        
        isLoading = true
        lastError = nil
        
        adLoadTask = Task {
            var attempts = 0
            
            while attempts < maxRetries && !Task.isCancelled {
                attempts += 1
                adLoadAttempts += 1
                
                do {
                    try await loadAdWithRetry()
                    break
                } catch {
                    let adError = MelodyMapError.adError(underlying: error)
                    lastError = adError
                    ErrorHandlingService.shared.handle(adError, context: "AdService.loadAd")
                    
                    if attempts < maxRetries && !Task.isCancelled {
                        print("🔄 Retrying ad load in \(retryDelay) seconds... (attempt \(attempts + 1)/\(maxRetries))")
                        try? await Task.sleep(nanoseconds: UInt64(retryDelay * 1_000_000_000))
                    }
                }
            }
            
            if Task.isCancelled {
                print("❌ Ad load cancelled")
            }
            
            isLoading = false
        }
        #else
        // Mock implementation
        isLoading = true
        try? await Task.sleep(nanoseconds: 1_000_000_000) // Simulate loading time
        isAdReady = true
        isLoading = false
        print("Ad loading disabled - mock implementation")
        #endif
    }
    
    #if ADS_ENABLED
    private func loadAdWithRetry() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            GADRewardedAd.load(withAdUnitID: adUnitID, request: GADRequest()) { [weak self] ad, error in
                Task { @MainActor in
                    if let error = error {
                        print("❌ Failed to load rewarded ad: \(error.localizedDescription)")
                        continuation.resume(throwing: error)
                        return
                    }
                    
                    guard let ad = ad else {
                        let error = NSError(domain: "AdService", code: 404, userInfo: [NSLocalizedDescriptionKey: "No ad returned"])
                        continuation.resume(throwing: error)
                        return
                    }
                    
                    self?.rewardedAd = ad
                    self?.isAdReady = true
                    self?.lastError = nil
                    print("✅ Rewarded ad loaded successfully")
                    continuation.resume()
                }
            }
        }
    }
    #endif

    // MARK: - Ad Presentation
    
    func presentAd(from rootVC: UIViewController, onEarned: @escaping (Bool) -> Void) {
        #if ADS_ENABLED
        guard let ad = rewardedAd else {
            print("❌ No ad available to present")
            let adError = MelodyMapError.adError(underlying: NSError(domain: "AdService", code: 404, userInfo: [NSLocalizedDescriptionKey: "No ad available"]))
            lastError = adError
            ErrorHandlingService.shared.handle(adError, context: "AdService.presentAd")
            onEarned(false)
            
            // Try to load a new ad
            Task {
                await loadAd()
            }
            return
        }
        
        rewardCompletion = onEarned
        ad.fullScreenContentDelegate = self
        
        do {
            ad.present(fromRootViewController: rootVC) { [weak self] in
                Task { @MainActor in
                    self?.successfulAdViews += 1
                    self?.rewardCompletion?(true)
                    self?.rewardCompletion = nil
                    self?.rewardedAd = nil
                    self?.isAdReady = false
                    await self?.loadAd()
                }
            }
        } catch {
            let adError = MelodyMapError.adError(underlying: error)
            lastError = adError
            ErrorHandlingService.shared.handle(adError, context: "AdService.presentAd")
            onEarned(false)
        }
        #else
        // Mock implementation that always succeeds
        print("Ad presentation disabled - simulating successful ad view")
        successfulAdViews += 1
        onEarned(true)
        #endif
    }
    
    // MARK: - Ad State Management
    
    func refreshAd() async {
        #if ADS_ENABLED
        rewardedAd = nil
        isAdReady = false
        await loadAd()
        #else
        print("Ad refresh disabled - mock implementation")
        #endif
    }
    
    func cancelAdLoad() {
        #if ADS_ENABLED
        adLoadTask?.cancel()
        isLoading = false
        #endif
    }
    
    // MARK: - Analytics
    
    var adLoadSuccessRate: Double {
        guard adLoadAttempts > 0 else { return 0.0 }
        return Double(successfulAdViews) / Double(adLoadAttempts)
    }
    
    func resetAnalytics() {
        adLoadAttempts = 0
        successfulAdViews = 0
    }
}

#if ADS_ENABLED
extension AdService: GADFullScreenContentDelegate {
    func ad(_ ad: GADFullScreenPresentingAd,
            didFailToPresentFullScreenContentWithError error: Error) {
        Task { @MainActor in
            print("❌ Ad failed to present: \(error.localizedDescription)")
            let adError = MelodyMapError.adError(underlying: error)
            lastError = adError
            ErrorHandlingService.shared.handle(adError, context: "AdService.presentation")
            
            rewardCompletion?(false)
            rewardCompletion = nil
            rewardedAd = nil
            isAdReady = false
            await loadAd()
        }
    }

    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        Task { @MainActor in
            print("📱 Ad dismissed")
            if rewardCompletion != nil {
                rewardCompletion?(false)
                rewardCompletion = nil
            }
            rewardedAd = nil
            isAdReady = false
            await loadAd()
        }
    }
    
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("📱 Ad will present")
    }
    
    func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        print("📱 Ad impression recorded")
    }
    
    func adDidRecordClick(_ ad: GADFullScreenPresentingAd) {
        print("📱 Ad click recorded")
    }
}
#endif
