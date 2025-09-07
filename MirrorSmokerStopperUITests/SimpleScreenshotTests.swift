//
//  SimpleScreenshotTests.swift
//  MirrorSmokerStopperUITests
//
//  Simple working screenshot test for immediate results
//

import XCTest

@MainActor
final class SimpleScreenshotTests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        continueAfterFailure = false
        app = XCUIApplication()
        
        // Configure for screenshot testing
        app.launchArguments = [
            "UI_TESTING",
            "SCREENSHOT_MODE",
            "-FASTLANE_SNAPSHOT", "YES",
            "-ui_testing"
        ]
        
        setupSnapshot(app)
        app.launch()
        
        // Wait for app to load
        sleep(3)
    }
    
    override func tearDownWithError() throws {
        app = nil
        try super.tearDownWithError()
    }
    
    func testAppScreenshots() throws {
        // Screenshot 1: Main screen (Today tab)
        snapshot("01-MainScreen")
        sleep(2)
        
        // Screenshot 2: Navigate to Statistics
        if app.tabBars.buttons.count > 1 {
            app.tabBars.buttons.element(boundBy: 1).tap()
            sleep(2)
            snapshot("02-Statistics")
        }
        
        // Screenshot 3: Navigate to Settings
        if app.tabBars.buttons.count > 2 {
            app.tabBars.buttons.element(boundBy: 2).tap()
            sleep(2)
            snapshot("03-Settings")
        }
        
        // Screenshot 4: Back to main screen and add button
        app.tabBars.buttons.element(boundBy: 0).tap()
        sleep(2)
        snapshot("04-MainWithAddButton")
    }
}