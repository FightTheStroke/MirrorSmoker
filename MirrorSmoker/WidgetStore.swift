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
    public let pendingCigarettesKey = "widget_pending_cigarettes"
    private let lastSyncDateKey = "widget_last_sync_date"
    
    // MARK: - Configuration
    public func configure(modelContext: ModelContext) {
        initializeWidgetDataIfNeeded()
        
        Task {
            await processPendingCigarettes(modelContext: modelContext)
        }
    }
    
    // MARK: - Initialize widget data on first run
    private func initializeWidgetDataIfNeeded() {
        guard let defaults = userDefaults else { return }
        
        let hasInitialized = defaults.bool(forKey: "widget_has_initialized")
        
        if !hasInitialized {
            defaults.set(0, forKey: todayCountKey)
            defaults.set("--:--", forKey: lastCigaretteTimeKey)
            defaults.set(Date(), forKey: lastUpdateKey)
            
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            defaults.set(today, forKey: lastSyncDateKey)
            
            defaults.set(true, forKey: "widget_has_initialized")
            defaults.synchronize()
            
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
    
    // MARK: - Update widget data
    public func updateWidgetData(todayCount: Int, lastCigaretteTime: String) {
        userDefaults?.set(todayCount, forKey: todayCountKey)
        userDefaults?.set(lastCigaretteTime, forKey: lastCigaretteTimeKey)
        userDefaults?.set(Date(), forKey: lastUpdateKey)
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        userDefaults?.set(today, forKey: lastSyncDateKey)
        
        userDefaults?.synchronize()
        
        DispatchQueue.main.async {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    // MARK: - Add Cigarette from Widget
    public func addCigaretteFromWidget() async {
        guard let defaults = userDefaults else { return }
        
        let now = Date()
        
        var pendingCigarettes = defaults.array(forKey: pendingCigarettesKey) as? [Double] ?? []
        pendingCigarettes.append(now.timeIntervalSince1970)
        defaults.set(pendingCigarettes, forKey: pendingCigarettesKey)
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let timeString = formatter.string(from: now)
        
        defaults.set(timeString, forKey: lastCigaretteTimeKey)
        
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    // MARK: - Process Pending Cigarettes
    @MainActor
    public func processPendingCigarettes(modelContext: ModelContext) async {
        guard let defaults = userDefaults,
              let pendingTimestamps = defaults.array(forKey: pendingCigarettesKey) as? [Double],
              !pendingTimestamps.isEmpty else {
            return
        }
        
        // Don't clear here - let the main app handle the full process
    }
    
    // MARK: - Check if widget data needs refresh
    public func needsRefresh() -> Bool {
        guard let defaults = userDefaults else { return true }
        
        if let pendingCigarettes = defaults.array(forKey: pendingCigarettesKey) as? [Double],
           !pendingCigarettes.isEmpty {
            return true
        }
        
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
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        
        return pendingCigarettes.filter { timestamp in
            let date = Date(timeIntervalSince1970: timestamp)
            return date >= today && date < tomorrow
        }.count
    }
    
    // MARK: - Check initialization status
    public func hasBeenInitialized() -> Bool {
        return userDefaults?.bool(forKey: "widget_has_initialized") ?? false
    }
    
    // MARK: - Initial sync method
    @MainActor
    public func performInitialSync(modelContext: ModelContext) async {
        await processPendingCigarettes(modelContext: modelContext)
        syncWithWidget(modelContext: modelContext)
    }
}

// MARK: - Widget Data Sync Extension
extension WidgetStore {
    public func syncWithWidget(modelContext: ModelContext) {
        Task {
            await processPendingCigarettes(modelContext: modelContext)
        }
    }
    
    public func syncWithWidget(todayCount: Int, lastCigaretteTime: String) {
        updateWidgetData(todayCount: todayCount, lastCigaretteTime: lastCigaretteTime)
    }
}