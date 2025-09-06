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
        // Screenshot 1: Main Dashboard - always take this first
        snapshot("01_MainDashboard")
        sleep(5)
        
        // Screenshot 2: Try to find tabs and navigate
        let tabBar = app.tabBars.firstMatch
        if tabBar.exists && tabBar.buttons.count > 1 {
            tabBar.buttons.element(boundBy: 1).tap()
            sleep(3)
            snapshot("02_SecondTab")
        } else {
            // If no tabs, just take another screenshot
            snapshot("02_MainView")
        }
        
        // Screenshot 3: Try third tab or just take current view
        if tabBar.exists && tabBar.buttons.count > 2 {
            tabBar.buttons.element(boundBy: 2).tap()
            sleep(3)
            snapshot("03_ThirdTab")
        } else {
            snapshot("03_CurrentView")
        }
        
        // Screenshot 4: Try fourth tab or settings
        if tabBar.exists && tabBar.buttons.count > 3 {
            tabBar.buttons.element(boundBy: 3).tap()
            sleep(3)
            snapshot("04_FourthTab")
        } else {
            // Try to find any settings or menu
            let buttons = app.buttons.allElementsBoundByIndex
            if !buttons.isEmpty {
                let lastButton = buttons[buttons.count - 1]
                if lastButton.isHittable {
                    lastButton.tap()
                    sleep(2)
                    snapshot("04_LastButton")
                }
            } else {
                snapshot("04_NoButtons")
            }
        }
        
        // Screenshot 5: Final screenshot
        snapshot("05_FinalView")
    }
}