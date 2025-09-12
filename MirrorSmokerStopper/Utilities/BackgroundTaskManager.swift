//
//  BackgroundTaskManager.swift
//  MirrorSmokerStopper
//
//  Manages background tasks for AI Coach notifications
//

import Foundation
import BackgroundTasks
import SwiftData
import os.log

@MainActor
final class BackgroundTaskManager: ObservableObject {
    static let shared = BackgroundTaskManager()
    
    private let logger = Logger(subsystem: "com.fightthestroke.MirrorSmokerStopper", category: "BackgroundTaskManager")
    
    // Task identifiers
    private let jitaiTaskIdentifier = "com.fightthestroke.MirrorSmokerStopper.jitai-evaluation"
    private let refreshTaskIdentifier = "com.fightthestroke.MirrorSmokerStopper.app-refresh"
    
    private init() {}
    
    // MARK: - Setup
    
    func setupBackgroundTasks() {
        // Register background tasks
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: jitaiTaskIdentifier,
            using: nil
        ) { task in
            self.handleJITAIEvaluation(task: task as! BGProcessingTask)
        }
        
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: refreshTaskIdentifier,
            using: nil
        ) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
        
        logger.info("Background tasks registered")
    }
    
    // MARK: - Scheduling
    
    func scheduleJITAIEvaluation() {
        let request = BGProcessingTaskRequest(identifier: jitaiTaskIdentifier)
        request.requiresNetworkConnectivity = false
        request.requiresExternalPower = false
        
        // Schedule for 2 hours from now
        request.earliestBeginDate = Date(timeIntervalSinceNow: 2 * 3600)
        
        do {
            try BGTaskScheduler.shared.submit(request)
            logger.info("JITAI evaluation scheduled for 2 hours from now")
        } catch {
            logger.error("Failed to schedule JITAI evaluation: \(error.localizedDescription)")
        }
    }
    
    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: refreshTaskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 4 * 3600) // 4 hours
        
        do {
            try BGTaskScheduler.shared.submit(request)
            logger.info("App refresh scheduled")
        } catch {
            logger.error("Failed to schedule app refresh: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Task Handlers
    
    private func handleJITAIEvaluation(task: BGProcessingTask) {
        logger.info("Starting JITAI background evaluation")
        
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
        
        Task {
            // Evaluate and potentially send notification
            await JITAIPlanner.shared.evaluateAndNotify()
            
            // Schedule next evaluation
            scheduleJITAIEvaluation()
            
            task.setTaskCompleted(success: true)
        }
    }
    
    private func handleAppRefresh(task: BGAppRefreshTask) {
        logger.info("Starting app refresh")
        
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
        
        Task {
            // Quick evaluation for immediate risks
            await evaluateImmediateRisks()
            
            // Schedule next refresh
            scheduleAppRefresh()
            
            task.setTaskCompleted(success: true)
        }
    }
    
    // MARK: - Smart Trigger Points
    
    func evaluateAfterCigarette() {
        Task {
            // Wait a bit to not be too intrusive
            try? await Task.sleep(nanoseconds: 30_000_000_000) // 30 seconds
            
            // Check if support is needed
            await JITAIPlanner.shared.evaluateAndNotify()
        }
    }
    
    func evaluateAtRiskTime() {
        Task {
            // Check if this is a high-risk time based on history
            await JITAIPlanner.shared.evaluateAndNotify()
        }
    }
    
    private func evaluateImmediateRisks() async {
        // Quick check for immediate intervention needs
        let hour = Calendar.current.component(.hour, from: Date())
        
        // High risk times (based on common patterns)
        let highRiskHours = [9, 11, 14, 16, 20] // Morning coffee, mid-morning, after lunch, afternoon, evening
        
        if highRiskHours.contains(hour) {
            await JITAIPlanner.shared.evaluateAndNotify()
        }
    }
}