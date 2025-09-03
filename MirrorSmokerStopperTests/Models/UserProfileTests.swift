//
//  UserProfileTests.swift
//  MirrorSmokerStopperTests
//
//  Created by Claude on 02/09/25.
//

import XCTest
import SwiftData
@testable import MirrorSmokerStopper

@MainActor
final class UserProfileTests: XCTestCase {
    
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    
    override func setUp() async throws {
        try await super.setUp()
        
        let schema = Schema([UserProfile.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [config])
        modelContext = ModelContext(modelContainer)
    }
    
    override func tearDown() async throws {
        modelContainer = nil
        modelContext = nil
        try await super.tearDown()
    }
    
    func testUserProfileInitialization() {
        let profile = UserProfile()
        
        XCTAssertNotEqual(profile.id, UUID())
        XCTAssertEqual(profile.name, "")
        XCTAssertNil(profile.birthDate)
        XCTAssertEqual(profile.weight, 0.0)
        XCTAssertEqual(profile.smokingType, .cigarettes)
        XCTAssertEqual(profile.startedSmokingAge, 18)
        XCTAssertTrue(profile.notificationsEnabled)
        XCTAssertEqual(profile.themePreference, "system")
        XCTAssertNil(profile.quitDate)
        XCTAssertTrue(profile.enableGradualReduction)
        XCTAssertEqual(profile.reductionCurve, .linear)
        XCTAssertEqual(profile.dailyAverage, 0.0)
    }
    
    func testUserProfileCustomInitialization() {
        let customBirthDate = Calendar.current.date(from: DateComponents(year: 1990, month: 5, day: 15))!
        let customQuitDate = Calendar.current.date(byAdding: .day, value: 30, to: Date())!
        
        let profile = UserProfile(
            name: "Test User",
            birthDate: customBirthDate,
            weight: 70.0,
            smokingType: .electronic,
            startedSmokingAge: 20,
            notificationsEnabled: false,
            themePreference: "dark",
            quitDate: customQuitDate,
            enableGradualReduction: false,
            reductionCurve: .exponential,
            dailyAverage: 15.0
        )
        
        XCTAssertEqual(profile.name, "Test User")
        XCTAssertEqual(profile.birthDate, customBirthDate)
        XCTAssertEqual(profile.weight, 70.0)
        XCTAssertEqual(profile.smokingType, .electronic)
        XCTAssertEqual(profile.startedSmokingAge, 20)
        XCTAssertFalse(profile.notificationsEnabled)
        XCTAssertEqual(profile.themePreference, "dark")
        XCTAssertEqual(profile.quitDate, customQuitDate)
        XCTAssertFalse(profile.enableGradualReduction)
        XCTAssertEqual(profile.reductionCurve, .exponential)
        XCTAssertEqual(profile.dailyAverage, 15.0)
    }
    
    func testAgeCalculation() {
        let birthDate = Calendar.current.date(from: DateComponents(year: 1990, month: 1, day: 1))!
        let profile = UserProfile(birthDate: birthDate)
        
        let expectedAge = Calendar.current.component(.year, from: Date()) - 1990
        XCTAssertEqual(profile.age, expectedAge)
        
        // Test with nil birthDate
        let profileNoBirth = UserProfile()
        XCTAssertEqual(profileNoBirth.age, 0)
    }
    
    func testYearsSmokingSinceCalculation() {
        let birthDate = Calendar.current.date(from: DateComponents(year: 1980, month: 1, day: 1))!
        let profile = UserProfile(birthDate: birthDate, startedSmokingAge: 20)
        
        let currentYear = Calendar.current.component(.year, from: Date())
        let expectedYearsSmoking = max(0, (currentYear - 1980) - 20)
        XCTAssertEqual(profile.yearsSmokingSince, expectedYearsSmoking)
    }
    
    func testSmokingTypeEnum() {
        let profile = UserProfile()
        
        // Test default
        XCTAssertEqual(profile.smokingType, .cigarettes)
        
        // Test setting different types
        profile.smokingType = .electronic
        XCTAssertEqual(profile.smokingType, .electronic)
        XCTAssertEqual(profile.smokingTypeRaw, "electronic")
        
        profile.smokingType = .tobacco
        XCTAssertEqual(profile.smokingType, .tobacco)
        XCTAssertEqual(profile.smokingTypeRaw, "tobacco")
        
        // Test invalid raw value fallback
        profile.smokingTypeRaw = "invalid_type"
        XCTAssertEqual(profile.smokingType, .cigarettes)
    }
    
    func testReductionCurveEnum() {
        let profile = UserProfile()
        
        // Test default
        XCTAssertEqual(profile.reductionCurve, .linear)
        
        // Test setting different curves
        profile.reductionCurve = .exponential
        XCTAssertEqual(profile.reductionCurve, .exponential)
        XCTAssertEqual(profile.reductionCurveRaw, "exponential")
        
        // Test invalid raw value fallback
        profile.reductionCurveRaw = "invalid_curve"
        XCTAssertEqual(profile.reductionCurve, .linear)
    }
    
    func testTodayTargetWithoutQuitPlan() {
        let profile = UserProfile(enableGradualReduction: false)
        let dailyAverage = 12.5
        
        let target = profile.todayTarget(dailyAverage: dailyAverage)
        XCTAssertEqual(target, 12) // Should round to Int(dailyAverage)
    }
    
    func testTodayTargetWithQuitPlan() {
        let quitDate = Calendar.current.date(byAdding: .day, value: 30, to: Date())!
        let profile = UserProfile(quitDate: quitDate, enableGradualReduction: true)
        let dailyAverage = 20.0
        
        let target = profile.todayTarget(dailyAverage: dailyAverage)
        
        // Should be less than daily average if there's time until quit date
        XCTAssertLessThan(target, Int(dailyAverage))
        XCTAssertGreaterThanOrEqual(target, 0)
    }
    
    func testTodayTargetPastQuitDate() {
        let pastQuitDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let profile = UserProfile(quitDate: pastQuitDate, enableGradualReduction: true)
        let dailyAverage = 20.0
        
        let target = profile.todayTarget(dailyAverage: dailyAverage)
        XCTAssertEqual(target, 0)
    }
    
    func testDependencyLevelCalculation() {
        let profile = UserProfile()
        
        // Test through todayTarget calculation with different averages
        let lowTarget = profile.todayTarget(dailyAverage: 3.0)
        let moderateTarget = profile.todayTarget(dailyAverage: 8.0)
        let highTarget = profile.todayTarget(dailyAverage: 15.0)
        let severeTarget = profile.todayTarget(dailyAverage: 25.0)
        
        // Without quit plan, should equal average
        XCTAssertEqual(lowTarget, 3)
        XCTAssertEqual(moderateTarget, 8)
        XCTAssertEqual(highTarget, 15)
        XCTAssertEqual(severeTarget, 25)
    }
    
    func testReductionCurveCalculations() {
        let quitDate = Calendar.current.date(byAdding: .day, value: 30, to: Date())!
        let profile = UserProfile(quitDate: quitDate, enableGradualReduction: true)
        
        // Test different curves produce different results
        profile.reductionCurve = .linear
        let linearTarget = profile.todayTarget(dailyAverage: 20.0)
        
        profile.reductionCurve = .exponential
        let exponentialTarget = profile.todayTarget(dailyAverage: 20.0)
        
        profile.reductionCurve = .logarithmic
        let logTarget = profile.todayTarget(dailyAverage: 20.0)
        
        // All should be different and valid
        XCTAssertNotEqual(linearTarget, exponentialTarget)
        XCTAssertNotEqual(linearTarget, logTarget)
        XCTAssertNotEqual(exponentialTarget, logTarget)
        
        XCTAssertGreaterThanOrEqual(linearTarget, 0)
        XCTAssertGreaterThanOrEqual(exponentialTarget, 0)
        XCTAssertGreaterThanOrEqual(logTarget, 0)
    }
    
    func testUserProfilePersistence() throws {
        let profile = UserProfile(name: "Test Persistence")
        modelContext.insert(profile)
        
        try modelContext.save()
        
        let fetchDescriptor = FetchDescriptor<UserProfile>()
        let fetchedProfiles = try modelContext.fetch(fetchDescriptor)
        
        XCTAssertEqual(fetchedProfiles.count, 1)
        XCTAssertEqual(fetchedProfiles.first?.name, "Test Persistence")
    }
    
    func testSmokingTypeDisplayNames() {
        XCTAssertEqual(SmokingType.cigarettes.displayName, NSLocalizedString("smoking.type.cigarettes", comment: ""))
        XCTAssertEqual(SmokingType.electronic.displayName, NSLocalizedString("smoking.type.electronic", comment: ""))
        XCTAssertEqual(SmokingType.tobacco.displayName, NSLocalizedString("smoking.type.tobacco", comment: ""))
    }
    
    func testSmokingTypeIcons() {
        XCTAssertEqual(SmokingType.cigarettes.icon, "lungs.fill")
        XCTAssertEqual(SmokingType.electronic.icon, "battery.100")
        XCTAssertEqual(SmokingType.tobacco.icon, "leaf.fill")
    }
}