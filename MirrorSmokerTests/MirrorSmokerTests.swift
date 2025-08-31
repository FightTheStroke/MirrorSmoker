//
//  MirrorSmokerTests.swift
//  MirrorSmokerTests
//
//  Created by Roberto D'Angelo on 27/08/24.
//

import XCTest
import SwiftData
@testable import MirrorSmoker

final class MirrorSmokerTests: XCTestCase {
    
    var modelContainer: ModelContainer!
    
    override func setUpWithError() throws {
        // Create an in-memory model container for testing
        let schema = Schema([
            Cigarette.self,
            Tag.self,
            UserProfile.self,
            Product.self
        ])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        
        do {
            modelContainer = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            XCTFail("Failed to create model container: \(error)")
        }
    }
    
    override func tearDownWithError() throws {
        // Clean up
        modelContainer = nil
    }
    
    func testCigaretteCreation() throws {
        let cigarette = Cigarette()
        XCTAssertNotNil(cigarette.id)
        XCTAssertNotNil(cigarette.timestamp)
        XCTAssertEqual(cigarette.note, "")
        XCTAssertTrue(cigarette.tags.isEmpty)
    }
    
    func testTagCreation() throws {
        let tag = Tag(name: "Test Tag", colorHex: "#FF0000")
        XCTAssertEqual(tag.name, "Test Tag")
        XCTAssertEqual(tag.colorHex, "#FF0000")
    }
    
    func testUserProfileCreation() throws {
        let profile = UserProfile(
            name: "Test User",
            email: "test@example.com",
            username: "testuser",
            dailyGoal: 20,
            weeklyGoal: 140,
            monthlyGoal: 600,
            notificationsEnabled: true,
            themePreference: "light"
        )
        
        XCTAssertEqual(profile.name, "Test User")
        XCTAssertEqual(profile.email, "test@example.com")
        XCTAssertEqual(profile.username, "testuser")
        XCTAssertEqual(profile.dailyGoal, 20)
        XCTAssertEqual(profile.weeklyGoal, 140)
        XCTAssertEqual(profile.monthlyGoal, 600)
        XCTAssertTrue(profile.notificationsEnabled)
        XCTAssertEqual(profile.themePreference, "light")
    }
    
    func testProductCreation() throws {
        let product = Product(
            name: "Test Product",
            brand: "Test Brand",
            nicotineContent: 0.8
        )
        
        XCTAssertEqual(product.name, "Test Product")
        XCTAssertEqual(product.brand, "Test Brand")
        XCTAssertEqual(product.nicotineContent, 0.8, accuracy: 0.001)
    }
    
    func testColorFromHex() throws {
        let redColor = Color.fromHex("#FF0000")
        XCTAssertNotNil(redColor)
        
        let whiteColor = Color.fromHex("#FFFFFF")
        XCTAssertNotNil(whiteColor)
        
        let blackColor = Color.fromHex("#000000")
        XCTAssertNotNil(blackColor)
        
        let invalidColor = Color.fromHex("Invalid")
        XCTAssertNil(invalidColor)
    }
    
    func testTagColorProperty() throws {
        let tag = Tag(name: "Red Tag", colorHex: "#FF0000")
        let color = tag.color
        XCTAssertNotNil(color)
    }
}