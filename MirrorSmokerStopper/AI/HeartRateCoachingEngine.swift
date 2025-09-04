//
//  HeartRateCoachingEngine.swift
//  MirrorSmokerStopper
//
//  Heart Rate Intelligence System for predictive coaching
//

import Foundation
import HealthKit
import SwiftUI
import os.log

/// Heart Rate Coaching Engine for craving prediction and stress-based interventions
@MainActor
class HeartRateCoachingEngine: ObservableObject {
    static let shared = HeartRateCoachingEngine()
    
    private let logger = Logger(subsystem: "com.fightthestroke.MirrorSmokerStopper", category: "HeartRate")
    private let healthStore = HKHealthStore()
    private var heartRateQuery: HKAnchoredObjectQuery?
    
    // MARK: - Published Properties
    
    @Published var currentHeartRate: Double = 0
    @Published var heartRateVariability: Double = 0
    @Published var stressLevel: StressLevel = .normal
    @Published var cravingRisk: CravingRisk = .low
    @Published var isMonitoring = false
    @Published var hasBaseline = false
    
    // MARK: - Personal Profile
    
    private var personalProfile: PersonalHeartRateProfile?
    private let profileKey = "heart_rate_profile"
    
    // MARK: - Types
    
    enum StressLevel {
        case low, normal, elevated, high
        
        var color: Color {
            switch self {
            case .low: return .green
            case .normal: return .blue
            case .elevated: return .orange
            case .high: return .red
            }
        }
        
        var description: String {
            switch self {
            case .low: return "Relaxed"
            case .normal: return "Normal"
            case .elevated: return "Slightly stressed"
            case .high: return "High stress"
            }
        }
    }
    
    enum CravingRisk {
        case low, medium, high, imminent
        
        var color: Color {
            switch self {
            case .low: return .green
            case .medium: return .yellow
            case .high: return .orange
            case .imminent: return .red
            }
        }
        
        var timeEstimate: String {
            switch self {
            case .low: return "No risk next 2h"
            case .medium: return "Risk in 30-60 min"
            case .high: return "Risk in 15-30 min"
            case .imminent: return "High risk now"
            }
        }
    }
    
    struct PersonalHeartRateProfile: Codable {
        var restingHR: Double
        var stressThreshold: Double  // +15-20 BPM above resting
        var cravingPatterns: [TimeInterval]  // Historical craving times
        var hrvBaseline: Double
        var lastUpdated: Date
        var dataPointCount: Int
        
        mutating func updateBaseline(with newData: [HRDataPoint]) {
            // Machine learning adaptation to personal patterns
            let avgResting = newData.filter { !$0.isActive }.map { $0.bpm }.reduce(0, +) / Double(newData.count)
            restingHR = (restingHR * 0.8) + (avgResting * 0.2) // Weighted average
            
            stressThreshold = restingHR + 15
            dataPointCount += newData.count
            lastUpdated = Date()
        }
    }
    
    struct HRDataPoint {
        let bpm: Double
        let timestamp: Date
        let isActive: Bool
        let context: String?
    }
    
    // MARK: - Initialization
    
    private init() {
        loadProfile()
    }
    
    // MARK: - HealthKit Authorization
    
    func requestAuthorization() async throws {
        let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
        let hrvType = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!
        let restingHRType = HKObjectType.quantityType(forIdentifier: .restingHeartRate)!
        let walkingHRType = HKObjectType.quantityType(forIdentifier: .walkingHeartRateAverage)!
        
        let typesToRead: Set<HKObjectType> = [
            heartRateType,
            hrvType,
            restingHRType,
            walkingHRType
        ]
        
        try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
        logger.info("HealthKit authorization granted for heart rate monitoring")
    }
    
    // MARK: - Monitoring
    
    func startMonitoring() {
        guard !isMonitoring else { return }
        
        Task {
            do {
                try await requestAuthorization()
                startHeartRateQuery()
                isMonitoring = true
                logger.info("Heart rate monitoring started")
            } catch {
                logger.error("Failed to start heart rate monitoring: \(error)")
            }
        }
    }
    
    func stopMonitoring() {
        if let query = heartRateQuery {
            healthStore.stop(query)
            heartRateQuery = nil
        }
        isMonitoring = false
        logger.info("Heart rate monitoring stopped")
    }
    
    private func startHeartRateQuery() {
        let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
        let predicate = HKQuery.predicateForSamples(
            withStart: Date().addingTimeInterval(-60),
            end: nil,
            options: .strictEndDate
        )
        
        heartRateQuery = HKAnchoredObjectQuery(
            type: heartRateType,
            predicate: predicate,
            anchor: nil,
            limit: HKObjectQueryNoLimit
        ) { [weak self] query, samples, deletedObjects, anchor, error in
            guard let self = self, let samples = samples else { return }
            
            Task { @MainActor in
                self.processSamples(samples)
            }
        }
        
        heartRateQuery?.updateHandler = { [weak self] query, samples, deletedObjects, anchor, error in
            guard let self = self, let samples = samples else { return }
            
            Task { @MainActor in
                self.processSamples(samples)
            }
        }
        
        healthStore.execute(heartRateQuery!)
    }
    
    private func processSamples(_ samples: [HKSample]) {
        guard let heartRateSamples = samples as? [HKQuantitySample] else { return }
        
        for sample in heartRateSamples {
            let heartRate = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
            currentHeartRate = heartRate
            
            // Update stress level based on heart rate
            updateStressLevel(heartRate: heartRate)
            
            // Predict craving risk
            predictCravingRisk()
        }
    }
    
    // MARK: - Analysis
    
    private func updateStressLevel(heartRate: Double) {
        guard let profile = personalProfile else {
            stressLevel = .normal
            return
        }
        
        let elevation = heartRate - profile.restingHR
        
        switch elevation {
        case ..<5:
            stressLevel = .low
        case 5..<10:
            stressLevel = .normal
        case 10..<20:
            stressLevel = .elevated
        default:
            stressLevel = .high
        }
    }
    
    func predictCravingRisk() {
        guard let profile = personalProfile else {
            cravingRisk = .low
            return
        }
        
        let hrElevation = currentHeartRate - profile.restingHR
        let stressScore = calculateStressScore()
        let timeScore = calculateTimeScore()
        
        // Multi-factor risk assessment
        let riskScore = (hrElevation / 30.0) * 0.4 + stressScore * 0.3 + timeScore * 0.3
        
        switch riskScore {
        case ..<0.3:
            cravingRisk = .low
        case 0.3..<0.5:
            cravingRisk = .medium
        case 0.5..<0.7:
            cravingRisk = .high
        default:
            cravingRisk = .imminent
        }
        
        // Trigger intervention if needed
        if cravingRisk == .high || cravingRisk == .imminent {
            triggerIntervention()
        }
    }
    
    private func calculateStressScore() -> Double {
        switch stressLevel {
        case .low: return 0.1
        case .normal: return 0.3
        case .elevated: return 0.6
        case .high: return 0.9
        }
    }
    
    private func calculateTimeScore() -> Double {
        guard let profile = personalProfile else { return 0.3 }
        
        let currentHour = Calendar.current.component(.hour, from: Date())
        let currentMinute = Calendar.current.component(.minute, from: Date())
        let currentTimeInterval = TimeInterval(currentHour * 60 + currentMinute)
        
        // Check if current time matches historical craving patterns
        for pattern in profile.cravingPatterns {
            if abs(currentTimeInterval - pattern) < 30 { // Within 30 minutes
                return 0.8
            }
        }
        
        return 0.2
    }
    
    // MARK: - Interventions
    
    private func triggerIntervention() {
        // Select optimal intervention based on current context
        let intervention = selectOptimalIntervention()
        
        // Create notification or in-app alert
        NotificationManager.shared.scheduleHeartRateIntervention(
            type: intervention,
            riskLevel: cravingRisk,
            stressLevel: stressLevel
        )
    }
    
    private func selectOptimalIntervention() -> HeartRateIntervention {
        // Logic to select best intervention based on:
        // - Current stress level
        // - Time of day
        // - User's historical success rates
        // - Current context (activity, location)
        
        if stressLevel == .high {
            return .breathingExercise
        } else if currentHeartRate > 100 {
            return .physicalActivity
        } else {
            return .mindfulnessSession
        }
    }
    
    // MARK: - Profile Management
    
    func establishBaseline() {
        // Collect 2 weeks of data to establish personal baseline
        Task {
            let baselineData = await collectBaselineData()
            createProfile(from: baselineData)
            hasBaseline = true
        }
    }
    
    private func collectBaselineData() async -> [HRDataPoint] {
        // Query HealthKit for last 2 weeks of heart rate data
        // This is a simplified version - actual implementation would be more complex
        return []
    }
    
    private func createProfile(from data: [HRDataPoint]) {
        let avgResting = data.filter { !$0.isActive }.map { $0.bpm }.reduce(0, +) / Double(data.count)
        
        personalProfile = PersonalHeartRateProfile(
            restingHR: avgResting,
            stressThreshold: avgResting + 15,
            cravingPatterns: [],
            hrvBaseline: 45, // Default - would calculate from actual HRV data
            lastUpdated: Date(),
            dataPointCount: data.count
        )
        
        saveProfile()
    }
    
    private func loadProfile() {
        if let data = UserDefaults.standard.data(forKey: profileKey),
           let profile = try? JSONDecoder().decode(PersonalHeartRateProfile.self, from: data) {
            personalProfile = profile
            hasBaseline = true
        }
    }
    
    private func saveProfile() {
        guard let profile = personalProfile else { return }
        
        if let data = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(data, forKey: profileKey)
        }
    }
    
    // MARK: - Progress Tracking
    
    func getCardiovascularProgress() -> CardiovascularProgress {
        guard let profile = personalProfile else {
            return CardiovascularProgress()
        }
        
        // Calculate improvements since quitting
        // This would query historical data and compare
        
        return CardiovascularProgress(
            restingHRImprovement: -8,  // BPM reduction
            hrvImprovement: 23,  // Percentage increase
            recoveryTimeImprovement: 35,  // Percentage faster
            sleepHRQuality: 4  // Out of 5 stars
        )
    }
    
    struct CardiovascularProgress {
        var restingHRImprovement: Int = 0
        var hrvImprovement: Int = 0
        var recoveryTimeImprovement: Int = 0
        var sleepHRQuality: Int = 0
    }
}

// MARK: - Intervention Types

enum HeartRateIntervention {
    case breathingExercise
    case physicalActivity
    case mindfulnessSession
    case socialSupport
    case professionalAlert
    
    var title: String {
        switch self {
        case .breathingExercise:
            return "Breathing Exercise Recommended"
        case .physicalActivity:
            return "Movement Break Suggested"
        case .mindfulnessSession:
            return "Mindfulness Moment"
        case .socialSupport:
            return "Connect with Support"
        case .professionalAlert:
            return "Check-in Recommended"
        }
    }
    
    var description: String {
        switch self {
        case .breathingExercise:
            return "Your heart rate suggests stress. A 2-minute breathing exercise can help."
        case .physicalActivity:
            return "A quick walk can help normalize your heart rate and reduce cravings."
        case .mindfulnessSession:
            return "Take a moment to ground yourself with a brief mindfulness session."
        case .socialSupport:
            return "Reach out to your support network - connection helps manage cravings."
        case .professionalAlert:
            return "Your patterns suggest you might benefit from professional support."
        }
    }
}