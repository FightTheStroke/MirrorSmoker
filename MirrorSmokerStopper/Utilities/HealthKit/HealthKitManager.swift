//
//  HealthKitManager.swift
//  MirrorSmokerStopper
//
//  Created by Claude on 02/09/25.
//

import Foundation
import HealthKit
import os.log

@MainActor
final class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()
    
    private let store = HKHealthStore()
    private let logger = Logger(subsystem: "com.fightthestroke.MirrorSmokerStopper", category: "HealthKitManager")
    
    init() {}
    
    // MARK: - Availability
    
    func isHealthDataAvailable() -> Bool {
        return HKHealthStore.isHealthDataAvailable()
    }
    
    // MARK: - Authorization
    
    func requestAuthorization() async throws {
        guard isHealthDataAvailable() else {
            logger.info("HealthKit data not available on this device")
            return
        }
        
        var toShare: Set<HKSampleType> = []
        var toRead: Set<HKObjectType> = []
        
        // Conservative, safe set; extend per-OS availability
        if let mindful = HKObjectType.categoryType(forIdentifier: .mindfulSession) {
            toShare.insert(mindful)
            toRead.insert(mindful)
        }
        
        if let sleep = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) {
            toRead.insert(sleep)
        }
        
        if let steps = HKObjectType.quantityType(forIdentifier: .stepCount) {
            toRead.insert(steps)
        }
        
        logger.info("Requesting HealthKit authorization for \(toRead.count) read types and \(toShare.count) share types")
        
        // Note: Clinical records removed as they're not essential for core functionality
        
        // Heart rate for additional context
        if let heartRate = HKObjectType.quantityType(forIdentifier: .heartRate) {
            toRead.insert(heartRate)
        }
        
        do {
            try await store.requestAuthorization(toShare: toShare, read: toRead)
            logger.info("HealthKit authorization completed")
        } catch {
            logger.error("HealthKit authorization failed: \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Data Queries
    
    func latestMindfulSessionDate() async throws -> Date? {
        guard let mindfulType = HKObjectType.categoryType(forIdentifier: .mindfulSession) else {
            return nil
        }
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let _ = HKSampleQuery(
            sampleType: mindfulType,
            predicate: nil,
            limit: 1,
            sortDescriptors: [sortDescriptor]
        ) { _, samples, error in
            if let error = error {
                self.logger.error("Failed to query mindful sessions: \(error.localizedDescription)")
                return
            }
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let wrappedQuery = HKSampleQuery(
                sampleType: mindfulType,
                predicate: nil,
                limit: 1,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: samples?.first?.startDate)
                }
            }
            store.execute(wrappedQuery)
        }
    }
    
    func didUseNRTRecently() async throws -> Bool {
        // Clinical records access removed - this method now returns false
        // NRT detection could be implemented through user input instead
        logger.info("NRT detection disabled - clinical records not accessed")
        return false
    }
    
    func getStepCountLast3Hours() async throws -> Double {
        guard let stepsType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            logger.warning("Step count type not available")
            return 0.0
        }
        
        // Check authorization status first
        let authStatus = store.authorizationStatus(for: stepsType)
        guard authStatus == .sharingAuthorized else {
            logger.info("Step count authorization not granted (status: \(authStatus.rawValue))")
            return 0.0
        }
        
        let threeHoursAgo = Date().addingTimeInterval(-3 * 3600)
        let predicate = HKQuery.predicateForSamples(
            withStart: threeHoursAgo,
            end: Date(),
            options: .strictStartDate
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: stepsType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                if let error = error {
                    self.logger.error("Failed to query step count: \(error.localizedDescription)")
                    continuation.resume(returning: 0.0)
                    return
                }
                
                let steps = result?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0.0
                self.logger.debug("Retrieved step count: \(steps)")
                continuation.resume(returning: steps)
            }
            store.execute(query)
        }
    }
    
    func didSleepPoorlyLastNight() async throws -> Bool {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            logger.warning("Sleep analysis type not available")
            return false
        }
        
        // Check authorization status first
        let authStatus = store.authorizationStatus(for: sleepType)
        guard authStatus == .sharingAuthorized else {
            logger.info("Sleep data authorization not granted (status: \(authStatus.rawValue))")
            return false
        }
        
        // Check sleep from yesterday evening to this morning
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let yesterdayEvening = calendar.date(bySettingHour: 20, minute: 0, second: 0, of: yesterday)!
        
        let predicate = HKQuery.predicateForSamples(
            withStart: yesterdayEvening,
            end: today.addingTimeInterval(10 * 3600), // Until 10 AM today
            options: .strictStartDate
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: sleepType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, samples, error in
                if let error = error {
                    self.logger.error("Failed to query sleep data: \(error.localizedDescription)")
                    continuation.resume(returning: false)
                    return
                }
                
                // Calculate total sleep duration
                let totalSleepMinutes = samples?.compactMap { sample in
                    guard let sleepSample = sample as? HKCategorySample,
                          sleepSample.value == HKCategoryValueSleepAnalysis.asleepCore.rawValue ||
                          sleepSample.value == HKCategoryValueSleepAnalysis.asleepDeep.rawValue ||
                          sleepSample.value == HKCategoryValueSleepAnalysis.asleepREM.rawValue else {
                        return nil
                    }
                    return sleepSample.endDate.timeIntervalSince(sleepSample.startDate) / 60.0
                }.reduce(0, +) ?? 0.0
                
                // Consider < 6 hours as poor sleep
                let poorSleep = totalSleepMinutes < 360
                continuation.resume(returning: poorSleep)
            }
            store.execute(query)
        }
    }
    
    // MARK: - Writing Data
    
    @MainActor
    func saveMindfulSession(duration: TimeInterval) async throws {
        guard let mindfulType = HKObjectType.categoryType(forIdentifier: .mindfulSession) else {
            throw HealthKitError.typeNotAvailable
        }
        
        let startDate = Date().addingTimeInterval(-duration)
        let endDate = Date()
        
        let mindfulSample = HKCategorySample(
            type: mindfulType,
            value: HKCategoryValue.notApplicable.rawValue,
            start: startDate,
            end: endDate
        )
        
        try await store.save(mindfulSample)
        logger.info("Saved mindful session of \(duration) seconds")
    }
    
    // MARK: - Additional Methods for AI Features
    
    func getSleepQuality() async throws -> Double {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            return 0.7 // Default sleep quality
        }
        
        let oneDayAgo = Date().addingTimeInterval(-24 * 3600)
        let predicate = HKQuery.predicateForSamples(
            withStart: oneDayAgo,
            end: Date(),
            options: .strictStartDate
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: sleepType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    // Simple sleep quality calculation based on sleep duration
                    let totalSleepMinutes = samples?.compactMap { sample in
                        sample.endDate.timeIntervalSince(sample.startDate) / 60
                    }.reduce(0, +) ?? 0
                    
                    let quality = min(1.0, max(0.0, totalSleepMinutes / (8 * 60))) // Normalize to 8 hours
                    continuation.resume(returning: quality)
                }
            }
            store.execute(query)
        }
    }
    
    func getStepsLast3Hours() async throws -> Double {
        return try await getStepCountLast3Hours()
    }
    
    func getMindfulSessionsToday() async throws -> Int {
        guard let mindfulType = HKObjectType.categoryType(forIdentifier: .mindfulSession) else {
            return 0
        }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: Date(),
            options: .strictStartDate
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: mindfulType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: samples?.count ?? 0)
                }
            }
            store.execute(query)
        }
    }
}

// MARK: - Errors

enum HealthKitError: LocalizedError {
    case typeNotAvailable
    case authorizationDenied
    case dataNotAvailable
    
    var errorDescription: String? {
        switch self {
        case .typeNotAvailable:
            return "The requested HealthKit data type is not available"
        case .authorizationDenied:
            return "HealthKit authorization was denied"
        case .dataNotAvailable:
            return "HealthKit data is not available on this device"
        }
    }
}