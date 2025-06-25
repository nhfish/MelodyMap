import Foundation
import Combine

#if SUBS_ENABLED
import StoreKit

@MainActor
final class PurchaseService: ObservableObject {
    static let shared = PurchaseService()
    
    // MARK: - Published Properties
    @Published var isSubscriber = false
    @Published var isLoading = false
    @Published var currentSubscription: Product.SubscriptionInfo?
    @Published var availableProducts: [Product] = []
    @Published var lastError: MelodyMapError?
    
    // MARK: - Private Properties
    private var updateListenerTask: Task<Void, Error>?
    private var productsLoaded = false
    
    // MARK: - Product Identifiers
    private let monthlySubscriptionID = "com.melodymap.monthly"
    private let yearlySubscriptionID = "com.melodymap.yearly"
    
    private init() {
        updateListenerTask = listenForTransactions()
        Task {
            await loadProducts()
            await updateSubscriptionStatus()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Public Methods
    
    func loadProducts() async {
        guard !productsLoaded else { return }
        
        isLoading = true
        lastError = nil
        
        do {
            let productIDs = Set([monthlySubscriptionID, yearlySubscriptionID])
            let products = try await Product.products(for: productIDs)
            
            self.availableProducts = products.sorted { $0.price < $1.price }
            self.productsLoaded = true
            
            print("📦 Loaded \(products.count) products")
        } catch {
            let purchaseError = MelodyMapError.purchaseError(underlying: error)
            self.lastError = purchaseError
            ErrorHandlingService.shared.handle(purchaseError, context: "PurchaseService.loadProducts")
        }
        
        isLoading = false
    }
    
    func purchaseMonthly() async {
        await purchase(productID: monthlySubscriptionID)
    }
    
    func purchaseYearly() async {
        await purchase(productID: yearlySubscriptionID)
    }
    
    func purchase(_ product: Product) async {
        isLoading = true
        lastError = nil
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                await handlePurchaseSuccess(verification)
            case .userCancelled:
                print("❌ Purchase cancelled by user")
            case .pending:
                print("⏳ Purchase pending")
            @unknown default:
                print("❓ Unknown purchase result")
            }
        } catch {
            let purchaseError = MelodyMapError.purchaseError(underlying: error)
            self.lastError = purchaseError
            ErrorHandlingService.shared.handle(purchaseError, context: "PurchaseService.purchase")
        }
        
        isLoading = false
    }
    
    func restorePurchases() async {
        isLoading = true
        lastError = nil
        
        do {
            try await AppStore.sync()
            await updateSubscriptionStatus()
            print("✅ Purchases restored successfully")
        } catch {
            let purchaseError = MelodyMapError.purchaseError(underlying: error)
            self.lastError = purchaseError
            ErrorHandlingService.shared.handle(purchaseError, context: "PurchaseService.restorePurchases")
        }
        
        isLoading = false
    }
    
    func updateSubscriptionStatus() async {
        do {
            var hasActiveSubscription = false
            var currentSub: Product.SubscriptionInfo?
            
            for await result in Transaction.currentEntitlements {
                guard case .verified(let transaction) = result else {
                    continue
                }
                
                if transaction.productType == .autoRenewable {
                    hasActiveSubscription = true
                    
                    // Get subscription info
                    if let subscription = transaction.subscription {
                        currentSub = subscription
                    }
                }
            }
            
            self.isSubscriber = hasActiveSubscription
            self.currentSubscription = currentSub
            
            print("📱 Subscription status updated: \(hasActiveSubscription)")
        } catch {
            let purchaseError = MelodyMapError.purchaseError(underlying: error)
            ErrorHandlingService.shared.handle(purchaseError, context: "PurchaseService.updateSubscriptionStatus")
        }
    }
    
    // MARK: - Private Methods
    
    private func purchase(productID: String) async {
        guard let product = availableProducts.first(where: { $0.id == productID }) else {
            let error = MelodyMapError.purchaseError(underlying: NSError(domain: "PurchaseService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Product not found"]))
            self.lastError = error
            ErrorHandlingService.shared.handle(error, context: "PurchaseService.purchase")
            return
        }
        
        await purchase(product)
    }
    
    private func handlePurchaseSuccess(_ verification: VerificationResult<Transaction>) async {
        guard case .verified(let transaction) = verification else {
            let error = MelodyMapError.purchaseError(underlying: NSError(domain: "PurchaseService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Transaction verification failed"]))
            self.lastError = error
            ErrorHandlingService.shared.handle(error, context: "PurchaseService.handlePurchaseSuccess")
            return
        }
        
        // Update subscription status
        await updateSubscriptionStatus()
        
        // Finish the transaction
        await transaction.finish()
        
        print("✅ Purchase successful: \(transaction.productID)")
    }
    
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                guard case .verified(let transaction) = result else {
                    continue
                }
                
                // Handle transaction updates
                await self.handleTransactionUpdate(transaction)
                
                // Finish the transaction
                await transaction.finish()
            }
        }
    }
    
    private func handleTransactionUpdate(_ transaction: Transaction) async {
        await MainActor.run {
            // Update subscription status when transactions change
            Task {
                await self.updateSubscriptionStatus()
            }
        }
    }
    
    // MARK: - Helper Methods
    
    var monthlyProduct: Product? {
        availableProducts.first { $0.id == monthlySubscriptionID }
    }
    
    var yearlyProduct: Product? {
        availableProducts.first { $0.id == yearlySubscriptionID }
    }
    
    var hasProducts: Bool {
        !availableProducts.isEmpty
    }
    
    func isProductAvailable(_ productID: String) -> Bool {
        availableProducts.contains { $0.id == productID }
    }
    
    func getProduct(by id: String) -> Product? {
        availableProducts.first { $0.id == id }
    }
    
    // MARK: - Subscription Info
    
    var subscriptionStatus: String {
        if isSubscriber {
            if let subscription = currentSubscription {
                return "Active (\(subscription.status.description))"
            } else {
                return "Active"
            }
        } else {
            return "Inactive"
        }
    }
    
    var subscriptionExpiryDate: Date? {
        currentSubscription?.expirationDate
    }
    
    var isSubscriptionExpired: Bool {
        guard let expiryDate = subscriptionExpiryDate else { return true }
        return Date() > expiryDate
    }
    
    var daysUntilExpiry: Int? {
        guard let expiryDate = subscriptionExpiryDate else { return nil }
        let calendar = Calendar.current
        return calendar.dateComponents([.day], from: Date(), to: expiryDate).day
    }
}

// MARK: - Subscription Status Extension

extension Product.SubscriptionStatus {
    var description: String {
        switch self {
        case .active:
            return "Active"
        case .expired:
            return "Expired"
        case .inGracePeriod:
            return "Grace Period"
        case .revoked:
            return "Revoked"
        case .inBillingRetryPeriod:
            return "Billing Retry"
        @unknown default:
            return "Unknown"
        }
    }
}

#else
@MainActor
final class PurchaseService: ObservableObject {
    static let shared = PurchaseService()
    
    @Published var isSubscriber = false
    @Published var isLoading = false
    @Published var currentSubscription: Any?
    @Published var availableProducts: [Any] = []
    @Published var lastError: MelodyMapError?
    
    func loadProducts() async {
        // Stub implementation when subscriptions are disabled
        print("📦 Subscriptions disabled - no products loaded")
    }
    
    func purchaseMonthly() async {
        // Stub implementation when subscriptions are disabled
        print("💰 Subscriptions disabled - purchase not available")
    }
    
    func purchaseYearly() async {
        // Stub implementation when subscriptions are disabled
        print("💰 Subscriptions disabled - purchase not available")
    }
    
    func purchase(_ product: Any) async {
        // Stub implementation when subscriptions are disabled
        print("💰 Subscriptions disabled - purchase not available")
    }
    
    func restorePurchases() async {
        // Stub implementation when subscriptions are disabled
        print("💰 Subscriptions disabled - restore not available")
    }
    
    func updateSubscriptionStatus() async {
        // Stub implementation when subscriptions are disabled
        self.isSubscriber = false
    }
    
    var monthlyProduct: Any? { nil }
    var yearlyProduct: Any? { nil }
    var hasProducts: Bool { false }
    var subscriptionStatus: String { "Subscriptions Disabled" }
    var subscriptionExpiryDate: Date? { nil }
    var isSubscriptionExpired: Bool { true }
    var daysUntilExpiry: Int? { nil }
}
#endif 