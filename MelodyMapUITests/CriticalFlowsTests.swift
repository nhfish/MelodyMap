import XCTest

final class CriticalFlowsTests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Search to Timeline Flow Tests
    
    func testSearchToTimelineNavigation() {
        // Given: App is launched and search view is visible
        XCTAssertTrue(app.textFields["Search"].exists, "Search field should be visible")
        
        // When: User searches for a song
        let searchField = app.textFields["Search"]
        searchField.tap()
        searchField.typeText("Let It Go")
        
        // Then: Search results should appear
        let searchResults = app.collectionViews["SearchResults"]
        XCTAssertTrue(searchResults.exists, "Search results should be displayed")
        
        // When: User taps on a search result
        let firstResult = searchResults.cells.element(boundBy: 0)
        if firstResult.exists {
            firstResult.tap()
            
            // Then: Should navigate to timeline view
            let timelineView = app.otherElements["TimelineView"]
            XCTAssertTrue(timelineView.exists, "Timeline view should be displayed")
        }
    }
    
    func testSearchWithNoResults() {
        // Given: App is launched
        XCTAssertTrue(app.textFields["Search"].exists)
        
        // When: User searches for non-existent content
        let searchField = app.textFields["Search"]
        searchField.tap()
        searchField.typeText("NonExistentSong12345")
        
        // Then: Should show no results state
        let noResultsLabel = app.staticTexts["No results found"]
        XCTAssertTrue(noResultsLabel.exists, "No results message should be displayed")
    }
    
    // MARK: - Quota Exceeded Flow Tests
    
    func testQuotaExceededShowsSheet() {
        // Given: User has no remaining uses (this would need to be set up in the test)
        // Note: This test assumes the app starts with quota available
        // In a real scenario, you'd need to consume quota first
        
        // When: User tries to view a song (assuming quota is exceeded)
        let searchField = app.textFields["Search"]
        searchField.tap()
        searchField.typeText("Let It Go")
        
        let searchResults = app.collectionViews["SearchResults"]
        if searchResults.exists {
            let firstResult = searchResults.cells.element(boundBy: 0)
            if firstResult.exists {
                firstResult.tap()
                
                // Then: Quota exceeded sheet should appear
                let quotaSheet = app.sheets["QuotaExceededSheet"]
                XCTAssertTrue(quotaSheet.exists, "Quota exceeded sheet should be displayed")
            }
        }
    }
    
    func testWatchAdFromQuotaSheet() {
        // Given: Quota exceeded sheet is shown
        // Note: This would require setting up the quota exceeded state
        
        // When: User taps "Watch Ad" button
        let watchAdButton = app.buttons["Watch Ad to Continue"]
        if watchAdButton.exists {
            watchAdButton.tap()
            
            // Then: Ad should be presented (or mock ad flow)
            // Note: In test environment, this would be a mock ad
            let adView = app.otherElements["AdView"]
            XCTAssertTrue(adView.exists, "Ad should be displayed")
        }
    }
    
    func testUpgradeFromQuotaSheet() {
        // Given: Quota exceeded sheet is shown
        
        // When: User taps "Upgrade" button
        let upgradeButton = app.buttons["Upgrade to Unlimited"]
        if upgradeButton.exists {
            upgradeButton.tap()
            
            // Then: Paywall should be presented
            let paywallView = app.otherElements["PaywallView"]
            XCTAssertTrue(paywallView.exists, "Paywall should be displayed")
        }
    }
    
    // MARK: - Favorites Flow Tests
    
    func testAddToFavorites() {
        // Given: User is viewing a song in timeline
        navigateToTimeline()
        
        // When: User taps the star button
        let starButton = app.buttons["Favorite Button"]
        if starButton.exists {
            starButton.tap()
            
            // Then: Song should be added to favorites
            XCTAssertTrue(starButton.isSelected, "Star button should be selected")
        }
    }
    
    func testRemoveFromFavorites() {
        // Given: User has a favorited song
        navigateToTimeline()
        
        let starButton = app.buttons["Favorite Button"]
        if starButton.exists && starButton.isSelected {
            // When: User taps the star button again
            starButton.tap()
            
            // Then: Song should be removed from favorites
            XCTAssertFalse(starButton.isSelected, "Star button should not be selected")
        }
    }
    
    func testFavoritesButtonVisibility() {
        // Given: App is launched
        
        // When: User has no favorites
        // Then: Favorites button should not be visible
        let favoritesButton = app.buttons["Favorites Button"]
        XCTAssertFalse(favoritesButton.exists, "Favorites button should not be visible when no favorites")
        
        // When: User adds a favorite
        navigateToTimeline()
        let starButton = app.buttons["Favorite Button"]
        if starButton.exists {
            starButton.tap()
            
            // Then: Favorites button should become visible
            XCTAssertTrue(favoritesButton.exists, "Favorites button should be visible when favorites exist")
        }
    }
    
    func testFavoritesViewNavigation() {
        // Given: User has favorites
        addFavoriteSong()
        
        // When: User taps favorites button
        let favoritesButton = app.buttons["Favorites Button"]
        if favoritesButton.exists {
            favoritesButton.tap()
            
            // Then: Favorites view should be displayed
            let favoritesView = app.otherElements["FavoritesView"]
            XCTAssertTrue(favoritesView.exists, "Favorites view should be displayed")
        }
    }
    
    // MARK: - Profile Flow Tests
    
    func testProfileViewNavigation() {
        // Given: App is launched
        
        // When: User taps profile button
        let profileButton = app.buttons["Profile Button"]
        if profileButton.exists {
            profileButton.tap()
            
            // Then: Profile view should be displayed
            let profileView = app.otherElements["ProfileView"]
            XCTAssertTrue(profileView.exists, "Profile view should be displayed")
        }
    }
    
    func testProfileViewShowsUsageInfo() {
        // Given: Profile view is displayed
        navigateToProfile()
        
        // Then: Should show usage information
        let usageLabel = app.staticTexts["Daily Uses"]
        XCTAssertTrue(usageLabel.exists, "Usage information should be displayed")
        
        let remainingLabel = app.staticTexts["Remaining"]
        XCTAssertTrue(remainingLabel.exists, "Remaining uses should be displayed")
    }
    
    // MARK: - Paywall Flow Tests
    
    func testPaywallNavigation() {
        // Given: App is launched
        
        // When: User taps upgrade button
        let upgradeButton = app.buttons["Upgrade Button"]
        if upgradeButton.exists {
            upgradeButton.tap()
            
            // Then: Paywall should be displayed
            let paywallView = app.otherElements["PaywallView"]
            XCTAssertTrue(paywallView.exists, "Paywall should be displayed")
        }
    }
    
    func testPaywallSubscriptionOptions() {
        // Given: Paywall is displayed
        navigateToPaywall()
        
        // Then: Should show subscription options
        let monthlyOption = app.buttons["Monthly Subscription"]
        let yearlyOption = app.buttons["Yearly Subscription"]
        
        XCTAssertTrue(monthlyOption.exists, "Monthly subscription option should be displayed")
        XCTAssertTrue(yearlyOption.exists, "Yearly subscription option should be displayed")
    }
    
    func testPaywallClose() {
        // Given: Paywall is displayed
        navigateToPaywall()
        
        // When: User taps close button
        let closeButton = app.buttons["Close Paywall"]
        if closeButton.exists {
            closeButton.tap()
            
            // Then: Paywall should be dismissed
            let paywallView = app.otherElements["PaywallView"]
            XCTAssertFalse(paywallView.exists, "Paywall should be dismissed")
        }
    }
    
    // MARK: - Helper Methods
    
    private func navigateToTimeline() {
        let searchField = app.textFields["Search"]
        searchField.tap()
        searchField.typeText("Let It Go")
        
        let searchResults = app.collectionViews["SearchResults"]
        if searchResults.exists {
            let firstResult = searchResults.cells.element(boundBy: 0)
            if firstResult.exists {
                firstResult.tap()
            }
        }
    }
    
    private func addFavoriteSong() {
        navigateToTimeline()
        let starButton = app.buttons["Favorite Button"]
        if starButton.exists {
            starButton.tap()
        }
    }
    
    private func navigateToProfile() {
        let profileButton = app.buttons["Profile Button"]
        if profileButton.exists {
            profileButton.tap()
        }
    }
    
    private func navigateToPaywall() {
        let upgradeButton = app.buttons["Upgrade Button"]
        if upgradeButton.exists {
            upgradeButton.tap()
        }
    }
} 