import XCTest

final class AccessibilityTests: XCTestCase {
    func testMainViewsHaveAccessibilityLabels() {
        let app = XCUIApplication()
        app.launch()
        
        // Check for main search bar accessibility
        let searchField = app.textFields["Search"]
        XCTAssertTrue(searchField.exists, "Search field should exist and be accessible.")
        
        // Check for timeline view accessibility
        let timeline = app.otherElements["TimelineView"]
        XCTAssertTrue(timeline.exists, "TimelineView should be accessible.")
        
        // Check for song detail accessibility
        let songDetail = app.otherElements["SongDetailView"]
        XCTAssertTrue(songDetail.exists, "SongDetailView should be accessible.")
    }
    
    func testDynamicTypeSupport() {
        let app = XCUIApplication()
        app.launchArguments.append("-UIPreferredContentSizeCategoryName")
        app.launchArguments.append("UICTContentSizeCategoryAccessibilityExtraExtraExtraLarge")
        app.launch()
        
        // Check that the search field still exists and is visible
        let searchField = app.textFields["Search"]
        XCTAssertTrue(searchField.exists, "Search field should exist with large text size.")
    }
} 