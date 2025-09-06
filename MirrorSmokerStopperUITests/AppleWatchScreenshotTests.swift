//
//  AppleWatchScreenshotTests.swift
//  MirrorSmokerStopperUITests
//
//  Apple Watch screenshot tests for App Store submission
//

import XCTest

@MainActor
final class AppleWatchScreenshotTests: XCTestCase {

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
        
        // Wait for Watch app to settle
        sleep(4)
    }

    override func tearDownWithError() throws {
        app = nil
        try super.tearDownWithError()
    }

    func testWatchAppScreenshots() throws {
        // Screenshot 1: Watch Main Screen - Quick smoking tracker
        snapshot("01_WatchMain")
        sleep(2)
        
        // Screenshot 2: Watch Add Cigarette - Easy tracking
        let addButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Add' OR label CONTAINS[c] 'Plus' OR label CONTAINS[c] '+'")).firstMatch
        if addButton.exists {
            addButton.tap()
            sleep(2)
            snapshot("02_WatchAddCigarette")
            
            // Dismiss or confirm
            let confirmButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Confirm' OR label CONTAINS[c] 'Done' OR label CONTAINS[c] 'Save'")).firstMatch
            if confirmButton.exists {
                confirmButton.tap()
                sleep(1)
            }
        }
        
        // Screenshot 3: Watch Progress - Daily statistics  
        let progressButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Progress' OR label CONTAINS[c] 'Stats' OR label CONTAINS[c] 'Chart'")).firstMatch
        if progressButton.exists {
            progressButton.tap()
            sleep(2)
            snapshot("03_WatchProgress")
        }
        
        // Screenshot 4: Watch Complications - Home screen widget
        let digitalCrown = XCUIDevice.shared
        digitalCrown.press(.home)
        sleep(3)
        snapshot("04_WatchComplications")
        
        // Screenshot 5: Watch Notifications - Motivation alerts
        let notificationCenter = app.swipeDown()
        sleep(2)
        snapshot("05_WatchNotifications")
    }
}