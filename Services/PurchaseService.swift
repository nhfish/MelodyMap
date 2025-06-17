import Foundation
import Combine

#if SUBS_ENABLED
import StoreKit

@MainActor
final class PurchaseService: ObservableObject {
    static let shared = PurchaseService()
    
    @Published var isSubscriber = false
    
    // TODO: Implement StoreKit 2 purchase logic
    func purchaseMonthly() {
        // StoreKit implementation will go here
    }
    
    func restorePurchases() {
        // StoreKit restore implementation will go here
    }
}
#else
@MainActor
final class PurchaseService: ObservableObject {
    static let shared = PurchaseService()
    
    @Published var isSubscriber = false
    
    func purchaseMonthly() {
        // Stub implementation when subscriptions are disabled
    }
    
    func restorePurchases() {
        // Stub implementation when subscriptions are disabled
    }
}
#endif 