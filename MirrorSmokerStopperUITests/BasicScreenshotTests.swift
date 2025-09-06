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
        // Screenshot 1: Main screen (should be the today tab)
        snapshot("01-MainDashboard")
        sleep(2)
        
        // Try to navigate to stats tab
        let tabBars = app.tabBars
        if tabBars.buttons.count > 1 {
            tabBars.buttons.element(boundBy: 1).tap()
            sleep(2)
            snapshot("02-Statistics") 
        }
        
        // Try to navigate to settings tab
        if tabBars.buttons.count > 2 {
            tabBars.buttons.element(boundBy: 2).tap()
            sleep(2)
            snapshot("03-Settings")
        }
        
        // Go back to main tab
        if tabBars.buttons.count > 0 {
            tabBars.buttons.element(boundBy: 0).tap()
            sleep(2)
            snapshot("04-MainWithButtons")
        }
    }
}