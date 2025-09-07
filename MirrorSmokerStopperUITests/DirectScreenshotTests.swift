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
        print("🎯 Starting very simple iOS app screenshot test...")
        
        // Create output directory in Documents
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.path
        let outputDir = "\(documentsPath)/screenshots"
        let fileManager = FileManager.default
        
        // Remove existing directory and create fresh one
        try? fileManager.removeItem(atPath: outputDir)
        try fileManager.createDirectory(atPath: outputDir, withIntermediateDirectories: true, attributes: nil)
        
        print("📂 Created directory: \(outputDir)")
        
        // Take simple screenshot
        print("📸 Taking screenshot: Main view")
        sleep(2) // Let app settle
        let mainScreenshot = app.screenshot()
        let mainPath = "\(outputDir)/01_MainDashboard.png"
        try mainScreenshot.pngRepresentation.write(to: URL(fileURLWithPath: mainPath))
        print("✅ Saved screenshot to: \(mainPath)")
        
        var screenshotCount = 2
        
        // Get tab bar reference  
        let tabBar = app.tabBars.firstMatch
        if tabBar.waitForExistence(timeout: 10) {
            let tabButtons = tabBar.buttons.allElementsBoundByIndex
            print("📱 Found \(tabButtons.count) tab buttons")
            
            // Screenshot 2: Statistics Tab
            if tabButtons.count > 1 {
                print("📸 Taking screenshot \(screenshotCount): Statistics")
                tabButtons[1].tap()
                sleep(2)
                let statsScreenshot = app.screenshot()
                let statsPath = "\(outputDir)/0\(screenshotCount)_Statistics.png"
                try statsScreenshot.pngRepresentation.write(to: URL(fileURLWithPath: statsPath))
                print("✅ Saved screenshot to: \(statsPath)")
                screenshotCount += 1
            }
            
            // Screenshot 3: Settings Tab
            if tabButtons.count > 2 {
                print("📸 Taking screenshot \(screenshotCount): Settings")
                tabButtons[2].tap()
                sleep(2)
                let settingsScreenshot = app.screenshot()
                let settingsPath = "\(outputDir)/0\(screenshotCount)_Settings.png"
                try settingsScreenshot.pngRepresentation.write(to: URL(fileURLWithPath: settingsPath))
                print("✅ Saved screenshot to: \(settingsPath)")
                screenshotCount += 1
            }
        }
        
        print("✅ Screenshot test completed!")
        print("📂 Generated \(screenshotCount - 1) screenshots in: \(outputDir)")
        
        // List all created files
        if let files = try? fileManager.contentsOfDirectory(atPath: outputDir) {
            print("📋 Created files:")
            for file in files.sorted() {
                print("   • \(file)")
            }
        } else {
            print("❌ Could not list directory contents")
        }
    }
}