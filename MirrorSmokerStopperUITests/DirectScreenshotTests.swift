//
//  DirectScreenshotTests.swift
//  MirrorSmokerStopperUITests
//
//  Direct screenshot test without fastlane
//

import XCTest

@MainActor
final class DirectScreenshotTests: XCTestCase {

    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING", "SCREENSHOT_MODE"]
        app.launch()
        
        // Wait for app to settle
        sleep(3)
    }

    override func tearDownWithError() throws {
        app = nil
        try super.tearDownWithError()
    }

    func testTakeDirectScreenshots() throws {
        // Take screenshot using XCTest native method
        let screenshot1 = app.screenshot()
        let attachment1 = XCTAttachment(screenshot: screenshot1)
        attachment1.name = "01_MainDashboard"
        attachment1.lifetime = .keepAlways
        add(attachment1)
        
        sleep(3)
        
        // Try to navigate
        let tabBar = app.tabBars.firstMatch
        if tabBar.exists && tabBar.buttons.count > 1 {
            tabBar.buttons.element(boundBy: 1).tap()
            sleep(2)
            
            let screenshot2 = app.screenshot()
            let attachment2 = XCTAttachment(screenshot: screenshot2)
            attachment2.name = "02_SecondTab"
            attachment2.lifetime = .keepAlways
            add(attachment2)
        }
        
        // Take final screenshot
        let screenshotFinal = app.screenshot()
        let attachmentFinal = XCTAttachment(screenshot: screenshotFinal)
        attachmentFinal.name = "03_FinalView"
        attachmentFinal.lifetime = .keepAlways
        add(attachmentFinal)
    }
}