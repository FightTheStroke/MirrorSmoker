//
//  ActualAppScreenshotTests.swift
//  MirrorSmokerStopperUITests
//
//  REAL screenshot test that captures ALL app views correctly
//

import XCTest

@MainActor
final class ActualAppScreenshotTests: XCTestCase {

    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launchArguments = [
            "UI_TESTING",
            "SCREENSHOT_MODE", 
            "-FASTLANE_SNAPSHOT", "YES"
        ]
        
        setupSnapshot(app)
        app.launch()
        
        // Wait for app to fully load
        sleep(4)
    }

    override func tearDownWithError() throws {
        app = nil
        try super.tearDownWithError()
    }

    func testActualAppScreenshots() throws {
        print("🎯 Starting ACTUAL app screenshots...")
        
        // Screenshot 1: Main Dashboard (ContentView)
        // This is the initial view with today's cigarette count, quick stats, AI coach tip
        snapshot("01_MainDashboard")
        sleep(2)
        
        // Navigate through all tabs using tab bar
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5), "Tab bar should exist")
        
        let tabButtons = tabBar.buttons.allElementsBoundByIndex
        print("📱 Found \(tabButtons.count) tab buttons")
        
        // Screenshot 2: Statistics View (EnhancedStatisticsView)
        if tabButtons.count > 1 {
            print("🧭 Navigating to Statistics tab...")
            tabButtons[1].tap()
            sleep(3)
            snapshot("02_Statistics")
        } else {
            snapshot("02_NoStatistics")
        }
        
        // Screenshot 3: Settings View 
        if tabButtons.count > 2 {
            print("🧭 Navigating to Settings tab...")
            tabButtons[2].tap()
            sleep(3)
            snapshot("03_Settings")
        } else {
            snapshot("03_NoSettings")
        }
        
        // Go back to main tab for Add Cigarette flow
        if tabButtons.count > 0 {
            print("🧭 Back to main tab...")
            tabButtons[0].tap()
            sleep(2)
        }
        
        // Screenshot 4: Try to trigger Add Cigarette modal
        // Look for the floating action button or any add button
        var addCigaretteTriggered = false
        
        // Method 1: Try to find floating action button by accessibility
        let fabButton = app.buttons.matching(NSPredicate(format: "identifier CONTAINS 'fab' OR identifier CONTAINS 'floating' OR identifier CONTAINS 'add'")).firstMatch
        if fabButton.exists && fabButton.isHittable {
            print("🎯 Found FAB button, tapping...")
            fabButton.tap()
            sleep(2)
            addCigaretteTriggered = true
        } else {
            // Method 2: Look for any button with "+" or "add" in label
            let addButtons = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'add' OR label CONTAINS[c] '+' OR label CONTAINS[c] 'plus'"))
            if addButtons.count > 0 {
                let addButton = addButtons.firstMatch
                if addButton.exists && addButton.isHittable {
                    print("🎯 Found add button, tapping...")
                    addButton.tap()
                    sleep(2)
                    addCigaretteTriggered = true
                }
            }
        }
        
        if addCigaretteTriggered {
            snapshot("04_AddCigarette")
            
            // Try to dismiss the modal/sheet
            let dismissButtons = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'cancel' OR label CONTAINS[c] 'done' OR label CONTAINS[c] 'close' OR label CONTAINS[c] 'back'"))
            if dismissButtons.count > 0 {
                let dismissButton = dismissButtons.firstMatch
                if dismissButton.exists && dismissButton.isHittable {
                    dismissButton.tap()
                    sleep(1)
                }
            } else {
                // Try escape key or swipe down to dismiss
                app.swipeDown()
                sleep(1)
            }
        } else {
            print("⚠️ Could not find add cigarette button")
            snapshot("04_NoAddButton")
        }
        
        // Screenshot 5: App Interface (final clean main view)
        // Make sure we're on the main tab
        if tabButtons.count > 0 {
            tabButtons[0].tap()
            sleep(2)
        }
        snapshot("05_AppInterface")
        
        print("✅ Completed all app screenshots")
    }
    
    func testQuickSingleScreenshots() throws {
        // Minimal test for just the main views
        print("🎯 Quick screenshot test...")
        
        snapshot("01_MainDashboard")
        
        let tabBar = app.tabBars.firstMatch
        if tabBar.exists {
            let buttons = tabBar.buttons.allElementsBoundByIndex
            
            if buttons.count > 1 {
                buttons[1].tap()
                sleep(2)
                snapshot("02_Statistics") 
            }
            
            if buttons.count > 2 {
                buttons[2].tap()
                sleep(2)
                snapshot("03_Settings")
            }
        }
        
        print("✅ Quick screenshots completed")
    }
}