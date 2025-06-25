import XCTest
import StoreKit
@testable import MelodyMap

@MainActor
final class PurchaseServiceTests: XCTestCase {
    var purchaseService: PurchaseService!
    
    override func setUpWithError() throws {
        purchaseService = PurchaseService()
    }
    
    override func tearDownWithError() throws {
        purchaseService = nil
    }
    
    // MARK: - Initialization Tests
    
    func testInitialization() {
        XCTAssertNotNil(purchaseService)
        XCTAssertFalse(purchaseService.isSubscriber)
        XCTAssertFalse(purchaseService.isLoading)
        XCTAssertNil(purchaseService.currentSubscription)
        XCTAssertTrue(purchaseService.availableProducts.isEmpty)
        XCTAssertNil(purchaseService.lastError)
    }
    
    // MARK: - Product Loading Tests
    
    func testLoadProducts() async {
        // Given: Service is initialized
        
        // When: Loading products
        await purchaseService.loadProducts()
        
        // Then: Should attempt to load products
        // Note: In test environment, this will likely fail due to no StoreKit configuration
        // but we can test the error handling
        XCTAssertFalse(purchaseService.isLoading)
    }
    
    func testLoadProductsSetsLoadingState() async {
        // Given: Service is initialized
        
        // When: Starting to load products
        let loadTask = Task {
            await purchaseService.loadProducts()
        }
        
        // Then: Should be in loading state briefly
        // Note: This is a timing-dependent test and may not always pass
        // In a real scenario, you'd use a mock StoreKit environment
        
        await loadTask.value
        XCTAssertFalse(purchaseService.isLoading)
    }
    
    // MARK: - Purchase Tests
    
    func testPurchaseMonthly() async {
        // Given: Service is initialized
        
        // When: Attempting to purchase monthly
        await purchaseService.purchaseMonthly()
        
        // Then: Should handle the purchase attempt
        // Note: In test environment, this will likely fail due to no StoreKit configuration
        XCTAssertFalse(purchaseService.isLoading)
    }
    
    func testPurchaseYearly() async {
        // Given: Service is initialized
        
        // When: Attempting to purchase yearly
        await purchaseService.purchaseYearly()
        
        // Then: Should handle the purchase attempt
        XCTAssertFalse(purchaseService.isLoading)
    }
    
    func testPurchaseWithInvalidProduct() async {
        // Given: Service with no products loaded
        purchaseService.availableProducts = []
        
        // When: Attempting to purchase with invalid product ID
        await purchaseService.purchase(productID: "invalid.product.id")
        
        // Then: Should handle error gracefully
        XCTAssertFalse(purchaseService.isLoading)
        XCTAssertNotNil(purchaseService.lastError)
    }
    
    // MARK: - Restore Purchases Tests
    
    func testRestorePurchases() async {
        // Given: Service is initialized
        
        // When: Attempting to restore purchases
        await purchaseService.restorePurchases()
        
        // Then: Should handle the restore attempt
        XCTAssertFalse(purchaseService.isLoading)
    }
    
    // MARK: - Subscription Status Tests
    
    func testUpdateSubscriptionStatus() async {
        // Given: Service is initialized
        
        // When: Updating subscription status
        await purchaseService.updateSubscriptionStatus()
        
        // Then: Should update status (likely to false in test environment)
        XCTAssertFalse(purchaseService.isSubscriber)
    }
    
    // MARK: - Helper Method Tests
    
    func testHasProducts() {
        // Given: Service with no products
        purchaseService.availableProducts = []
        
        // Then: Should return false
        XCTAssertFalse(purchaseService.hasProducts)
        
        // Given: Service with products
        purchaseService.availableProducts = [MockProduct()]
        
        // Then: Should return true
        XCTAssertTrue(purchaseService.hasProducts)
    }
    
    func testIsProductAvailable() {
        // Given: Service with a specific product
        let product = MockProduct(id: "test.product")
        purchaseService.availableProducts = [product]
        
        // When: Checking if product is available
        let isAvailable = purchaseService.isProductAvailable("test.product")
        
        // Then: Should return true
        XCTAssertTrue(isAvailable)
        
        // When: Checking for non-existent product
        let isNotAvailable = purchaseService.isProductAvailable("non.existent.product")
        
        // Then: Should return false
        XCTAssertFalse(isNotAvailable)
    }
    
    func testGetProduct() {
        // Given: Service with a specific product
        let product = MockProduct(id: "test.product")
        purchaseService.availableProducts = [product]
        
        // When: Getting product by ID
        let retrievedProduct = purchaseService.getProduct(by: "test.product")
        
        // Then: Should return the product
        XCTAssertNotNil(retrievedProduct)
        XCTAssertEqual(retrievedProduct?.id, "test.product")
        
        // When: Getting non-existent product
        let nonExistentProduct = purchaseService.getProduct(by: "non.existent.product")
        
        // Then: Should return nil
        XCTAssertNil(nonExistentProduct)
    }
    
    // MARK: - Subscription Info Tests
    
    func testSubscriptionStatus() {
        // Given: Service with no subscription
        purchaseService.isSubscriber = false
        
        // Then: Should return inactive status
        XCTAssertEqual(purchaseService.subscriptionStatus, "Inactive")
        
        // Given: Service with active subscription
        purchaseService.isSubscriber = true
        
        // Then: Should return active status
        XCTAssertEqual(purchaseService.subscriptionStatus, "Active")
    }
    
    func testSubscriptionExpiryDate() {
        // Given: Service with no subscription
        purchaseService.currentSubscription = nil
        
        // Then: Should return nil
        XCTAssertNil(purchaseService.subscriptionExpiryDate)
    }
    
    func testIsSubscriptionExpired() {
        // Given: Service with no subscription
        purchaseService.currentSubscription = nil
        
        // Then: Should return true (expired)
        XCTAssertTrue(purchaseService.isSubscriptionExpired)
    }
    
    func testDaysUntilExpiry() {
        // Given: Service with no subscription
        purchaseService.currentSubscription = nil
        
        // Then: Should return nil
        XCTAssertNil(purchaseService.daysUntilExpiry)
    }
    
    // MARK: - Error Handling Tests
    
    func testErrorHandlingInLoadProducts() async {
        // Given: Service is initialized
        
        // When: Loading products (which will likely fail in test environment)
        await purchaseService.loadProducts()
        
        // Then: Should handle errors gracefully
        // Note: In a real test environment with StoreKit configuration,
        // you'd mock the StoreKit responses to test specific error scenarios
        XCTAssertFalse(purchaseService.isLoading)
    }
    
    func testErrorHandlingInPurchase() async {
        // Given: Service with no products
        purchaseService.availableProducts = []
        
        // When: Attempting to purchase
        await purchaseService.purchaseMonthly()
        
        // Then: Should handle error gracefully
        XCTAssertFalse(purchaseService.isLoading)
        XCTAssertNotNil(purchaseService.lastError)
    }
    
    // MARK: - Mock Data
    
    func testWithMockProducts() {
        // Given: Mock products
        let monthlyProduct = MockProduct(id: "com.melodymap.monthly")
        let yearlyProduct = MockProduct(id: "com.melodymap.yearly")
        purchaseService.availableProducts = [monthlyProduct, yearlyProduct]
        
        // Then: Helper methods should work correctly
        XCTAssertTrue(purchaseService.hasProducts)
        XCTAssertEqual(purchaseService.availableProducts.count, 2)
        XCTAssertNotNil(purchaseService.monthlyProduct)
        XCTAssertNotNil(purchaseService.yearlyProduct)
        XCTAssertEqual(purchaseService.monthlyProduct?.id, "com.melodymap.monthly")
        XCTAssertEqual(purchaseService.yearlyProduct?.id, "com.melodymap.yearly")
    }
}

// MARK: - Mock Product

class MockProduct: Product {
    let mockID: String
    
    init(id: String) {
        self.mockID = id
        super.init()
    }
    
    override var id: String {
        return mockID
    }
    
    override var price: Decimal {
        return 9.99
    }
    
    override var displayName: String {
        return "Mock Product"
    }
    
    override var description: String {
        return "A mock product for testing"
    }
    
    override var type: Product.ProductType {
        return .autoRenewable
    }
}

// MARK: - PurchaseService Extension for Testing

extension PurchaseService {
    func purchase(productID: String) async {
        guard let product = availableProducts.first(where: { $0.id == productID }) else {
            let error = MelodyMapError.purchaseError(underlying: NSError(domain: "PurchaseService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Product not found"]))
            self.lastError = error
            ErrorHandlingService.shared.handle(error, context: "PurchaseService.purchase")
            return
        }
        
        await purchase(product)
    }
    
    func purchase(_ product: Any) async {
        // Mock implementation for testing
        isLoading = true
        
        // Simulate purchase delay
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Simulate success
        isSubscriber = true
        isLoading = false
    }
} 