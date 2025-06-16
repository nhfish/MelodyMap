import Foundation
import Combine

@MainActor
final class InAppPurchaseService: ObservableObject {
    static let shared = InAppPurchaseService()

    func purchaseMonthly() {
        // TODO: Implement StoreKit 2 purchase
    }
}
