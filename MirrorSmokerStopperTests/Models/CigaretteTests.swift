//
//  CigaretteTests.swift
//  MirrorSmokerStopperTests
//
//  Created by Claude on 02/09/25.
//

import XCTest
import SwiftData
@testable import MirrorSmokerStopper

@MainActor
final class CigaretteTests: XCTestCase {
    
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    
    override func setUp() async throws {
        try await super.setUp()
        
        // Create in-memory container for testing
        let schema = Schema([Cigarette.self, Tag.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [config])
        modelContext = ModelContext(modelContainer)
    }
    
    override func tearDown() async throws {
        modelContainer = nil
        modelContext = nil
        try await super.tearDown()
    }
    
    func testCigaretteInitialization() {
        // Test default initialization
        let cigarette1 = Cigarette()
        modelContext.insert(cigarette1)
        
        XCTAssertNotNil(cigarette1.id)
        XCTAssertLessThanOrEqual(Date().timeIntervalSince(cigarette1.timestamp), 1.0)
        XCTAssertEqual(cigarette1.note, "")
        XCTAssertNil(cigarette1.tags)
        
        // Test custom initialization
        let customDate = Date().addingTimeInterval(-3600) // 1 hour ago
        let customID = UUID()
        let customNote = "Test note"
        
        let cigarette2 = Cigarette(
            id: customID,
            timestamp: customDate,
            note: customNote,
            tags: nil
        )
        modelContext.insert(cigarette2)
        
        XCTAssertEqual(cigarette2.id, customID)
        XCTAssertEqual(cigarette2.timestamp, customDate)
        XCTAssertEqual(cigarette2.note, customNote)
        XCTAssertNil(cigarette2.tags)
    }
    
    func testCigaretteWithTags() {
        // Create test tags
        let tag1 = Tag()
        tag1.name = "Stress"
        tag1.colorHex = "#FF0000"
        
        let tag2 = Tag()
        tag2.name = "Morning"
        tag2.colorHex = "#00FF00"
        
        modelContext.insert(tag1)
        modelContext.insert(tag2)
        
        // Create cigarette with tags
        let cigarette = Cigarette(tags: [tag1, tag2])
        modelContext.insert(cigarette)
        
        XCTAssertEqual(cigarette.tags?.count, 2)
        XCTAssertTrue(cigarette.tags?.contains(tag1) ?? false)
        XCTAssertTrue(cigarette.tags?.contains(tag2) ?? false)
    }
    
    func testCigarettePersistence() throws {
        let cigarette = Cigarette(note: "Persistence test")
        modelContext.insert(cigarette)
        
        try modelContext.save()
        
        // Fetch and verify
        let fetchDescriptor = FetchDescriptor<Cigarette>()
        let fetchedCigarettes = try modelContext.fetch(fetchDescriptor)
        
        XCTAssertEqual(fetchedCigarettes.count, 1)
        XCTAssertEqual(fetchedCigarettes.first?.note, "Persistence test")
    }
    
    func testCigaretteFiltering() throws {
        let now = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: now) ?? now.addingTimeInterval(-86400)
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: now) ?? now.addingTimeInterval(86400)
        
        // Create cigarettes at different times
        let todayCig = Cigarette(timestamp: now, note: "Today")
        let yesterdayCig = Cigarette(timestamp: yesterday, note: "Yesterday")
        let tomorrowCig = Cigarette(timestamp: tomorrow, note: "Tomorrow")
        
        modelContext.insert(todayCig)
        modelContext.insert(yesterdayCig)
        modelContext.insert(tomorrowCig)
        
        try modelContext.save()
        
        // Test filtering for today
        let startOfDay = Calendar.current.startOfDay(for: now)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay.addingTimeInterval(86400)
        
        let todayPredicate = #Predicate<Cigarette> { cigarette in
            cigarette.timestamp >= startOfDay && cigarette.timestamp < endOfDay
        }
        
        let todayDescriptor = FetchDescriptor<Cigarette>(predicate: todayPredicate)
        let todayCigarettes = try modelContext.fetch(todayDescriptor)
        
        XCTAssertEqual(todayCigarettes.count, 1)
        XCTAssertEqual(todayCigarettes.first?.note, "Today")
    }
    
    func testCigaretteSorting() throws {
        let baseDate = Date()
        let dates = [
            baseDate.addingTimeInterval(-7200), // 2 hours ago
            baseDate.addingTimeInterval(-3600), // 1 hour ago
            baseDate.addingTimeInterval(-1800), // 30 minutes ago
        ]
        
        // Insert in random order
        for (index, date) in dates.enumerated() {
            let cigarette = Cigarette(timestamp: date, note: "Cigarette \(index)")
            modelContext.insert(cigarette)
        }
        
        try modelContext.save()
        
        // Fetch sorted by timestamp descending (newest first)
        let sortedDescriptor = FetchDescriptor<Cigarette>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        let sortedCigarettes = try modelContext.fetch(sortedDescriptor)
        
        XCTAssertEqual(sortedCigarettes.count, 3)
        XCTAssertGreaterThan(sortedCigarettes[0].timestamp, sortedCigarettes[1].timestamp)
        XCTAssertGreaterThan(sortedCigarettes[1].timestamp, sortedCigarettes[2].timestamp)
    }
    
    func testCigaretteDeletion() throws {
        let cigarette = Cigarette(note: "To be deleted")
        modelContext.insert(cigarette)
        try modelContext.save()
        
        // Verify it exists
        var fetchDescriptor = FetchDescriptor<Cigarette>()
        var cigarettes = try modelContext.fetch(fetchDescriptor)
        XCTAssertEqual(cigarettes.count, 1)
        
        // Delete it
        modelContext.delete(cigarette)
        try modelContext.save()
        
        // Verify it's gone
        cigarettes = try modelContext.fetch(fetchDescriptor)
        XCTAssertEqual(cigarettes.count, 0)
    }
}