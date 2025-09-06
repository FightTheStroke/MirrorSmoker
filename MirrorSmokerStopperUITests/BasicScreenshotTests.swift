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
        // Screenshot 1: Main Dashboard - iOS 26 ready app
        snapshot("01_MainDashboard")
        sleep(3)
        
        // Screenshot 2: Navigate to AI Coach (second tab typically)
        let tabBar = app.tabBars.firstMatch
        if tabBar.buttons.count > 1 {
            tabBar.buttons.element(boundBy: 1).tap()
            sleep(3)
            snapshot("02_AICoach")
        }
        
        // Screenshot 3: Navigate to Statistics (third tab typically)
        if tabBar.buttons.count > 2 {
            tabBar.buttons.element(boundBy: 2).tap()
            sleep(2)
            snapshot("03_Statistics")
        }
        
        // Screenshot 4: Navigate to Settings (fourth tab typically)
        if tabBar.buttons.count > 3 {
            tabBar.buttons.element(boundBy: 3).tap()
            sleep(2)
            snapshot("04_Settings")
        }
        
        // Screenshot 5: Back to main and try to trigger add cigarette
        if tabBar.buttons.count > 0 {
            tabBar.buttons.element(boundBy: 0).tap()
            sleep(2)
            
            // Try to find and tap add button
            let buttons = app.buttons.allElementsBoundByIndex
            for i in 0..<min(buttons.count, 10) {
                let button = buttons[i]
                if button.isHittable && button.label.contains("Add") || button.label.contains("+") {
                    button.tap()
                    sleep(2)
                    snapshot("05_AddCigarette")
                    
                    // Try to dismiss
                    let cancelButtons = app.buttons.allElementsBoundByIndex
                    for cancelButton in cancelButtons {
                        if cancelButton.label.contains("Cancel") || cancelButton.label.contains("Close") {
                            cancelButton.tap()
                            break
                        }
                    }
                    break
                }
            }
        }
    }
}