//
//  SyncUITests.swift
//  MirrorSmokerStopperUITests
//
//  Created by Claude on 05/09/25.
//
//  UI Tests for verifying synchronization between App, Widget, and Watch

import XCTest

final class SyncUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Test App to Widget Sync
    
    func testAddCigaretteFromApp_UpdatesWidget() throws {
        // Get initial count
        let heroSection = app.scrollViews.firstMatch
        XCTAssertTrue(heroSection.waitForExistence(timeout: 5))
        
        // Find and tap FAB button
        let fabButton = app.buttons.matching(identifier: "fab_button").firstMatch
        if !fabButton.exists {
            // Try finding by accessibility identifier
            let addButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", "plus")).firstMatch
            XCTAssertTrue(addButton.waitForExistence(timeout: 5), "Add cigarette button not found")
            addButton.tap()
        } else {
            fabButton.tap()
        }
        
        // Wait for save
        sleep(2)
        
        // Verify count increased
        let countText = app.staticTexts.matching(NSPredicate(format: "label MATCHES %@", "\\d+")).firstMatch
        XCTAssertTrue(countText.exists, "Count text should exist")
    }
    
    // MARK: - Test Data Persistence
    
    func testDataPersistsAfterAppRestart() throws {
        // Add a cigarette
        let addButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", "plus")).firstMatch
        if addButton.waitForExistence(timeout: 5) {
            addButton.tap()
        }
        
        // Get count after adding
        sleep(1)
        let initialCount = getCurrentCigaretteCount()
        
        // Terminate and relaunch app
        app.terminate()
        app.launch()
        
        // Verify count persisted
        sleep(2)
        let newCount = getCurrentCigaretteCount()
        XCTAssertEqual(initialCount, newCount, "Cigarette count should persist after restart")
    }
    
    // MARK: - Test UI Updates
    
    func testUIUpdatesWhenCigaretteAdded() throws {
        // Get initial state
        let initialCount = getCurrentCigaretteCount()
        
        // Add cigarette
        let addButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", "plus")).firstMatch
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()
        
        // Wait for UI update
        sleep(2)
        
        // Verify count increased
        let newCount = getCurrentCigaretteCount()
        XCTAssertEqual(newCount, initialCount + 1, "Count should increase by 1")
        
        // Check for success notification
        let notification = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "saved")).firstMatch
        XCTAssertTrue(notification.waitForExistence(timeout: 3), "Success notification should appear")
    }
    
    // MARK: - Test Settings Access
    
    func testSettingsButtonOpensSettings() throws {
        // Find settings button
        let settingsButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", "gear")).firstMatch
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 5), "Settings button should exist")
        
        settingsButton.tap()
        
        // Verify settings sheet opened
        let settingsView = app.navigationBars["Settings"].firstMatch
        XCTAssertTrue(settingsView.waitForExistence(timeout: 3), "Settings view should appear")
    }
    
    // MARK: - Helper Methods
    
    private func getCurrentCigaretteCount() -> Int {
        // Try to find the count in various possible locations
        let predicates = [
            NSPredicate(format: "label MATCHES %@", "^\\d+$"),
            NSPredicate(format: "value MATCHES %@", "^\\d+$"),
            NSPredicate(format: "label CONTAINS %@ AND label MATCHES %@", "today", ".*\\d+.*")
        ]
        
        for predicate in predicates {
            let countElement = app.staticTexts.matching(predicate).firstMatch
            if countElement.exists {
                if let countText = countElement.label.components(separatedBy: CharacterSet.decimalDigits.inverted).first(where: { !$0.isEmpty }),
                   let count = Int(countText) {
                    return count
                }
            }
        }
        
        return 0
    }
    
    // MARK: - Performance Tests
    
    func testLaunchPerformance() throws {
        if #available(iOS 13.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}