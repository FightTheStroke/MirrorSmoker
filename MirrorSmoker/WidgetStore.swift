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
    
    // MARK: - Configuration
    public func configure(modelContext: ModelContext) {
        // Update widget data when app launches
        Task {
            await updateWidgetData(from: modelContext)
        }
    }
    
    // MARK: - Read Data for Widget
    public static func readSnapshot() -> (todayCount: Int, lastCigaretteTime: String) {
        let store = WidgetStore.shared
        let todayCount = store.userDefaults?.integer(forKey: store.todayCountKey) ?? 0
        let lastTime = store.userDefaults?.string(forKey: store.lastCigaretteTimeKey) ?? "--:--"
        
        return (todayCount: todayCount, lastCigaretteTime: lastTime)
    }
    
    // MARK: - Update Widget Data from Main App (Simplified for now)
    @MainActor
    public func updateWidgetData(from modelContext: ModelContext) async {
        // For now, just set some basic data to avoid SwiftData issues in widget context
        // TODO: Implement proper shared container when App Groups are configured
        
        userDefaults?.set(0, forKey: todayCountKey)
        userDefaults?.set("--:--", forKey: lastCigaretteTimeKey)
        userDefaults?.set(Date(), forKey: lastUpdateKey)
        
        // Tell WidgetKit to refresh
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    // MARK: - Add Cigarette from Widget
    public func addCigaretteFromWidget() async {
        // For now, increment count locally and update widget
        guard let defaults = userDefaults else { return }
        
        let currentCount = defaults.integer(forKey: todayCountKey)
        defaults.set(currentCount + 1, forKey: todayCountKey)
        
        // Update last cigarette time
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        defaults.set(formatter.string(from: Date()), forKey: lastCigaretteTimeKey)
        
        // Refresh widget
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
    /// Call this method whenever cigarettes are added, deleted, or modified in the main app
    public func syncWithWidget(modelContext: ModelContext) {
        Task {
            await updateWidgetData(from: modelContext)
        }
    }
}