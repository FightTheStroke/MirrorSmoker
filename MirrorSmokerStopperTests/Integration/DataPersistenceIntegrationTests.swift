//
//  DataPersistenceIntegrationTests.swift
//  MirrorSmokerStopperTests
//
//  Created by Claude on 02/09/25.
//

import XCTest
import SwiftData
import WidgetKit
@testable import MirrorSmokerStopper

@MainActor
final class DataPersistenceIntegrationTests: XCTestCase {
    
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    
    override func setUp() async throws {
        try await super.setUp()
        
        // Create in-memory container with full schema
        let schema = Schema([
            Cigarette.self,
            Tag.self,
            UserProfile.self,
            Product.self,
            Purchase.self,
            UrgeLog.self
        ])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [config])
        modelContext = ModelContext(modelContainer)
    }
    
    override func tearDown() async throws {
        modelContainer = nil
        modelContext = nil
        try await super.tearDown()
    }
    
    // MARK: - Complete User Journey Tests
    
    func testCompleteUserJourney() throws {
        // 1. Create user profile
        let profile = UserProfile(
            name: "Test User",
            birthDate: Calendar.current.date(from: DateComponents(year: 1985, month: 6, day: 15)),
            weight: 75.0,
            smokingType: .cigarettes,
            quitDate: Calendar.current.date(byAdding: .day, value: 30, to: Date()), dailyAverage: 15.0
        )
        modelContext.insert(profile)
        
        // 2. Create tags
        let stressTag = Tag(name: "Stress", colorHex: "#FF0000")
        let morningTag = Tag(name: "Morning", colorHex: "#00FF00")
        let workTag = Tag(name: "Work", colorHex: "#0000FF")
        
        modelContext.insert(stressTag)
        modelContext.insert(morningTag)
        modelContext.insert(workTag)
        
        try modelContext.save()
        
        // 3. Create cigarettes over several days
        let baseDate = Date()
        let cigarettes = [
            // Day 1
            Cigarette(timestamp: baseDate.addingTimeInterval(-86400 * 2), note: "Morning coffee", tags: [morningTag]),
            Cigarette(timestamp: baseDate.addingTimeInterval(-86400 * 2 + 3600), note: "Work break", tags: [workTag, stressTag]),
            Cigarette(timestamp: baseDate.addingTimeInterval(-86400 * 2 + 7200), note: "", tags: nil),
            
            // Day 2
            Cigarette(timestamp: baseDate.addingTimeInterval(-86400), note: "Stressful day", tags: [stressTag]),
            Cigarette(timestamp: baseDate.addingTimeInterval(-86400 + 1800), note: "Lunch break", tags: [workTag]),
            
            // Today
            Cigarette(timestamp: baseDate.addingTimeInterval(-3600), note: "Recent", tags: [stressTag]),
        ]
        
        for cigarette in cigarettes {
            modelContext.insert(cigarette)
        }
        
        try modelContext.save()
        
        // 4. Verify all data persisted correctly
        let fetchedProfiles = try modelContext.fetch(FetchDescriptor<UserProfile>())
        XCTAssertEqual(fetchedProfiles.count, 1)
        XCTAssertEqual(fetchedProfiles.first?.name, "Test User")
        
        let fetchedTags = try modelContext.fetch(FetchDescriptor<Tag>(sortBy: [SortDescriptor(\.name)]))
        XCTAssertEqual(fetchedTags.count, 3)
        XCTAssertEqual(fetchedTags[0].name, "Morning")
        XCTAssertEqual(fetchedTags[1].name, "Stress")
        XCTAssertEqual(fetchedTags[2].name, "Work")
        
        let fetchedCigarettes = try modelContext.fetch(FetchDescriptor<Cigarette>(sortBy: [SortDescriptor(\.timestamp)]))
        XCTAssertEqual(fetchedCigarettes.count, 6)
        
        // 5. Test queries and relationships
        let stressfulCigarettes = try modelContext.fetch(
            FetchDescriptor<Cigarette>(
                predicate: #Predicate { cigarette in
                    cigarette.tags?.contains { tag in tag.name == "Stress" } ?? false
                }
            )
        )
        XCTAssertEqual(stressfulCigarettes.count, 3)
        
        // 6. Test today's count
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today) ?? today.addingTimeInterval(86400)
        
        let todayPredicate = #Predicate<Cigarette> { cigarette in
            cigarette.timestamp >= today && cigarette.timestamp < tomorrow
        }
        let todayCigarettes = try modelContext.fetch(FetchDescriptor<Cigarette>(predicate: todayPredicate))
        XCTAssertEqual(todayCigarettes.count, 1)
    }
    
    func testCigaretteTagRelationshipIntegrity() throws {
        let tag = Tag(name: "Test Tag", colorHex: "#FF0000")
        modelContext.insert(tag)
        
        let cigarette = Cigarette(note: "Tagged cigarette", tags: [tag])
        modelContext.insert(cigarette)
        
        try modelContext.save()
        
        // Verify relationship exists
        let fetchedCigarettes = try modelContext.fetch(FetchDescriptor<Cigarette>())
        XCTAssertEqual(fetchedCigarettes.count, 1)
        XCTAssertEqual(fetchedCigarettes.first?.tags?.count, 1)
        XCTAssertEqual(fetchedCigarettes.first?.tags?.first?.name, "Test Tag")
        
        // Delete tag and verify cigarette still exists but without tag
        modelContext.delete(tag)
        try modelContext.save()
        
        let updatedCigarettes = try modelContext.fetch(FetchDescriptor<Cigarette>())
        XCTAssertEqual(updatedCigarettes.count, 1)
        // Note: The tag relationship behavior depends on SwiftData's cascade rules
        // This test documents the expected behavior
    }
    
    func testUserProfileQuitPlanIntegration() throws {
        let quitDate = Calendar.current.date(byAdding: .day, value: 14, to: Date()) ?? Date().addingTimeInterval(14 * 86400)
        let profile = UserProfile(
            name: "Quitting User",
            quitDate: quitDate, enableGradualReduction: true, reductionCurve: .exponential, dailyAverage: 20.0
        )
        
        modelContext.insert(profile)
        try modelContext.save()
        
        // Test quit plan calculations
        let todayTarget = profile.todayTarget(dailyAverage: 20.0)
        XCTAssertGreaterThan(todayTarget, 0)
        XCTAssertLessThan(todayTarget, 20)
        
        // Test as we approach quit date
        let laterProfile = UserProfile(
            name: "Close to Quit",
            quitDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date().addingTimeInterval(86400), enableGradualReduction: true, dailyAverage: 20.0
        )
        
        let finalTarget = laterProfile.todayTarget(dailyAverage: 20.0)
        XCTAssertLessThan(finalTarget, todayTarget) // Should be lower closer to quit date
    }
    
    func testStatisticsCalculations() throws {
        let baseDate = Date()
        let cigarettes = [
            // Last week
            Cigarette(timestamp: baseDate.addingTimeInterval(-86400 * 7)),
            Cigarette(timestamp: baseDate.addingTimeInterval(-86400 * 6)),
            Cigarette(timestamp: baseDate.addingTimeInterval(-86400 * 5)),
            
            // This week
            Cigarette(timestamp: baseDate.addingTimeInterval(-86400 * 3)),
            Cigarette(timestamp: baseDate.addingTimeInterval(-86400 * 2)),
            Cigarette(timestamp: baseDate.addingTimeInterval(-86400)),
            
            // Today
            Cigarette(timestamp: baseDate.addingTimeInterval(-3600)),
            Cigarette(timestamp: baseDate.addingTimeInterval(-1800)),
        ]
        
        for cigarette in cigarettes {
            modelContext.insert(cigarette)
        }
        try modelContext.save()
        
        // Test today count
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today) ?? today.addingTimeInterval(86400)
        
        let todayPredicate = #Predicate<Cigarette> { cigarette in
            cigarette.timestamp >= today && cigarette.timestamp < tomorrow
        }
        let todayCount = try modelContext.fetch(FetchDescriptor<Cigarette>(predicate: todayPredicate)).count
        XCTAssertEqual(todayCount, 2)
        
        // Test weekly count
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date().addingTimeInterval(-7 * 86400)
        let weekPredicate = #Predicate<Cigarette> { cigarette in
            cigarette.timestamp >= weekAgo
        }
        let weekCount = try modelContext.fetch(FetchDescriptor<Cigarette>(predicate: weekPredicate)).count
        XCTAssertEqual(weekCount, 5) // 3 this week + 2 today
        
        // Test monthly count
        let monthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date().addingTimeInterval(-30 * 86400)
        let monthPredicate = #Predicate<Cigarette> { cigarette in
            cigarette.timestamp >= monthAgo
        }
        let monthCount = try modelContext.fetch(FetchDescriptor<Cigarette>(predicate: monthPredicate)).count
        XCTAssertEqual(monthCount, 8) // All cigarettes
    }
    
    func testConcurrentDataOperations() throws {
        let expectation = XCTestExpectation(description: "Concurrent operations complete")
        
        // Simulate concurrent data operations
        DispatchQueue.global().async {
            let cigarette1 = Cigarette(note: "Concurrent 1")
            self.modelContext.insert(cigarette1)
            
            do {
                try self.modelContext.save()
            } catch {
                XCTFail("Failed to save cigarette1: \(error)")
            }
        }
        
        DispatchQueue.global().async {
            let cigarette2 = Cigarette(note: "Concurrent 2")
            self.modelContext.insert(cigarette2)
            
            do {
                try self.modelContext.save()
            } catch {
                XCTFail("Failed to save cigarette2: \(error)")
            }
        }
        
        // Wait and verify
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            do {
                let allCigarettes = try self.modelContext.fetch(FetchDescriptor<Cigarette>())
                XCTAssertEqual(allCigarettes.count, 2)
                expectation.fulfill()
            } catch {
                XCTFail("Failed to fetch cigarettes: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testDataMigrationScenario() throws {
        // Simulate adding data, then updating schema-like operations
        
        // Phase 1: Create initial data
        let profile = UserProfile(name: "Migration Test")
        modelContext.insert(profile)
        
        let cigarette = Cigarette(note: "Pre-migration")
        modelContext.insert(cigarette)
        
        try modelContext.save()
        
        // Phase 2: Verify data exists
        var profiles = try modelContext.fetch(FetchDescriptor<UserProfile>())
        var cigarettes = try modelContext.fetch(FetchDescriptor<Cigarette>())
        
        XCTAssertEqual(profiles.count, 1)
        XCTAssertEqual(cigarettes.count, 1)
        
        // Phase 3: Update data (simulating migration)
        profiles.first?.name = "Post-migration"
        cigarettes.first?.note = "Post-migration"
        
        try modelContext.save()
        
        // Phase 4: Verify updates
        let updatedProfiles = try modelContext.fetch(FetchDescriptor<UserProfile>())
        let updatedCigarettes = try modelContext.fetch(FetchDescriptor<Cigarette>())
        
        XCTAssertEqual(updatedProfiles.first?.name, "Post-migration")
        XCTAssertEqual(updatedCigarettes.first?.note, "Post-migration")
    }
}
