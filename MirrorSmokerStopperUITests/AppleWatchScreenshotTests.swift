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
        print("🎯 Starting Apple Watch screenshot capture...")
        
        // Create output directory - use Documents for reliable access
        let documentsPath = NSHomeDirectory() + "/Documents"
        let outputDir = "\(documentsPath)/watch-screenshots"
        let fileManager = FileManager.default
        
        // Remove existing directory and create fresh one
        try? fileManager.removeItem(atPath: outputDir)
        try fileManager.createDirectory(atPath: outputDir, withIntermediateDirectories: true, attributes: nil)
        
        print("📂 Created directory: \(outputDir)")
        
        var screenshotCount = 1
        
        // Screenshot 1: Watch Main Dashboard
        print("📸 Taking screenshot \(screenshotCount): Watch Main Dashboard")
        let mainScreenshot = app.screenshot()
        let mainPath = "\(outputDir)/Watch_0\(screenshotCount)_Dashboard.png"
        try mainScreenshot.pngRepresentation.write(to: URL(fileURLWithPath: mainPath))
        print("✅ Saved screenshot to: \(mainPath)")
        screenshotCount += 1
        
        // Screenshot 2: Watch Add Cigarette - Easy tracking
        let addButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Add' OR label CONTAINS[c] 'Plus' OR label CONTAINS[c] '+'")).firstMatch
        if addButton.exists && addButton.isHittable {
            print("📸 Taking screenshot \(screenshotCount): Watch Add Cigarette")
            addButton.tap()
            sleep(2)
            let addScreenshot = app.screenshot()
            let addPath = "\(outputDir)/Watch_0\(screenshotCount)_AddCigarette.png"
            try addScreenshot.pngRepresentation.write(to: URL(fileURLWithPath: addPath))
            print("✅ Saved screenshot to: \(addPath)")
            screenshotCount += 1
            
            // Dismiss or confirm
            let confirmButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Confirm' OR label CONTAINS[c] 'Done' OR label CONTAINS[c] 'Save'")).firstMatch
            if confirmButton.exists && confirmButton.isHittable {
                confirmButton.tap()
                sleep(1)
            }
        }
        
        // Screenshot 3: Watch Progress - Daily statistics  
        let progressButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Progress' OR label CONTAINS[c] 'Stats' OR label CONTAINS[c] 'Chart'")).firstMatch
        if progressButton.exists && progressButton.isHittable {
            print("📸 Taking screenshot \(screenshotCount): Watch Progress")
            progressButton.tap()
            sleep(2)
            let progressScreenshot = app.screenshot()
            let progressPath = "\(outputDir)/Watch_0\(screenshotCount)_Progress.png"
            try progressScreenshot.pngRepresentation.write(to: URL(fileURLWithPath: progressPath))
            print("✅ Saved screenshot to: \(progressPath)")
            screenshotCount += 1
        }
        
        // Screenshot 4: Watch Home Screen - Digital Crown press
        print("📸 Taking screenshot \(screenshotCount): Watch Home Screen")
        let digitalCrown = XCUIDevice.shared
        digitalCrown.press(.home)
        sleep(3)
        let homeScreenshot = app.screenshot()
        let homePath = "\(outputDir)/Watch_0\(screenshotCount)_HomeScreen.png"
        try homeScreenshot.pngRepresentation.write(to: URL(fileURLWithPath: homePath))
        print("✅ Saved screenshot to: \(homePath)")
        screenshotCount += 1
        
        // Screenshot 5: Final Watch Interface
        print("📸 Taking screenshot \(screenshotCount): Final Watch Interface")
        let finalScreenshot = app.screenshot()
        let finalPath = "\(outputDir)/Watch_0\(screenshotCount)_Interface.png"
        try finalScreenshot.pngRepresentation.write(to: URL(fileURLWithPath: finalPath))
        print("✅ Saved screenshot to: \(finalPath)")
        screenshotCount += 1
        
        print("✅ Apple Watch screenshot capture completed!")
        print("📂 Generated 5 watch screenshots in: \(outputDir)")
        
        // List all created files
        if let files = try? fileManager.contentsOfDirectory(atPath: outputDir) {
            print("📋 Created watch screenshot files:")
            for file in files.sorted() {
                print("   • \(file)")
            }
        } else {
            print("❌ Could not list directory contents")
        }
    }
}