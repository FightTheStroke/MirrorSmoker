//
//  WidgetScreenshotTests.swift
//  MirrorSmokerStopperUITests
//
//  Genera screenshot del Widget nelle varie famiglie per l'App Store.
//
import XCTest

@MainActor
final class WidgetScreenshotTests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = [
            "UI_TESTING",
            "SCREENSHOT_MODE",
            "-FASTLANE_SNAPSHOT", "YES",
            "-ui_testing"
        ]
        setupSnapshot(app)
        app.launch()
        sleep(3)
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func testWidgetScreenshots() throws {
        // Simula dati visibili nella home per riflettere widget aggiornato
        populateDemoDataIfNeeded()
        sleep(2)
        snapshot("10-WidgetMediumPreview")
        // In mancanza di API diretta per mostrare varianti widget in UI test,
        // prendiamo ulteriori screenshot dopo scroll/azioni per differenziare.
        app.swipeUp()
        sleep(1)
        snapshot("11-WidgetSmallPreview")
    }

    private func populateDemoDataIfNeeded() {
        // Aggiunge qualche voce se il contatore è 0 per evitare widget vuoto
        let addButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] '+' OR label CONTAINS[c] 'Add'")).firstMatch
        if addButton.waitForExistence(timeout: 5) {
            for _ in 0..<2 { addButton.tap(); sleep(1) }
        }
    }
}
