//
//  DesignSystemTests.swift
//  MirrorSmokerStopperTests
//
//  Created by Claude on 02/09/25.
//

import XCTest
import SwiftUI
@testable import MirrorSmokerStopper

final class DesignSystemTests: XCTestCase {
    
    func testDSColors() {
        // Test that all DS colors are defined
        XCTAssertNotNil(DS.Colors.primary)
        XCTAssertNotNil(DS.Colors.primaryLight)
        XCTAssertNotNil(DS.Colors.primaryDark)
        XCTAssertNotNil(DS.Colors.background)
        XCTAssertNotNil(DS.Colors.backgroundSecondary)
        XCTAssertNotNil(DS.Colors.textPrimary)
        XCTAssertNotNil(DS.Colors.textSecondary)
        XCTAssertNotNil(DS.Colors.textTertiary)
        XCTAssertNotNil(DS.Colors.success)
        XCTAssertNotNil(DS.Colors.warning)
        XCTAssertNotNil(DS.Colors.danger)
        XCTAssertNotNil(DS.Colors.info)
        XCTAssertNotNil(DS.Colors.cigarette)
        XCTAssertNotNil(DS.Colors.health)
    }
    
    func testDSSpace() {
        // Test spacing values are reasonable
        XCTAssertGreaterThan(DS.Space.xs, 0)
        XCTAssertGreaterThan(DS.Space.sm, DS.Space.xs)
        XCTAssertGreaterThan(DS.Space.md, DS.Space.sm)
        XCTAssertGreaterThan(DS.Space.lg, DS.Space.md)
        XCTAssertGreaterThan(DS.Space.xl, DS.Space.lg)
        XCTAssertGreaterThan(DS.Space.xxl, DS.Space.xl)
    }
    
    func testDSSizes() {
        // Test size values are reasonable
        XCTAssertGreaterThan(DS.Size.buttonHeight, 0)
        XCTAssertGreaterThan(DS.Size.cardRadius, 0)
        XCTAssertGreaterThan(DS.Size.cardRadiusSmall, 0)
        XCTAssertLessThan(DS.Size.cardRadiusSmall, DS.Size.cardRadius)
        XCTAssertGreaterThan(DS.Size.iconSize, 0)
        XCTAssertGreaterThan(DS.Size.iconSizeLarge, DS.Size.iconSize)
    }
    
    func testDSAdaptiveSize() {
        // Test adaptive size calculations
        let size = DS.AdaptiveSize.self
        
        // Test button height is reasonable
        XCTAssertGreaterThan(size.buttonHeight, 40)
        XCTAssertLessThan(size.buttonHeight, 60)
        
        // Test card radius is reasonable
        XCTAssertGreaterThan(size.cardRadius, 8)
        XCTAssertLessThan(size.cardRadius, 20)
        
        // Test icon sizes (now in DS.Size)
        XCTAssertGreaterThan(DS.Size.iconSize, 16)
        XCTAssertLessThan(DS.Size.iconSize, 32)
        XCTAssertGreaterThan(DS.Size.iconSizeLarge, DS.Size.iconSize)
    }
    
    func testDSText() {
        // Test that text styles are defined
        XCTAssertNotNil(DS.Text.largeTitle)
        XCTAssertNotNil(DS.Text.title)
        XCTAssertNotNil(DS.Text.title2)
        XCTAssertNotNil(DS.Text.title3)
        XCTAssertNotNil(DS.Text.headline)
        XCTAssertNotNil(DS.Text.body)
        XCTAssertNotNil(DS.Text.callout)
        XCTAssertNotNil(DS.Text.caption)
        XCTAssertNotNil(DS.Text.caption2)
    }
}