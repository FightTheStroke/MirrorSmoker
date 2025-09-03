//
//  MirrorSmokerStopperUITests.swift
//  MirrorSmokerStopperUITests
//
//  Created by Roberto D'Angelo on 01/09/25.
//

import XCTest

final class MirrorSmokerStopperUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it's important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testBasicAppLaunch() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"]
        app.launch()
        
        // Verify main interface elements exist
        let homeTab = app.tabBars.buttons.element(boundBy: 0)
        XCTAssertTrue(homeTab.waitForExistence(timeout: 10))
        
        // Verify app doesn't crash on launch
        XCTAssertTrue(app.state == .runningForeground)
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            let app = XCUIApplication()
            app.launchArguments = ["UI_TESTING"]
            app.launch()
        }
    }
    
    @MainActor
    func testMemoryUsage() throws {
        // Test memory usage during typical operations
        let app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"]
        
        measure(metrics: [XCTMemoryMetric()]) {
            app.launch()
            
            // Navigate through main tabs
            if app.tabBars.buttons.count >= 3 {
                app.tabBars.buttons.element(boundBy: 0).tap()
                app.tabBars.buttons.element(boundBy: 1).tap()
                app.tabBars.buttons.element(boundBy: 2).tap()
            }
            
            app.terminate()
        }
    }
}

// MARK: - UI Test Helpers

extension XCUIElement {
    func clearAndEnterText(_ text: String) {
        guard self.exists else { return }
        
        self.tap()
        
        // Clear existing text
        if let stringValue = self.value as? String, !stringValue.isEmpty {
            let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
            self.typeText(deleteString)
        }
        
        // Enter new text
        self.typeText(text)
    }
    
    func waitForExistenceAndTap(timeout: TimeInterval = 5) -> Bool {
        guard self.waitForExistence(timeout: timeout) else { return false }
        self.tap()
        return true
    }
}
