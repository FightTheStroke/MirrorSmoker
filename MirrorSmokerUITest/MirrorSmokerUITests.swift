//
//  MirrorSmokerUITests.swift
//  Mirror Smoker UI Tests
//
//  Created by Roberto D’Angelo on 31/08/25.
//

import XCTest

final class MirrorSmokerUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
    }

    @MainActor
    func testExample() throws {
        let app = XCUIApplication()
        app.launch()
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
