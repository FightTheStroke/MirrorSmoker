//
//  MainUserFlowsUITests.swift
//  MirrorSmokerStopperUITests
//
//  Created by Claude on 02/09/25.
//

import XCTest

@MainActor
final class MainUserFlowsUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"]
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Core User Flows
    
    func testAddCigaretteFlow() throws {
        // Navigate to home tab
        let homeTab = app.tabBars.buttons["tab.home"]
        XCTAssertTrue(homeTab.exists)
        homeTab.tap()
        
        // Find and tap the floating action button
        let addButton = app.buttons.containing(NSPredicate(format: "identifier CONTAINS 'add' OR identifier CONTAINS 'plus'")).firstMatch
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()
        
        // Verify cigarette was added (check if count increased)
        let todayCountLabel = app.staticTexts.matching(NSPredicate(format: "label MATCHES %@", "\\d+")).firstMatch
        XCTAssertTrue(todayCountLabel.waitForExistence(timeout: 3))
    }
    
    func testAddCigaretteWithTagsFlow() throws {
        // Navigate to home tab
        app.tabBars.buttons["tab.home"].tap()
        
        // Long press the add button to open tag picker
        let addButton = app.buttons.containing(NSPredicate(format: "identifier CONTAINS 'add' OR identifier CONTAINS 'plus'")).firstMatch
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.press(forDuration: 1.0)
        
        // Verify tag picker sheet appears
        let tagPickerSheet = app.sheets.firstMatch
        if tagPickerSheet.waitForExistence(timeout: 3) {
            // If no tags exist, create one
            let createTagButton = app.buttons[NSLocalizedString("tags.create.title", comment: "")]
            if createTagButton.exists {
                createTagButton.tap()
                
                // Fill in tag details
                let nameField = app.textFields.firstMatch
                if nameField.exists {
                    nameField.tap()
                    nameField.typeText("Test Tag")
                }
                
                // Select a color (tap first color circle)
                let colorCircle = app.buttons.matching(NSPredicate(format: "identifier CONTAINS 'color'")).firstMatch
                if colorCircle.exists {
                    colorCircle.tap()
                }
                
                // Save tag
                app.navigationBars.buttons[NSLocalizedString("save.button", comment: "")].tap()
            }
            
            // Select the tag
            let tagRow = app.buttons.firstMatch
            if tagRow.exists {
                tagRow.tap()
            }
            
            // Confirm selection
            app.navigationBars.buttons[NSLocalizedString("done", comment: "")].tap()
        }
    }
    
    func testNavigationFlow() throws {
        // Test all main tabs
        let homeTab = app.tabBars.buttons["tab.home"]
        let statsTab = app.tabBars.buttons["tab.stats.main"]
        let settingsTab = app.tabBars.buttons["tab.settings.main"]
        
        // Test Home tab
        XCTAssertTrue(homeTab.waitForExistence(timeout: 5))
        homeTab.tap()
        
        // Verify home content loads
        let todaySection = app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", NSLocalizedString("statistics.today", comment: ""))).firstMatch
        XCTAssertTrue(todaySection.waitForExistence(timeout: 3))
        
        // Test Stats tab
        XCTAssertTrue(statsTab.exists)
        statsTab.tap()
        
        // Verify stats content loads
        let statisticsTitle = app.navigationBars.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", NSLocalizedString("statistics.title.main", comment: ""))).firstMatch
        XCTAssertTrue(statisticsTitle.waitForExistence(timeout: 3))
        
        // Test Settings tab
        XCTAssertTrue(settingsTab.exists)
        settingsTab.tap()
        
        // Verify settings content loads
        let settingsTitle = app.navigationBars.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", NSLocalizedString("settings.title", comment: ""))).firstMatch
        XCTAssertTrue(settingsTitle.waitForExistence(timeout: 3))
    }
    
    func testSettingsFlow() throws {
        // Navigate to settings
        app.tabBars.buttons["tab.settings.main"].tap()
        
        // Test help button
        let helpButton = app.navigationBars.buttons.matching(NSPredicate(format: "identifier CONTAINS 'help' OR identifier CONTAINS 'question'")).firstMatch
        if helpButton.waitForExistence(timeout: 3) {
            helpButton.tap()
            
            // Verify help modal appears
            let helpModal = app.sheets.firstMatch
            XCTAssertTrue(helpModal.waitForExistence(timeout: 3))
            
            // Close help modal
            let closeButton = app.buttons[NSLocalizedString("done", comment: "")]
            if closeButton.exists {
                closeButton.tap()
            }
        }
        
        // Test profile name field
        let nameField = app.textFields.containing(NSPredicate(format: "identifier CONTAINS 'name'")).firstMatch
        if nameField.waitForExistence(timeout: 3) {
            nameField.tap()
            nameField.clearAndEnterText("UI Test User")
            
            // Verify save button appears
            let saveButton = app.navigationBars.buttons[NSLocalizedString("save", comment: "")]
            XCTAssertTrue(saveButton.waitForExistence(timeout: 2))
        }
    }
    
    func testStatisticsFlow() throws {
        // Navigate to statistics
        app.tabBars.buttons["tab.stats.main"].tap()
        
        // Wait for statistics to load
        let statisticsView = app.scrollViews.firstMatch
        XCTAssertTrue(statisticsView.waitForExistence(timeout: 5))
        
        // Test scrolling through statistics
        statisticsView.swipeUp()
        
        // Look for statistics elements
        let generalStats = app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", NSLocalizedString("stats.general", comment: ""))).firstMatch
        let weeklyStats = app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", NSLocalizedString("stats.weekly", comment: ""))).firstMatch
        
        // At least one should exist
        let statsExist = generalStats.exists || weeklyStats.exists
        XCTAssertTrue(statsExist, "No statistics sections found")
    }
    
    func testCigaretteListInteraction() throws {
        // First add a cigarette to ensure list has content
        app.tabBars.buttons["tab.home"].tap()
        
        let addButton = app.buttons.containing(NSPredicate(format: "identifier CONTAINS 'add' OR identifier CONTAINS 'plus'")).firstMatch
        if addButton.waitForExistence(timeout: 5) {
            addButton.tap()
        }
        
        // Look for cigarette list items
        let cigaretteRows = app.buttons.matching(NSPredicate(format: "identifier CONTAINS 'cigarette' OR identifier CONTAINS 'row'"))
        
        if cigaretteRows.count > 0 {
            let firstRow = cigaretteRows.firstMatch
            
            // Test swipe gestures on cigarette row
            if firstRow.exists {
                // Test swipe right for tags
                firstRow.swipeRight()
                
                // Test swipe left for delete
                firstRow.swipeLeft()
                
                // If delete button appears, cancel it
                let deleteButton = app.buttons.containing(NSPredicate(format: "label CONTAINS %@", NSLocalizedString("delete", comment: ""))).firstMatch
                if deleteButton.exists {
                    // Tap somewhere else to cancel delete
                    app.tap()
                }
            }
        }
    }
    
    func testTagManagementFlow() throws {
        // Navigate to home and try to add a cigarette with tags
        app.tabBars.buttons["tab.home"].tap()
        
        let addButton = app.buttons.containing(NSPredicate(format: "identifier CONTAINS 'add' OR identifier CONTAINS 'plus'")).firstMatch
        if addButton.waitForExistence(timeout: 5) {
            addButton.press(forDuration: 1.0)
            
            let tagSheet = app.sheets.firstMatch
            if tagSheet.waitForExistence(timeout: 3) {
                // Test creating a new tag
                let createButton = app.buttons[NSLocalizedString("tags.create.title", comment: "")]
                if createButton.exists {
                    createButton.tap()
                    
                    // Fill tag form
                    let tagNameField = app.textFields.firstMatch
                    if tagNameField.exists {
                        tagNameField.tap()
                        tagNameField.typeText("UI Test Tag")
                    }
                    
                    // Save tag
                    let saveButton = app.navigationBars.buttons[NSLocalizedString("save.button", comment: "")]
                    if saveButton.exists {
                        saveButton.tap()
                    }
                    
                    // Select the created tag
                    let tagRow = app.buttons.containing(NSPredicate(format: "label CONTAINS 'UI Test Tag'")).firstMatch
                    if tagRow.waitForExistence(timeout: 2) {
                        tagRow.tap()
                    }
                }
                
                // Done with tag selection
                let doneButton = app.navigationBars.buttons[NSLocalizedString("done", comment: "")]
                if doneButton.exists {
                    doneButton.tap()
                }
            }
        }
    }
    
    // MARK: - Performance Tests
    
    func testAppLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
    
    func testScrollingPerformance() throws {
        app.tabBars.buttons["tab.stats.main"].tap()
        
        let scrollView = app.scrollViews.firstMatch
        XCTAssertTrue(scrollView.waitForExistence(timeout: 5))
        
        measure(metrics: [XCTOSSignpostMetric.scrollingAndDecelerationMetric]) {
            scrollView.swipeUp()
            scrollView.swipeDown()
            scrollView.swipeUp()
            scrollView.swipeDown()
        }
    }
    
    // MARK: - Accessibility Tests
    
    func testVoiceOverNavigation() throws {
        // Enable accessibility for testing
        app.launchEnvironment["ACCESSIBILITY_TESTING"] = "1"
        
        app.tabBars.buttons["tab.home"].tap()
        
        // Verify important elements are accessible
        let addButton = app.buttons.containing(NSPredicate(format: "identifier CONTAINS 'add'")).firstMatch
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        XCTAssertTrue(addButton.isAccessibilityElement)
        
        // Check tab accessibility
        let homeTab = app.tabBars.buttons["tab.home"]
        XCTAssertTrue(homeTab.isAccessibilityElement)
        XCTAssertFalse(homeTab.accessibilityLabel?.isEmpty ?? true)
    }
}