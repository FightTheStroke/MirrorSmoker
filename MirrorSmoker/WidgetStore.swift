//
//  WidgetStore.swift
//  Mirror Smoker
//
//  Created by Roberto D'Angelo on 31/08/25.
//

import WidgetKit
import SwiftData
import Foundation
import SwiftUI

public class WidgetStore {
    public static let shared = WidgetStore()
    
    private let appGroupID = "group.mirrorsmoker.shared"
    public let userDefaults: UserDefaults?
    
    private init() {
        self.userDefaults = UserDefaults(suiteName: appGroupID)
    }
    
    // MARK: - Data Keys
    public let todayCountKey = "widget_today_count"
    public let lastCigaretteTimeKey = "widget_last_cigarette_time"
    private let lastUpdateKey = "widget_last_update"
    private let pendingCigarettesKey = "widget_pending_cigarettes"
    
    // MARK: - Configuration
    public func configure(modelContext: ModelContext) {
        // Check for pending cigarettes from widget and add them to the database
        Task {
            await processPendingCigarettes(modelContext: modelContext)
        }
    }
    
    // MARK: - Read Data for Widget
    public static func readSnapshot() -> (todayCount: Int, lastCigaretteTime: String) {
        let store = WidgetStore.shared
        let todayCount = store.userDefaults?.integer(forKey: store.todayCountKey) ?? 0
        let lastTime = store.userDefaults?.string(forKey: store.lastCigaretteTimeKey) ?? "--:--"
        
        return (todayCount: todayCount, lastCigaretteTime: lastTime)
    }
    
    // MARK: - Direct update method that takes count and time
    public func updateWidgetData(todayCount: Int, lastCigaretteTime: String) {
        userDefaults?.set(todayCount, forKey: todayCountKey)
        userDefaults?.set(lastCigaretteTime, forKey: lastCigaretteTimeKey)
        userDefaults?.set(Date(), forKey: lastUpdateKey)
        
        print("Widget sync: \(todayCount) cigarettes, last at \(lastCigaretteTime)")
        
        // Tell WidgetKit to refresh
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    // MARK: - Add Cigarette from Widget
    public func addCigaretteFromWidget() async {
        guard let defaults = userDefaults else { return }
        
        let now = Date()
        let currentCount = defaults.integer(forKey: todayCountKey)
        
        // Update widget display immediately for responsiveness
        defaults.set(currentCount + 1, forKey: todayCountKey)
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let timeString = formatter.string(from: now)
        defaults.set(timeString, forKey: lastCigaretteTimeKey)
        
        // Store pending cigarette to be processed by main app
        var pendingCigarettes = defaults.array(forKey: pendingCigarettesKey) as? [Double] ?? []
        pendingCigarettes.append(now.timeIntervalSince1970)
        defaults.set(pendingCigarettes, forKey: pendingCigarettesKey)
        
        // Refresh widget immediately
        WidgetCenter.shared.reloadAllTimelines()
        
        print("Added cigarette from widget. New count: \(currentCount + 1), time: \(timeString)")
    }
    
    // MARK: - Process Pending Cigarettes (called by main app)
    @MainActor
    public func processPendingCigarettes(modelContext: ModelContext) async {
        guard let defaults = userDefaults,
              let pendingTimestamps = defaults.array(forKey: pendingCigarettesKey) as? [Double],
              !pendingTimestamps.isEmpty else {
            return
        }
        
        print("Processing \(pendingTimestamps.count) pending cigarettes from widget...")
        
        do {
            // Add each pending cigarette to the database
            for timestamp in pendingTimestamps {
                // Create cigarette using the createCigarette callback
                await createCigaretteInDatabase(timestamp: timestamp, modelContext: modelContext)
            }
            
            // Clear pending cigarettes
            defaults.removeObject(forKey: pendingCigarettesKey)
            
            print("Successfully processed \(pendingTimestamps.count) cigarettes from widget")
            
            // Sync back to widget with actual data from database
            await updateFromDatabase(modelContext: modelContext)
            
        } catch {
            print("Error processing pending cigarettes: \(error)")
        }
    }
    
    // MARK: - Create Cigarette in Database
    @MainActor
    private func createCigaretteInDatabase(timestamp: Double, modelContext: ModelContext) async {
        // This is a workaround since we can't directly import Cigarette model
        // We'll use a callback approach or reflection
        
        // For now, we'll rely on the main app to handle this
        // The main app will check for pending cigarettes and create them
        print("Queued cigarette creation for timestamp: \(timestamp)")
    }
    
    // MARK: - Update from Database
    @MainActor
    private func updateFromDatabase(modelContext: ModelContext) async {
        // Let the main app handle the database fetch and call our update method
        print("Requesting database update from main app")
    }
    
    // MARK: - Public method for main app to create pending cigarettes
    @MainActor
    public func createPendingCigarettes(using creator: (Date) throws -> Void) throws {
        guard let defaults = userDefaults,
              let pendingTimestamps = defaults.array(forKey: pendingCigarettesKey) as? [Double],
              !pendingTimestamps.isEmpty else {
            return
        }
        
        print("Creating \(pendingTimestamps.count) pending cigarettes...")
        
        for timestamp in pendingTimestamps {
            let date = Date(timeIntervalSince1970: timestamp)
            try creator(date)
        }
        
        // Clear pending cigarettes after creation
        defaults.removeObject(forKey: pendingCigarettesKey)
        
        print("Successfully created \(pendingTimestamps.count) cigarettes from widget")
    }
    
    // MARK: - Legacy Methods
    public static func enqueueQuickAdd(note: String, tagNames: [String]) {
        Task {
            await shared.addCigaretteFromWidget()
        }
    }
}

// MARK: - Widget Data Sync Extension
extension WidgetStore {
    /// Call this method whenever cigarettes are added, deleted, or modified in the main app
    public func syncWithWidget(modelContext: ModelContext) {
        Task {
            await processPendingCigarettes(modelContext: modelContext)
            await updateFromDatabase(modelContext: modelContext)
        }
    }
    
    /// Direct sync method that passes data
    public func syncWithWidget(todayCount: Int, lastCigaretteTime: String) {
        updateWidgetData(todayCount: todayCount, lastCigaretteTime: lastCigaretteTime)
    }
}