//
//  AICoachScreenshotTests.swift
//  MirrorSmokerStopperUITests
//
//  Specialized screenshot tests for AI Coach Dashboard and features
//  Showcases the app's advanced AI coaching capabilities
//

import XCTest

@MainActor
final class AICoachScreenshotTests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        continueAfterFailure = false
        app = XCUIApplication()
        
        // Configure for AI Coach screenshot testing
        app.launchArguments = [
            "UI_TESTING",
            "SCREENSHOT_MODE",
            "AI_COACH_DEMO_MODE", // Special mode to show populated AI coach data
            "-FASTLANE_SNAPSHOT", "YES",
            "-ui_testing"
        ]
        
        setupSnapshot(app)
        app.launch()
        
        // Wait for app to fully load
        _ = app.wait(for: .runningForeground, timeout: 15)
        sleep(3)
        
        // Dismiss any initial alerts or permission requests
        dismissInitialAlerts()
    }
    
    override func tearDownWithError() throws {
        app = nil
        try super.tearDownWithError()
    }
    
    // MARK: - AI Coach Screenshot Tests
    
    func testAICoachScreenshots() throws {
        // Enable AI Coach first
        setupAICoachForScreenshots()
        
        // Take AI Coach Dashboard screenshot
        takeAICoachDashboardScreenshot()
        
        // Take Heart Rate Monitoring screenshot
        takeHeartRateMonitoringScreenshot()
        
        // Take Predictive Analysis screenshot
        takePredictiveAnalysisScreenshot()
        
        // Take AI Insights screenshot
        takeAIInsightsScreenshot()
    }
    
    // MARK: - Setup and Helper Methods
    
    private func setupAICoachForScreenshots() {
        print("📱 Setting up AI Coach for screenshots")
        
        // Navigate to AI Coach (try multiple approaches)
        if !navigateToAICoach() {
            // Fallback: Enable AI Coach through settings
            enableAICoachThroughSettings()
        }
        
        // Wait for AI Coach to initialize
        sleep(2)
    }
    
    private func navigateToAICoach() -> Bool {
        // Try to find AI Coach tab or navigation item
        
        // Method 1: Look for dedicated AI Coach tab
        let aiCoachTab = app.tabBars.buttons.containing(NSPredicate(format: "label CONTAINS 'AI' OR label CONTAINS 'Coach'")).firstMatch
        if aiCoachTab.waitForExistence(timeout: 3) {
            aiCoachTab.tap()
            return true
        }
        
        // Method 2: Look for AI Coach button in main interface
        let aiCoachButton = app.buttons.containing(NSPredicate(format: "label CONTAINS 'AI Coach' OR identifier CONTAINS 'aicoach'")).firstMatch
        if aiCoachButton.waitForExistence(timeout: 3) {
            aiCoachButton.tap()
            return true
        }
        
        // Method 3: Look for AI Coach in navigation bar
        let navBarAI = app.navigationBars.buttons.containing(NSPredicate(format: "label CONTAINS 'AI' OR label CONTAINS 'Coach'")).firstMatch
        if navBarAI.exists {
            navBarAI.tap()
            return true
        }
        
        // Method 4: Swipe through tabs to find AI Coach
        let tabBar = app.tabBars.firstMatch
        if tabBar.exists {
            let tabs = tabBar.buttons
            for i in 0..<min(tabs.count, 5) {
                let tab = tabs.element(boundBy: i)
                tab.tap()
                sleep(1)
                
                // Check if current screen contains AI Coach content
                if app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'AI Coach' OR label CONTAINS 'COACH'")).count > 0 {
                    return true
                }
            }
        }
        
        return false
    }
    
    private func enableAICoachThroughSettings() {
        print("📱 Enabling AI Coach through settings")
        
        // Navigate to settings
        let settingsTab = app.tabBars.buttons.containing(NSPredicate(format: "label CONTAINS 'Settings'")).firstMatch
        if settingsTab.exists {
            settingsTab.tap()
        } else {
            // Try last tab (usually settings)
            let tabs = app.tabBars.buttons
            if tabs.count > 0 {
                tabs.element(boundBy: tabs.count - 1).tap()
            }
        }
        
        sleep(1)
        
        // Look for AI Coach toggle or option
        let scrollView = app.scrollViews.firstMatch
        if scrollView.exists {
            // Scroll to find AI Coach option
            for _ in 0..<3 {
                scrollView.swipeUp()
                sleep(1)
                
                let aiCoachToggle = app.switches.containing(NSPredicate(format: "identifier CONTAINS 'ai' OR identifier CONTAINS 'coach'")).firstMatch
                if aiCoachToggle.exists && !aiCoachToggle.isSelected {
                    aiCoachToggle.tap()
                    sleep(1)
                    break
                }
            }
        }
    }
    
    private func takeAICoachDashboardScreenshot() {
        print("📱 Taking AI Coach Dashboard screenshot")
        
        // Ensure we're on the AI Coach dashboard
        if !app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'AI Coach' OR label CONTAINS 'COACH'")).firstMatch.exists {
            // Try to navigate to AI Coach again
            _ = navigateToAICoach()
        }
        
        // Wait for dashboard to load completely
        sleep(3)
        
        // Enable AI Coach if there's a toggle visible
        let aiToggle = app.switches.firstMatch
        if aiToggle.exists && !aiToggle.isSelected {
            aiToggle.tap()
            sleep(2)
        }
        
        // Wait for dashboard to populate with data
        sleep(2)
        
        // Scroll to show different parts of the dashboard
        let scrollView = app.scrollViews.firstMatch
        if scrollView.exists {
            scrollView.swipeUp(velocity: .slow)
            sleep(1)
            scrollView.swipeDown(velocity: .slow)
            sleep(1)
        }
        
        snapshot("06-AICoachDashboard")
    }
    
    private func takeHeartRateMonitoringScreenshot() {
        print("📱 Taking Heart Rate Monitoring screenshot")
        
        // Look for heart rate setup or monitoring card
        let heartRateCard = app.buttons.containing(NSPredicate(format: "label CONTAINS 'Heart Rate' OR label CONTAINS 'heart'")).firstMatch
        
        if heartRateCard.exists {
            heartRateCard.tap()
            sleep(2)
            snapshot("07-HeartRateMonitoring")
            
            // Go back
            let backButton = app.navigationBars.buttons.firstMatch
            if backButton.exists {
                backButton.tap()
                sleep(1)
            }
        } else {
            // If no heart rate card found, scroll to find it
            let scrollView = app.scrollViews.firstMatch
            if scrollView.exists {
                scrollView.swipeUp()
                sleep(1)
                snapshot("07-HeartRateSetup")
                scrollView.swipeDown()
            }
        }
    }
    
    private func takePredictiveAnalysisScreenshot() {
        print("📱 Taking Predictive Analysis screenshot")
        
        // Look for pattern analysis or prediction cards
        let scrollView = app.scrollViews.firstMatch
        if scrollView.exists {
            // Scroll to show pattern analysis section
            scrollView.swipeUp(velocity: .slow)
            sleep(1)
            
            // Look for prediction or pattern elements
            if app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'Pattern' OR label CONTAINS 'Prediction' OR label CONTAINS 'Risk'")).count > 0 {
                snapshot("08-PredictiveAnalysis")
            } else {
                // Take screenshot of current view anyway
                snapshot("08-AICoachFeatures")
            }
        }
    }
    
    private func takeAIInsightsScreenshot() {
        print("📱 Taking AI Insights screenshot")
        
        // Look for insights section or recommendations
        let scrollView = app.scrollViews.firstMatch
        if scrollView.exists {
            scrollView.swipeDown(velocity: .slow)
            sleep(1)
            
            // Look for personalized actions or insights
            if app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'Insight' OR label CONTAINS 'Recommendation' OR label CONTAINS 'Action'")).count > 0 {
                snapshot("09-AIInsights")
            } else {
                // Show the current dashboard state
                snapshot("09-AICoachOverview")
            }
        }
    }
    
    private func dismissInitialAlerts() {
        // Dismiss any initial system alerts
        sleep(1)
        
        let alerts = app.alerts
        if alerts.count > 0 {
            let alert = alerts.firstMatch
            if alert.exists {
                // Try common button labels
                let buttons = ["Allow", "OK", "Don't Allow", "Cancel", "Enable", "Later"]
                for buttonLabel in buttons {
                    let button = alert.buttons[buttonLabel]
                    if button.exists {
                        button.tap()
                        sleep(1)
                        break
                    }
                }
            }
        }
        
        // Dismiss any sheets that might appear
        let sheets = app.sheets
        if sheets.count > 0 {
            let sheet = sheets.firstMatch
            if sheet.exists {
                let cancelButton = sheet.buttons.containing(NSPredicate(format: "label CONTAINS 'Cancel' OR label CONTAINS 'Done' OR label CONTAINS 'Close'")).firstMatch
                if cancelButton.exists {
                    cancelButton.tap()
                    sleep(1)
                }
            }
        }
        
        // Dismiss any permission requests
        dismissPermissionRequests()
    }
    
    private func dismissPermissionRequests() {
        // Handle HealthKit permissions
        let healthKitAlert = app.alerts.containing(NSPredicate(format: "label CONTAINS 'Health' OR label CONTAINS 'heart rate'")).firstMatch
        if healthKitAlert.waitForExistence(timeout: 2) {
            let allowButton = healthKitAlert.buttons["Allow"]
            if allowButton.exists {
                allowButton.tap()
                sleep(1)
            }
        }
        
        // Handle notification permissions
        let notificationAlert = app.alerts.containing(NSPredicate(format: "label CONTAINS 'Notification' OR label CONTAINS 'notification'")).firstMatch
        if notificationAlert.waitForExistence(timeout: 2) {
            let allowButton = notificationAlert.buttons["Allow"]
            if allowButton.exists {
                allowButton.tap()
                sleep(1)
            }
        }
    }
}

// MARK: - Extensions

extension XCUIElement {
    var isSelected: Bool {
        return (value as? String) == "1"
    }
}

extension XCUIElementQuery {
    var isSelected: Bool {
        return (firstMatch.value as? String) == "1"
    }
}