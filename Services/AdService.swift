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

    #if ADS_ENABLED
    private let adUnitID = "ca-app-pub-3940256099942544/1712485313"
    private var rewardedAd: GADRewardedAd?
    #endif
    
    private var rewardCompletion: ((Bool) -> Void)?

    private override init() {
        super.init()
        
        #if ADS_ENABLED
        // Google Mobile Ads initialization
        GADMobileAds.sharedInstance().start { status in
            print("Google Mobile Ads initialization status: \(status)")
        }
        // Load initial ad
        Task { @MainActor in
            await self.loadAd()
        }
        #else
        print("Google Ads disabled - using mock implementation")
        #endif
    }

    func loadAd() async {
        #if ADS_ENABLED
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            GADRewardedAd.load(withAdUnitID: adUnitID, request: GADRequest()) { ad, error in
                Task { @MainActor in
                    if let ad = ad {
                        self.rewardedAd = ad
                        print("Rewarded ad loaded successfully")
                    } else {
                        print("Failed to load rewarded ad: \(error?.localizedDescription ?? "unknown error")")
                        self.rewardedAd = nil
                    }
                    continuation.resume()
                }
            }
        }
        #else
        print("Ad loading disabled - mock implementation")
        #endif
    }

    func presentAd(from rootVC: UIViewController, onEarned: @escaping (Bool) -> Void) {
        #if ADS_ENABLED
        guard let ad = rewardedAd else {
            onEarned(false)
            Task { @MainActor in
                await self.loadAd()
            }
            return
        }
        rewardCompletion = onEarned
        ad.fullScreenContentDelegate = self
        ad.present(fromRootViewController: rootVC) {
            Task { @MainActor in
                self.rewardCompletion?(true)
                self.rewardCompletion = nil
                self.rewardedAd = nil
                await self.loadAd()
            }
        }
        #else
        // Mock implementation that always succeeds
        print("Ad presentation disabled - simulating successful ad view")
        onEarned(true)
        #endif
    }
}

#if ADS_ENABLED
extension AdService: GADFullScreenContentDelegate {
    func ad(_ ad: GADFullScreenPresentingAd,
            didFailToPresentFullScreenContentWithError error: Error) {
        Task { @MainActor in
            rewardCompletion?(false)
            rewardCompletion = nil
            rewardedAd = nil
            await loadAd()
        }
    }

    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        Task { @MainActor in
            if rewardCompletion != nil {
                rewardCompletion?(false)
                rewardCompletion = nil
            }
            rewardedAd = nil
            await loadAd()
        }
    }
}
#endif
