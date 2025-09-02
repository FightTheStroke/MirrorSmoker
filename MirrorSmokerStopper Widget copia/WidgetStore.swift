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
import os.log

public class WidgetStore {
    public static let shared = WidgetStore()
    private static let logger = Logger(subsystem: "com.fightthestroke.MirrorSmokerStopper", category: "WidgetStore")
    
    // Torniamo all'App Group originale
    private let appGroupID = "group.org.mirror-labs.mirrorsmoker"
    public let userDefaults: UserDefaults?
    
    // Fallback su UserDefaults standard se App Group non disponibile
    private let fallbackDefaults = UserDefaults.standard
    
    private init() {
        // Prova a creare UserDefaults con App Group
        if let groupDefaults = UserDefaults(suiteName: appGroupID) {
            self.userDefaults = groupDefaults
            Self.logger.info("✅ Using App Group: \(appGroupID)")
        } else {
            self.userDefaults = nil
            Self.logger.warning("⚠️ App Group not available, using fallback")
        }
    }
    
    // MARK: - Computed property per UserDefaults attivi
    private var activeDefaults: UserDefaults {
        return userDefaults ?? fallbackDefaults
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
        let hasInitialized = activeDefaults.bool(forKey: "widget_has_initialized")
        
        if !hasInitialized {
            activeDefaults.set(0, forKey: todayCountKey)
            activeDefaults.set("--:--", forKey: lastCigaretteTimeKey)
            activeDefaults.set(Date(), forKey: lastUpdateKey)
            
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            activeDefaults.set(today, forKey: lastSyncDateKey)
            
            activeDefaults.set(true, forKey: "widget_has_initialized")
            activeDefaults.synchronize()
            
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    // MARK: - Read Data for Widget
    public static func readSnapshot() -> (todayCount: Int, lastCigaretteTime: String) {
        let store = WidgetStore.shared
        let todayCount = store.activeDefaults.integer(forKey: store.todayCountKey)
        let lastTime = store.activeDefaults.string(forKey: store.lastCigaretteTimeKey) ?? "--:--"
        
        return (todayCount: todayCount, lastCigaretteTime: lastTime)
    }
    
    // MARK: - Update widget data
    public func updateWidgetData(todayCount: Int, lastCigaretteTime: String) {
        activeDefaults.set(todayCount, forKey: todayCountKey)
        activeDefaults.set(lastCigaretteTime, forKey: lastCigaretteTimeKey)
        activeDefaults.set(Date(), forKey: lastUpdateKey)
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        activeDefaults.set(today, forKey: lastSyncDateKey)
        
        activeDefaults.synchronize()
        
        DispatchQueue.main.async {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    // MARK: - Add Cigarette from Widget
    public func addCigaretteFromWidget() async {
        let now = Date()
        
        var pendingCigarettes = activeDefaults.array(forKey: pendingCigarettesKey) as? [Double] ?? []
        pendingCigarettes.append(now.timeIntervalSince1970)
        activeDefaults.set(pendingCigarettes, forKey: pendingCigarettesKey)
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let timeString = formatter.string(from: now)
        
        activeDefaults.set(timeString, forKey: lastCigaretteTimeKey)
        activeDefaults.synchronize()
        
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    // MARK: - Process Pending Cigarettes
    @MainActor
    public func processPendingCigarettes(modelContext: ModelContext) async {
        guard let pendingTimestamps = activeDefaults.array(forKey: pendingCigarettesKey) as? [Double],
              !pendingTimestamps.isEmpty else {
            return
        }
        
        // Don't clear here - let the main app handle the full process
    }
    
    // MARK: - Check if widget data needs refresh
    public func needsRefresh() -> Bool {
        if let pendingCigarettes = activeDefaults.array(forKey: pendingCigarettesKey) as? [Double],
           !pendingCigarettes.isEmpty {
            return true
        }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if let lastSyncDate = activeDefaults.object(forKey: lastSyncDateKey) as? Date {
            return !calendar.isDate(lastSyncDate, inSameDayAs: today)
        }
        
        return true
    }
    
    // MARK: - Get pending cigarettes count for UI feedback
    public func getPendingCount() -> Int {
        guard let pendingCigarettes = activeDefaults.array(forKey: pendingCigarettesKey) as? [Double] else {
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
        return activeDefaults.bool(forKey: "widget_has_initialized")
    }
    
    // MARK: - Initial sync method
    @MainActor
    public func performInitialSync(modelContext: ModelContext) async {
        await processPendingCigarettes(modelContext: modelContext)
        syncWithWidget(modelContext: modelContext)
    }
    
    // MARK: - Public access methods
    public var safeDefaults: UserDefaults {
        return activeDefaults
    }
    
    public func clearPendingData() {
        activeDefaults.removeObject(forKey: pendingCigarettesKey)
        activeDefaults.synchronize()
    }
    
    public func resetWidgetData() {
        activeDefaults.removeObject(forKey: todayCountKey)
        activeDefaults.removeObject(forKey: lastCigaretteTimeKey)
        activeDefaults.removeObject(forKey: pendingCigarettesKey)
        activeDefaults.synchronize()
        WidgetCenter.shared.reloadAllTimelines()
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
    public func syncWithWidget(modelContext: ModelContext) {
        Task {
            await processPendingCigarettes(modelContext: modelContext)
        }
    }
    
    public func syncWithWidget(todayCount: Int, lastCigaretteTime: String) {
        updateWidgetData(todayCount: todayCount, lastCigaretteTime: lastCigaretteTime)
    }
}