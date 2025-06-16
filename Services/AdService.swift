import Foundation
import Combine
import GoogleMobileAds

@MainActor
final class AdService: ObservableObject {
    static let shared = AdService()

    private let adUnitID = "ca-app-pub-3940256099942544/1712485313"

    private var rewardedAd: GADRewardedAd?
    private var rewardCompletion: ((Bool) -> Void)?

    private init() {
        loadAd()
    }

    func loadAd() {
        GADRewardedAd.load(withAdUnitID: adUnitID, request: GADRequest()) { [weak self] ad, error in
            if let ad = ad {
                self?.rewardedAd = ad
            } else {
                print("Failed to load rewarded ad: \(error?.localizedDescription ?? "unknown error")")
                self?.rewardedAd = nil
            }
        }
    }

    func presentAd(from rootVC: UIViewController, onEarned: @escaping (Bool) -> Void) {
        guard let ad = rewardedAd else {
            onEarned(false)
            loadAd()
            return
        }
        rewardCompletion = onEarned
        ad.fullScreenContentDelegate = self
        ad.present(fromRootViewController: rootVC) { [weak self] in
            self?.rewardCompletion?(true)
            self?.rewardCompletion = nil
            self?.rewardedAd = nil
            self?.loadAd()
        }
    }
}

extension AdService: GADFullScreenContentDelegate {
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        rewardCompletion?(false)
        rewardCompletion = nil
        rewardedAd = nil
        loadAd()
    }

    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        if rewardCompletion != nil {
            // Ad dismissed without reward
            rewardCompletion?(false)
            rewardCompletion = nil
        }
        rewardedAd = nil
        loadAd()
    }
}
