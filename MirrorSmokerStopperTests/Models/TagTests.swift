//
//  TagTests.swift
//  MirrorSmokerStopperTests
//
//  Created by Claude on 02/09/25.
//

import XCTest
import SwiftUI
import SwiftData
@testable import MirrorSmokerStopper

@MainActor
final class TagTests: XCTestCase {
    
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    
    override func setUp() async throws {
        try await super.setUp()
        
        let schema = Schema([Tag.self, Cigarette.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [config])
        modelContext = ModelContext(modelContainer)
    }
    
    override func tearDown() async throws {
        modelContainer = nil
        modelContext = nil
        try await super.tearDown()
    }
    
    func testTagInitialization() {
        let tag = Tag()
        
        XCTAssertNotEqual(tag.id, UUID())
        XCTAssertEqual(tag.name, "")
        XCTAssertEqual(tag.colorHex, "#007AFF")
    }
    
    func testTagCustomInitialization() {
        let customID = UUID()
        
        let tag = Tag(
            id: customID,
            name: "Test Tag",
            colorHex: "#FF0000"
        )
        
        XCTAssertEqual(tag.id, customID)
        XCTAssertEqual(tag.name, "Test Tag")
        XCTAssertEqual(tag.colorHex, "#FF0000")
    }
    
    func testTagColorProperty() {
        let tag = Tag()
        
        // Test default color
        XCTAssertEqual(tag.colorHex, "#007AFF")
        
        // Test valid hex colors
        tag.colorHex = "#FF0000"
        let redColor = tag.color
        XCTAssertNotNil(redColor)
        
        tag.colorHex = "#00FF00"
        let greenColor = tag.color
        XCTAssertNotNil(greenColor)
        XCTAssertNotEqual(redColor, greenColor)
        
        // Test invalid hex color fallback
        tag.colorHex = "invalid"
        let fallbackColor = tag.color
        XCTAssertNotNil(fallbackColor) // Should fallback to default blue
    }
    
    func testTagPersistence() throws {
        let tag = Tag()
        tag.name = "Persistence Test"
        tag.colorHex = "#00FF00"
        
        modelContext.insert(tag)
        try modelContext.save()
        
        // Fetch and verify
        let fetchDescriptor = FetchDescriptor<Tag>()
        let fetchedTags = try modelContext.fetch(fetchDescriptor)
        
        XCTAssertEqual(fetchedTags.count, 1)
        XCTAssertEqual(fetchedTags.first?.name, "Persistence Test")
        XCTAssertEqual(fetchedTags.first?.colorHex, "#00FF00")
    }
    
    func testTagSorting() throws {
        let tagA = Tag()
        tagA.name = "Alpha"
        
        let tagZ = Tag()
        tagZ.name = "Zulu"
        
        let tagM = Tag()
        tagM.name = "Mike"
        
        modelContext.insert(tagA)
        modelContext.insert(tagZ)
        modelContext.insert(tagM)
        
        try modelContext.save()
        
        // Fetch sorted by name
        let sortedDescriptor = FetchDescriptor<Tag>(
            sortBy: [SortDescriptor(\.name, order: .forward)]
        )
        let sortedTags = try modelContext.fetch(sortedDescriptor)
        
        XCTAssertEqual(sortedTags.count, 3)
        XCTAssertEqual(sortedTags[0].name, "Alpha")
        XCTAssertEqual(sortedTags[1].name, "Mike")
        XCTAssertEqual(sortedTags[2].name, "Zulu")
    }
    
    func testTagCigaretteRelationship() throws {
        // Create tag
        let tag = Tag()
        tag.name = "Test Tag"
        tag.colorHex = "#FF0000"
        modelContext.insert(tag)
        
        // Create cigarette with tag
        let cigarette = Cigarette(note: "Tagged cigarette", tags: [tag])
        modelContext.insert(cigarette)
        
        try modelContext.save()
        
        // Verify relationship
        XCTAssertEqual(cigarette.tags?.count, 1)
        XCTAssertEqual(cigarette.tags?.first?.name, "Test Tag")
    }
    
    func testTagDeletion() throws {
        let tag = Tag()
        tag.name = "To be deleted"
        
        modelContext.insert(tag)
        try modelContext.save()
        
        // Verify exists
        var fetchDescriptor = FetchDescriptor<Tag>()
        var tags = try modelContext.fetch(fetchDescriptor)
        XCTAssertEqual(tags.count, 1)
        
        // Delete
        modelContext.delete(tag)
        try modelContext.save()
        
        // Verify deleted
        tags = try modelContext.fetch(fetchDescriptor)
        XCTAssertEqual(tags.count, 0)
    }
    
    func testTagUniqueness() throws {
        // Create two tags with same name
        let tag1 = Tag()
        tag1.name = "Duplicate"
        
        let tag2 = Tag()
        tag2.name = "Duplicate"
        
        modelContext.insert(tag1)
        modelContext.insert(tag2)
        
        try modelContext.save()
        
        // Should allow duplicates (business logic can handle this)
        let fetchDescriptor = FetchDescriptor<Tag>()
        let tags = try modelContext.fetch(fetchDescriptor)
        XCTAssertEqual(tags.count, 2)
    }
    
    func testColorHexValidation() {
        let tag = Tag()
        
        // Test valid hex colors
        let validColors = ["#FF0000", "#00FF00", "#0000FF", "#FFFFFF", "#000000", "#123ABC"]
        
        for color in validColors {
            tag.colorHex = color
            XCTAssertNotNil(tag.color)
        }
        
        // Test invalid formats (should not crash, may fallback)
        let invalidColors = ["FF0000", "#GGG", "#12345", "", "invalid", "#1234567890"]
        
        for color in invalidColors {
            tag.colorHex = color
            XCTAssertNotNil(tag.color) // Should not be nil even with invalid input
        }
    }
}