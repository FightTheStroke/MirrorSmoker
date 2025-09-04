import XCTest
@testable import MirrorSmokerStopper

final class SettingsViewUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    func testDeleteAllDataButtonExists() throws {
        // Navigate to Settings by looking for tab bar
        let settingsTab = app.tabBars.buttons["Settings"]
        if settingsTab.exists {
            settingsTab.tap()
        } else {
            // Try alternative way to get to settings
            let tabBars = app.tabBars.firstMatch
            if tabBars.exists {
                let buttons = tabBars.buttons.allElementsBoundByIndex
                for button in buttons {
                    if button.label.contains("Settings") || button.identifier.contains("settings") {
                        button.tap()
                        break
                    }
                }
            }
        }
        
        // Give some time for the view to load
        Thread.sleep(forTimeInterval: 1)
        
        // Scroll to find the delete button
        let scrollView = app.scrollViews.firstMatch
        if scrollView.exists {
            // Try multiple scroll attempts to find the button
            for _ in 0..<5 {
                scrollView.swipeUp()
                Thread.sleep(forTimeInterval: 0.5)
                
                // Check if delete button is now visible
                let deleteButton = app.buttons["deleteAllDataButton"]
                if deleteButton.exists {
                    break
                }
            }
        }
        
        // Look for delete button using accessibility identifier
        let deleteButton = app.buttons["deleteAllDataButton"]
        
        if deleteButton.exists {
            print("✅ Delete All Data button found")
        } else {
            print("❌ Delete All Data button not found")
            print("Current screen hierarchy:")
            print(app.debugDescription)
        }
        
        XCTAssertTrue(deleteButton.exists, "Delete All Data button should exist in Settings")
    }
    
    func testDeleteAllDataButtonTap() throws {
        // Navigate to Settings
        let settingsTab = app.tabBars.buttons["Settings"]
        if settingsTab.exists {
            settingsTab.tap()
        } else {
            let settingsButton = app.buttons["Settings"]
            if settingsButton.exists {
                settingsButton.tap()
            }
        }
        
        // Scroll to find the delete button
        let scrollView = app.scrollViews.firstMatch
        if scrollView.exists {
            scrollView.swipeUp()
            scrollView.swipeUp()
        }
        
        // Find and tap the delete button
        let deleteButton = app.buttons.containing(NSPredicate(format: "label CONTAINS 'Delete All Data'")).firstMatch
        
        if deleteButton.exists {
            deleteButton.tap()
            
            // Check if alert appears
            let alert = app.alerts.firstMatch
            if alert.waitForExistence(timeout: 2) {
                print("✅ Delete confirmation alert appeared")
                
                // Tap Cancel to avoid actually deleting data
                let cancelButton = alert.buttons["Cancel"]
                if cancelButton.exists {
                    cancelButton.tap()
                }
            } else {
                print("❌ Delete confirmation alert did not appear")
            }
            
            XCTAssertTrue(alert.waitForExistence(timeout: 2), "Delete confirmation alert should appear when tapping delete button")
        } else {
            XCTFail("Delete All Data button not found")
        }
    }
}