//
//  BasicScreenshotTests.swift
//  MirrorSmokerStopperUITests
//
//  Working screenshot test for App Store submission
//

import XCTest

@MainActor
final class BasicScreenshotTests: XCTestCase {

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
        
        // Wait for app to settle
        sleep(3)
    }

    override func tearDownWithError() throws {
        app = nil
        try super.tearDownWithError()
    }

    func testAppScreenshots() throws {
        print("🎯 Starting ACTUAL app screenshots with proper navigation...")
        
        // Screenshot 1: Main Dashboard (ContentView - today's cigarette count, AI coach)
        snapshot("01_MainDashboard")
        sleep(2)
        
        // Navigate through tabs using tab bar
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 10), "Tab bar should exist")
        
        let tabButtons = tabBar.buttons.allElementsBoundByIndex
        print("📱 Found \(tabButtons.count) tab buttons")
        
        // Print all tab button details for debugging
        for (index, button) in tabButtons.enumerated() {
            print("📋 Tab \(index): label='\(button.label)', identifier='\(button.identifier)', exists=\(button.exists), hittable=\(button.isHittable)")
        }
        
        // Screenshot 2: Statistics View (EnhancedStatisticsView)
        if tabButtons.count > 1 {
            print("🧭 Tapping Statistics tab (button 1)...")
            let statsButton = tabButtons[1]
            if statsButton.exists && statsButton.isHittable {
                statsButton.tap()
                sleep(3) // Wait for data to load
                print("📊 Statistics tab tapped successfully")
            } else {
                print("⚠️ Statistics tab button not hittable")
            }
            snapshot("02_Statistics")
        } else {
            print("⚠️ No Statistics tab found")
            snapshot("02_MainView")
        }
        
        // Screenshot 3: Settings View
        if tabButtons.count > 2 {
            print("🧭 Tapping Settings tab (button 2)...")
            let settingsButton = tabButtons[2]
            if settingsButton.exists && settingsButton.isHittable {
                settingsButton.tap()
                sleep(2) // Less time for settings
                print("⚙️ Settings tab tapped successfully")
            } else {
                print("⚠️ Settings tab button not hittable")
            }
            snapshot("03_Settings")
        } else {
            print("⚠️ No Settings tab found")
            snapshot("03_MainView2")
        }
        
        // Go back to main tab for Add Cigarette attempt
        if tabButtons.count > 0 {
            print("🧭 Back to main tab (button 0)...")
            tabButtons[0].tap()
            sleep(2)
        }
        
        // Screenshot 4: Try to trigger Add Cigarette modal/sheet
        var addTriggered = false
        
        // Look for floating action button or any add button
        let allButtons = app.buttons.allElementsBoundByIndex
        print("🔍 Checking \(allButtons.count) buttons for add functionality...")
        
        // Try to find buttons that might be the FAB or add button
        for (index, button) in allButtons.enumerated() {
            if button.isHittable && button.exists {
                let label = button.label.lowercased()
                let identifier = button.identifier.lowercased()
                
                // Look for buttons with add-related text or symbols
                if label.contains("+") || label.contains("add") || label.contains("plus") ||
                   identifier.contains("fab") || identifier.contains("add") || identifier.contains("floating") {
                    print("🎯 Found potential add button [\(index)]: '\(label)' id: '\(identifier)'")
                    button.tap()
                    sleep(2)
                    addTriggered = true
                    break
                }
            }
        }
        
        // If no specific add button found, try the last visible button (often FAB)
        if !addTriggered && !allButtons.isEmpty {
            let lastButton = allButtons.last!
            if lastButton.isHittable {
                print("🎯 Trying last button as potential FAB...")
                lastButton.tap()
                sleep(2)
                addTriggered = true
            }
        }
        
        snapshot("04_AddCigarette")
        
        // Try to dismiss any modal that opened
        if addTriggered {
            // Look for cancel/done/close buttons
            let dismissButtons = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'cancel' OR label CONTAINS[c] 'done' OR label CONTAINS[c] 'close'"))
            if dismissButtons.count > 0 {
                dismissButtons.firstMatch.tap()
                sleep(1)
            } else {
                // Try swipe down to dismiss
                app.swipeDown()
                sleep(1)
            }
        }
        
        // Screenshot 5: Final clean main view (App Interface)
        if tabButtons.count > 0 {
            tabButtons[0].tap()
            sleep(2)
        }
        snapshot("05_AppInterface")
        
        print("✅ Completed all app screenshots with proper navigation")
    }
}