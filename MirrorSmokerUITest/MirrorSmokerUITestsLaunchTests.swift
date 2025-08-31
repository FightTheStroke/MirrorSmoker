//
//  MirrorSmokerUITestsLaunchTests.swift
//  Mirror Smoker UI Tests
//
//  Created by Roberto D’Angelo on 31/08/25.
//

import XCTest

final class MirrorSmokerUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
