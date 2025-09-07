//
//  ScreenshotTests.swift
//  MirrorSmokerStopperUITests
//
//  Automated Screenshot Generation for App Store
//  Captures all key app features including AI Coach Dashboard
//

import XCTest

@MainActor
final class ScreenshotTests: XCTestCase {
    
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
        
        // Wait for app to fully load
        _ = app.wait(for: .runningForeground, timeout: 10)
        sleep(2)
    }
    
    override func tearDownWithError() throws {
        app = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Screenshot Tests
    
    func testScreenshots() throws {
        // Screenshot 1: Main Dashboard (Home Screen)
        takeMainDashboardScreenshot()
        
        // Screenshot 2: AI Coach Dashboard
        takeAICoachScreenshot()
        
        // Screenshot 3: Statistics View
        takeStatisticsScreenshot()
        
        // Screenshot 4: Settings View
        takeSettingsScreenshot()
        
        // Screenshot 5: Adding Cigarette with Tags
        takeAddCigaretteWithTagsScreenshot()
    }
    
    // MARK: - Individual Screenshot Methods
    
    private func takeMainDashboardScreenshot() {
        print("📱 Taking Main Dashboard Screenshot")
        
        // Navigate to home tab
        let homeTab = app.tabBars.buttons.element(boundBy: 0)
        if homeTab.waitForExistence(timeout: 5) {
            homeTab.tap()
        }
        
        // Wait for content to load
        sleep(2)
        
        // Take screenshot
        snapshot("01-MainDashboard")
    }
    
    private func takeAICoachScreenshot() {
        print("📱 Taking AI Coach Dashboard Screenshot")
        
        // First, try to find and navigate to AI Coach
        // Look for AI Coach tab or button
        let aiCoachButton = app.buttons.containing(NSPredicate(format: "label CONTAINS 'AI' OR label CONTAINS 'Coach'")).firstMatch
        
        if aiCoachButton.waitForExistence(timeout: 3) {
            aiCoachButton.tap()
        } else {
            // Navigate through settings or find AI Coach another way
            navigateToAICoach()
        }
        
        // Wait for AI Coach view to load
        sleep(2)
        
        // Enable AI Coach if not already enabled
        let aiToggle = app.switches.firstMatch
        if aiToggle.exists && !aiToggle.isSelected {
            aiToggle.tap()
            sleep(1)
        }
        
        // Wait for dashboard to populate with data
        sleep(2)
        
        // Take screenshot
        snapshot("02-AICoachDashboard")
    }
    
    private func takeStatisticsScreenshot() {
        print("📱 Taking Statistics Screenshot")
        
        // Navigate to statistics tab
        let statsTab = app.tabBars.buttons.containing(NSPredicate(format: "label CONTAINS 'Statistics' OR label CONTAINS 'Stats'")).firstMatch
        
        if !statsTab.exists {
            // Try by index if identifier doesn't work
            let tabButtons = app.tabBars.buttons
            if tabButtons.count >= 2 {
                tabButtons.element(boundBy: 1).tap()
            }
        } else {
            statsTab.tap()
        }
        
        // Wait for statistics to load
        sleep(3)
        
        // Scroll to show various statistics
        let scrollView = app.scrollViews.firstMatch
        if scrollView.exists {
            scrollView.swipeUp(velocity: .slow)
            sleep(1)
        }
        
        // Take screenshot
        snapshot("03-Statistics")
    }
    
    private func takeSettingsScreenshot() {
        print("📱 Taking Settings Screenshot")
        
        // Navigate to settings tab
        let settingsTab = app.tabBars.buttons.containing(NSPredicate(format: "label CONTAINS 'Settings'")).firstMatch
        
        if !settingsTab.exists {
            // Try by index if identifier doesn't work
            let tabButtons = app.tabBars.buttons
            if tabButtons.count >= 3 {
                tabButtons.element(boundBy: 2).tap()
            }
        } else {
            settingsTab.tap()
        }
        
        // Wait for settings to load
        sleep(2)
        
        // Fill in some sample data for a better screenshot
        fillSampleSettingsData()
        
        // Take screenshot
        snapshot("04-Settings")
    }
    
    private func takeAddCigaretteWithTagsScreenshot() {
        print("📱 Taking Add Cigarette with Tags Screenshot")
        
        // Navigate back to home
        let homeTab = app.tabBars.buttons.element(boundBy: 0)
        if homeTab.waitForExistence(timeout: 5) {
            homeTab.tap()
        }
        
        sleep(1)
        
        // Find and long-press the add button to show tag picker
        let addButton = app.buttons.containing(NSPredicate(format: "identifier CONTAINS 'add' OR identifier CONTAINS 'plus'")).firstMatch
        
        if addButton.waitForExistence(timeout: 5) {
            // Create a tag first if none exist
            createSampleTagIfNeeded()
            
            // Long press to show tag selection
            addButton.press(forDuration: 1.0)
            
            // Wait for tag picker sheet
            let tagSheet = app.sheets.firstMatch
            if tagSheet.waitForExistence(timeout: 3) {
                sleep(1)
                snapshot("05-AddCigaretteWithTags")
                
                // Close the sheet
                let doneButton = app.navigationBars.buttons.containing(NSPredicate(format: "label CONTAINS 'Done'")).firstMatch
                if doneButton.exists {
                    doneButton.tap()
                }
            } else {
                // If no sheet appeared, just take a screenshot of the add button
                snapshot("05-AddCigarette")
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func navigateToAICoach() {
        // Try to find AI Coach through navigation
        // This might be in settings or accessible through a menu
        
        let settingsTab = app.tabBars.buttons.containing(NSPredicate(format: "label CONTAINS 'Settings'")).firstMatch
        if settingsTab.exists {
            settingsTab.tap()
            sleep(1)
            
            // Look for AI Coach option in settings
            let aiCoachOption = app.buttons.containing(NSPredicate(format: "label CONTAINS 'AI' OR label CONTAINS 'Coach'")).firstMatch
            if aiCoachOption.exists {
                aiCoachOption.tap()
                return
            }
        }
        
        // If not found in settings, check if there's a dedicated tab
        let tabBars = app.tabBars.buttons
        for i in 0..<tabBars.count {
            let tab = tabBars.element(boundBy: i)
            if tab.label.contains("AI") || tab.label.contains("Coach") {
                tab.tap()
                return
            }
        }
        
        // Fallback: Look for any AI-related navigation items
        let navItems = app.navigationBars.buttons
        for i in 0..<navItems.count {
            let item = navItems.element(boundBy: i)
            if item.label.contains("AI") || item.label.contains("Coach") {
                item.tap()
                return
            }
        }
    }
    
    private func fillSampleSettingsData() {
        // Fill in sample data to make settings screenshot look better
        
        // Name field
        let nameField = app.textFields.containing(NSPredicate(format: "placeholder CONTAINS 'name' OR placeholder CONTAINS 'Name'")).firstMatch
        if nameField.waitForExistence(timeout: 3) {
            nameField.tap()
            nameField.clearAndEnterText("John Smith")
        }
        
        // Weight field
        let weightField = app.textFields.containing(NSPredicate(format: "placeholder CONTAINS 'weight' OR placeholder CONTAINS 'Weight'")).firstMatch
        if weightField.exists {
            weightField.tap()
            weightField.clearAndEnterText("75")
        }
        
        // Age stepper - increase age
        let steppers = app.steppers
        if steppers.count > 0 {
            let ageStepper = steppers.firstMatch
            ageStepper.buttons.element(boundBy: 1).tap() // Increase button
            sleep(1)
        }
        
        // Scroll to show more settings
        let scrollView = app.scrollViews.firstMatch
        if scrollView.exists {
            scrollView.swipeUp(velocity: .slow)
            sleep(1)
        }
        
        // Dismiss keyboard if visible
        if app.keyboards.element.exists {
            app.tap()
            sleep(1)
        }
    }
    
    private func createSampleTagIfNeeded() {
        // Long press add button to see if tags exist
        let addButton = app.buttons.containing(NSPredicate(format: "identifier CONTAINS 'add' OR identifier CONTAINS 'plus'")).firstMatch
        
        if addButton.waitForExistence(timeout: 5) {
            addButton.press(forDuration: 1.0)
            
            let tagSheet = app.sheets.firstMatch
            if tagSheet.waitForExistence(timeout: 3) {
                
                // Check if create tag button exists (meaning no tags exist)
                let createTagButton = app.buttons.containing(NSPredicate(format: "label CONTAINS 'Create' OR label CONTAINS 'create'")).firstMatch
                
                if createTagButton.exists {
                    createTagButton.tap()
                    
                    // Fill in tag details
                    let nameField = app.textFields.firstMatch
                    if nameField.exists {
                        nameField.tap()
                        nameField.typeText("Work Break")
                        sleep(1)
                    }
                    
                    // Select a color (tap first color option)
                    let colorOptions = app.buttons.containing(NSPredicate(format: "identifier CONTAINS 'color'"))
                    if colorOptions.count > 0 {
                        colorOptions.firstMatch.tap()
                        sleep(1)
                    }
                    
                    // Save tag
                    let saveButton = app.navigationBars.buttons.containing(NSPredicate(format: "label CONTAINS 'Save' OR label CONTAINS 'save'")).firstMatch
                    if saveButton.exists {
                        saveButton.tap()
                        sleep(1)
                    }
                }
                
                // Close the sheet
                let cancelButton = app.buttons.containing(NSPredicate(format: "label CONTAINS 'Cancel' OR label CONTAINS 'Done'")).firstMatch
                if cancelButton.exists {
                    cancelButton.tap()
                    sleep(1)
                }
            }
        }
    }
    
    private func dismissAnyAlerts() {
        // Dismiss any system alerts that might appear
        let alerts = app.alerts
        if alerts.count > 0 {
            let alert = alerts.firstMatch
            if alert.exists {
                // Try to find OK, Cancel, or Allow buttons
                let okButton = alert.buttons["OK"]
                let allowButton = alert.buttons["Allow"]
                let cancelButton = alert.buttons["Cancel"]
                
                if okButton.exists {
                    okButton.tap()
                } else if allowButton.exists {
                    allowButton.tap()
                } else if cancelButton.exists {
                    cancelButton.tap()
                }
                
                sleep(1)
            }
        }
    }
}

// MARK: - Helper Extensions
// Extensions are shared with AICoachScreenshotTests.swift