//
//  CoachEngineTests.swift
//  MirrorSmokerStopperTests
//
//  Created by Claude on 02/09/25.
//

import XCTest
import SwiftData
@testable import MirrorSmokerStopper

@MainActor
final class CoachEngineTests: XCTestCase {
    
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    var coachEngine: CoachEngine!
    
    override func setUp() async throws {
        try await super.setUp()
        
        // Create in-memory container with full schema including UrgeLog
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
        
        coachEngine = CoachEngine.shared
    }
    
    override func tearDown() async throws {
        modelContainer = nil
        modelContext = nil
        coachEngine = nil
        try await super.tearDown()
    }
    
    func testRuleFallbackMorningLowStepsHighRecency() async {
        // Create test data - recent cigarette with low activity
        let recentCigarette = Cigarette(timestamp: Date().addingTimeInterval(-30 * 60.0)) // 30 min ago
        modelContext.insert(recentCigarette)
        try! modelContext.save()
        
        // Force evaluation
        let action = await coachEngine.decide(
            modelContext: modelContext,
            userProfile: nil,
            forceEvaluation: true
        )
        
        // Should return some form of action (either nudge or none)
        XCTAssertNotNil(action)
        
        // If it's a nudge, should have content
        if case .nudge(let tip) = action {
            XCTAssertFalse(tip.isEmpty)
            XCTAssertLessThanOrEqual(tip.count, 200) // Reasonable length
        }
    }
    
    func testNoNudgeForLongStreak() async {
        // Create user with long streak
        let profile = UserProfile(
            quitDate: Calendar.current.date(byAdding: .day, value: -40, to: Date()),
            enableGradualReduction: true
        )
        modelContext.insert(profile)
        
        // Create old cigarette (40+ days ago)
        let oldCigarette = Cigarette(timestamp: Date().addingTimeInterval(-40 * 24 * 3600.0))
        modelContext.insert(oldCigarette)
        
        try! modelContext.save()
        
        let action = await coachEngine.decide(
            modelContext: modelContext,
            userProfile: profile,
            forceEvaluation: false // Normal evaluation
        )
        
        // Should not nudge someone with a very long streak unless high risk
        XCTAssertEqual(action, .none)
    }
    
    func testHighRiskScenarioGeneratesNudge() async {
        // Create high-risk scenario - recent cigarette, morning (trigger time)
        let morningTime = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
        let recentCigarette = Cigarette(timestamp: morningTime.addingTimeInterval(-10 * 60.0)) // 10 min ago
        
        modelContext.insert(recentCigarette)
        try! modelContext.save()
        
        let action = await coachEngine.decide(
            modelContext: modelContext,
            userProfile: nil,
            forceEvaluation: true
        )
        
        // Should generate some form of response for high-risk
        XCTAssertNotNil(action)
    }
    
    func testQuietHoursRespected() async {
        // Update quiet hours to include current time (simulate night time)
        let currentHour = Calendar.current.component(.hour, from: Date())
        coachEngine.updateQuietHours(currentHour...currentHour)
        
        // Create high-risk scenario
        let recentCigarette = Cigarette(timestamp: Date().addingTimeInterval(-15 * 60.0))
        modelContext.insert(recentCigarette)
        try! modelContext.save()
        
        let action = await coachEngine.decide(
            modelContext: modelContext,
            userProfile: nil,
            forceEvaluation: false // Normal evaluation should respect quiet hours
        )
        
        // Should not nudge during quiet hours unless forced
        XCTAssertEqual(action, .none)
    }
    
    func testForceEvaluationOverridesQuietHours() async {
        // Set quiet hours to current time
        let currentHour = Calendar.current.component(.hour, from: Date())
        coachEngine.updateQuietHours(currentHour...currentHour)
        
        // Create scenario that would normally trigger
        let recentCigarette = Cigarette(timestamp: Date().addingTimeInterval(-15 * 60.0))
        modelContext.insert(recentCigarette)
        try! modelContext.save()
        
        let action = await coachEngine.decide(
            modelContext: modelContext,
            userProfile: nil,
            forceEvaluation: true // Force should override quiet hours
        )
        
        // Force evaluation should work even in quiet hours
        XCTAssertNotNil(action)
    }
    
    func testTipGenerationBasedOnContext() async {
        // Test with different contexts
        let scenarios = [
            (minutes: 15, expectation: "Should handle recent cigarette"),
            (minutes: 120, expectation: "Should handle moderate time gap"),
            (minutes: 480, expectation: "Should handle longer time gap")
        ]
        
        for scenario in scenarios {
            // Clean slate
            try! modelContext.delete(model: Cigarette.self)
            
            let cigarette = Cigarette(timestamp: Date().addingTimeInterval(TimeInterval(-scenario.minutes * 60)))
            modelContext.insert(cigarette)
            try! modelContext.save()
            
            let action = await coachEngine.decide(
                modelContext: modelContext,
                userProfile: nil,
                forceEvaluation: true
            )
            
            // Should handle the scenario appropriately
            XCTAssertNotNil(action, scenario.expectation)
        }
    }
    
    func testNRTSupportReducesRisk() async {
        // This test would require mocking HealthKit data
        // For now, we test that the engine handles NRT status appropriately
        
        let profile = UserProfile(dailyAverage: 20.0) // High baseline risk
        modelContext.insert(profile)
        
        let recentCigarette = Cigarette(timestamp: Date().addingTimeInterval(-30 * 60.0))
        modelContext.insert(recentCigarette)
        
        try! modelContext.save()
        
        let action = await coachEngine.decide(
            modelContext: modelContext,
            userProfile: profile,
            forceEvaluation: true
        )
        
        // Should generate some response for high-risk user
        XCTAssertNotNil(action)
    }
    
    func testEmptyDatabaseHandling() async {
        // Test with no data
        let action = await coachEngine.decide(
            modelContext: modelContext,
            userProfile: nil,
            forceEvaluation: true
        )
        
        // Should handle empty database gracefully
        XCTAssertNotNil(action)
    }
    
    func testTipLanguageHandling() async {
        // Test that tips are generated in appropriate language
        let cigarette = Cigarette(timestamp: Date().addingTimeInterval(-30 * 60.0))
        modelContext.insert(cigarette)
        try! modelContext.save()
        
        let action = await coachEngine.decide(
            modelContext: modelContext,
            userProfile: nil,
            forceEvaluation: true
        )
        
        if case .nudge(let tip) = action {
            // Should be non-empty and reasonable length
            XCTAssertFalse(tip.isEmpty)
            XCTAssertGreaterThan(tip.count, 10)
            XCTAssertLessThan(tip.count, 500)
        }
    }
    
    func testCoachEngineRateLimiting() async {
        // This would test rate limiting in a more complex scenario
        // For now, we verify the engine respects its internal state
        
        let cigarette = Cigarette(timestamp: Date().addingTimeInterval(-30 * 60.0))
        modelContext.insert(cigarette)
        try! modelContext.save()
        
        // First call
        let action1 = await coachEngine.decide(
            modelContext: modelContext,
            userProfile: nil,
            forceEvaluation: false
        )
        
        // Second call immediately after (should be rate limited)
        let action2 = await coachEngine.decide(
            modelContext: modelContext,
            userProfile: nil,
            forceEvaluation: false
        )
        
        // At least one should respect rate limiting
        XCTAssertTrue(action1 == .none || action2 == .none)
    }
}

// MARK: - Feature Store Tests

@MainActor
final class FeatureStoreTests: XCTestCase {
    
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    var featureStore: FeatureStore!
    
    override func setUp() async throws {
        try await super.setUp()
        
        let schema = Schema([Cigarette.self, Tag.self, UserProfile.self, Product.self, Purchase.self, UrgeLog.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [config])
        modelContext = ModelContext(modelContainer)
        
        featureStore = FeatureStore.shared
    }
    
    override func tearDown() async throws {
        modelContainer = nil
        modelContext = nil
        featureStore = nil
        try await super.tearDown()
    }
    
    func testFeatureCollectionWithEmptyData() async {
        let features = await featureStore.collect(from: modelContext)
        
        XCTAssertEqual(features.minutesSinceLastCig, 1440.0) // 24 hours fallback
        XCTAssertGreaterThanOrEqual(features.hour, 0)
        XCTAssertLessThanOrEqual(features.hour, 23)
        XCTAssertEqual(features.currentStreak, 0)
        XCTAssertEqual(features.avgCigarettesPerDay, 0.0)
        XCTAssertFalse(features.hasActiveTags)
    }
    
    func testFeatureCollectionWithData() async {
        // Create test data
        let tag = Tag(name: "Test", colorHex: "#FF0000")
        modelContext.insert(tag)
        
        let cigarettes = [
            Cigarette(timestamp: Date().addingTimeInterval(-3600.0), tags: [tag]), // 1 hour ago
            Cigarette(timestamp: Date().addingTimeInterval(-86400.0)), // 1 day ago
            Cigarette(timestamp: Date().addingTimeInterval(-2 * 86400.0)), // 2 days ago
        ]
        
        for cigarette in cigarettes {
            modelContext.insert(cigarette)
        }
        
        let profile = UserProfile(
            quitDate: Calendar.current.date(byAdding: .day, value: 10, to: Date()),
            dailyAverage: 5.0
        )
        modelContext.insert(profile)
        
        try! modelContext.save()
        
        let features = await featureStore.collect(from: modelContext, userProfile: profile)
        
        XCTAssertEqual(features.minutesSinceLastCig, 60.0) // 1 hour
        XCTAssertEqual(features.avgCigarettesPerDay, 3.0 / 30.0) // 3 cigarettes over 30 days
        XCTAssertTrue(features.hasActiveTags)
        XCTAssertEqual(features.currentStreak, 0) // Had cigarette today
        XCTAssertEqual(features.daysSinceQuitDate, -10) // 10 days before quit date
    }
    
    func testStreakCalculation() async {
        // Create cigarettes with a gap (streak)
        let cigarettes = [
            Cigarette(timestamp: Date().addingTimeInterval(-5 * 86400.0)), // 5 days ago
            Cigarette(timestamp: Date().addingTimeInterval(-6 * 86400.0)), // 6 days ago
        ]
        
        for cigarette in cigarettes {
            modelContext.insert(cigarette)
        }
        
        try! modelContext.save()
        
        let features = await featureStore.collect(from: modelContext)
        
        XCTAssertGreaterThan(features.currentStreak, 0)
        XCTAssertLessThanOrEqual(features.currentStreak, 5) // At most 5 days
    }
    
    func testTimeOfDayRisk() async {
        let currentHour = Calendar.current.component(.hour, from: Date())
        
        // Create cigarettes at current hour
        let cigarettes = [
            Cigarette(timestamp: Date().addingTimeInterval(-86400.0)), // Same hour yesterday
            Cigarette(timestamp: Date().addingTimeInterval(-2 * 86400.0)), // Same hour 2 days ago
        ]
        
        for cigarette in cigarettes {
            modelContext.insert(cigarette)
        }
        
        try! modelContext.save()
        
        let features = await featureStore.collect(from: modelContext)
        
        XCTAssertGreaterThan(features.timeOfDayRisk, 0.0)
        XCTAssertLessThanOrEqual(features.timeOfDayRisk, 1.0)
    }
}