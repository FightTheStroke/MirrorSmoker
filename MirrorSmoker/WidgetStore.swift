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

// Import the Cigarette model
// Since we can't directly import it, we'll work around this limitation

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
    public let pendingCigarettesKey = "widget_pending_cigarettes" // Made public
    private let lastSyncDateKey = "widget_last_sync_date"
    
    // MARK: - Configuration
    public func configure(modelContext: ModelContext) {
        // First time setup - initialize widget data if needed
        initializeWidgetDataIfNeeded()
        
        // Check for pending cigarettes from widget and add them to the database
        Task {
            await processPendingCigarettes(modelContext: modelContext)
        }
    }
    
    // MARK: - Initialize widget data on first run
    private func initializeWidgetDataIfNeeded() {
        guard let defaults = userDefaults else { return }
        
        // Check if this is the first time we're initializing
        let hasInitialized = defaults.bool(forKey: "widget_has_initialized")
        
        if !hasInitialized {
            // First time setup - set clean initial values
            defaults.set(0, forKey: todayCountKey)
            defaults.set("--:--", forKey: lastCigaretteTimeKey)
            defaults.set(Date(), forKey: lastUpdateKey)
            
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            defaults.set(today, forKey: lastSyncDateKey)
            
            // Mark as initialized
            defaults.set(true, forKey: "widget_has_initialized")
            defaults.synchronize()
            
            print("🎯 Widget initialized for first time")
            
            // Force widget refresh
            WidgetCenter.shared.reloadAllTimelines()
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
        
        // Update last sync date to current day
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        userDefaults?.set(today, forKey: lastSyncDateKey)
        
        print("📱 Widget data updated: \(todayCount) cigarettes, last at \(lastCigaretteTime)")
        
        // Force synchronize UserDefaults
        userDefaults?.synchronize()
        
        // Tell WidgetKit to refresh with more aggressive timeline
        WidgetCenter.shared.reloadAllTimelines()
        
        // Also try to reload specific widget if needed
        WidgetCenter.shared.reloadTimelines(ofKind: "MirrorSmokerWidget")
    }
    
    // MARK: - Add Cigarette from Widget (Fixed)
    public func addCigaretteFromWidget() async {
        guard let defaults = userDefaults else { return }
        
        let now = Date()
        
        // Store pending cigarette to be processed by main app
        var pendingCigarettes = defaults.array(forKey: pendingCigarettesKey) as? [Double] ?? []
        pendingCigarettes.append(now.timeIntervalSince1970)
        defaults.set(pendingCigarettes, forKey: pendingCigarettesKey)
        
        // Show immediate feedback with "pending" indicator instead of incrementing count
        // We'll let the main app update the actual count after processing
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let timeString = formatter.string(from: now)
        
        // Update last cigarette time for immediate feedback
        defaults.set(timeString, forKey: lastCigaretteTimeKey)
        
        // Don't increment count here - let the app do it after processing pending items
        
        // Refresh widget to show the updated time
        WidgetCenter.shared.reloadAllTimelines()
        
        print("Added cigarette to widget queue. Time: \(timeString)")
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
        
        // Don't clear here - let the main app handle the full process
        print("Found \(pendingTimestamps.count) cigarettes from widget to be processed by main app")
    }
    
    // MARK: - Check if widget data needs refresh
    public func needsRefresh() -> Bool {
        guard let defaults = userDefaults else { return true }
        
        // Check if we have any pending cigarettes
        if let pendingCigarettes = defaults.array(forKey: pendingCigarettesKey) as? [Double],
           !pendingCigarettes.isEmpty {
            return true
        }
        
        // Check if last sync was from a different day
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if let lastSyncDate = defaults.object(forKey: lastSyncDateKey) as? Date {
            return !calendar.isDate(lastSyncDate, inSameDayAs: today)
        }
        
        return true
    }
    
    // MARK: - Get pending cigarettes count for UI feedback
    public func getPendingCount() -> Int {
        guard let defaults = userDefaults,
              let pendingCigarettes = defaults.array(forKey: pendingCigarettesKey) as? [Double] else {
            return 0
        }
        
        // Only count pending cigarettes from today
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        
        return pendingCigarettes.filter { timestamp in
            let date = Date(timeIntervalSince1970: timestamp)
            return date >= today && date < tomorrow
        }.count
    }
    
    // MARK: - Legacy Methods (Cleaned up)
    public static func enqueueQuickAdd(note: String, tagNames: [String]) {
        Task {
            await shared.addCigaretteFromWidget()
        }
    }
    
    // MARK: - Check initialization status
    public func hasBeenInitialized() -> Bool {
        return userDefaults?.bool(forKey: "widget_has_initialized") ?? false
    }
}

// MARK: - Widget Data Sync Extension (Improved)
extension WidgetStore {
    /// Call this method whenever cigarettes are added, deleted, or modified in the main app
    public func syncWithWidget(modelContext: ModelContext) {
        Task {
            // First process any pending cigarettes from widget
            await processPendingCigarettes(modelContext: modelContext)
            
            // Then update widget with current database state using callback approach
            await updateWidgetUsingCallback(modelContext: modelContext)
        }
    }
    
    /// Direct sync method that passes data
    public func syncWithWidget(todayCount: Int, lastCigaretteTime: String) {
        updateWidgetData(todayCount: todayCount, lastCigaretteTime: lastCigaretteTime)
    }
    
    /// Update widget data using callback approach (since we can't import Cigarette model directly)
    @MainActor
    private func updateWidgetUsingCallback(modelContext: ModelContext) async {
        // The main app will handle the actual database query and call our update method
        // This is a placeholder that will be handled by the ContentView's syncWidget method
        print("Requesting database update from main app")
    }
    
    // MARK: - Initial sync method
    @MainActor
    public func performInitialSync(modelContext: ModelContext) async {
        print("🚀 Performing initial widget sync...")
        
        // Process any pending items first
        await processPendingCigarettes(modelContext: modelContext)
        
        // Then force sync widget with current database state
        syncWithWidget(modelContext: modelContext)
        
        print("✅ Initial widget sync completed")
    }
}