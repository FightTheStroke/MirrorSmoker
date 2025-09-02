//
//  WidgetDataProvider.swift
//  HomeWidget
//
//  Created by Roberto D'Angelo on 02/09/25.
//

import Foundation
import WidgetKit

// We need to access the shared WidgetStore from the main app
// This requires using the App Group container
public class WidgetStore {
    public static let shared = WidgetStore()
    
    private let appGroupID = "group.org.mirror-labs.mirrorsmoker"
    public let userDefaults: UserDefaults?
    
    private let fallbackDefaults = UserDefaults.standard
    
    private init() {
        if let groupDefaults = UserDefaults(suiteName: appGroupID) {
            self.userDefaults = groupDefaults
        } else {
            self.userDefaults = nil
        }
    }
    
    private var activeDefaults: UserDefaults {
        return userDefaults ?? fallbackDefaults
    }
    
    public let todayCountKey = "widget_today_count"
    public let lastCigaretteTimeKey = "widget_last_cigarette_time"
    
    public static func readSnapshot() -> (todayCount: Int, lastCigaretteTime: String) {
        let store = WidgetStore.shared
        let todayCount = store.activeDefaults.integer(forKey: store.todayCountKey)
        let lastTime = store.activeDefaults.string(forKey: store.lastCigaretteTimeKey) ?? "--:--"
        
        return (todayCount: todayCount, lastCigaretteTime: lastTime)
    }
    
    public func addCigaretteFromWidget() async {
        let now = Date()
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let timeString = formatter.string(from: now)
        
        let currentCount = activeDefaults.integer(forKey: todayCountKey)
        activeDefaults.set(currentCount + 1, forKey: todayCountKey)
        activeDefaults.set(timeString, forKey: lastCigaretteTimeKey)
        activeDefaults.synchronize()
        
        WidgetCenter.shared.reloadAllTimelines()
    }
}

// MARK: - Widget Today Stats
public struct WidgetTodayStats {
    public let todayCount: Int
    public let dailyAverage: Double
    public let lastCigaretteTime: Date?
    
    public init(todayCount: Int, dailyAverage: Double, lastCigaretteTime: Date?) {
        self.todayCount = todayCount
        self.dailyAverage = dailyAverage
        self.lastCigaretteTime = lastCigaretteTime
    }
    
    // Computed property for status color based on cigarette count
    public var statusColor: String {
        if todayCount == 0 {
            return "#34C759" // Green
        } else if todayCount <= 5 {
            return "#007AFF" // Blue
        } else if todayCount <= 10 {
            return "#FF9500" // Orange
        } else {
            return "#FF3B30" // Red
        }
    }
    
    // Computed property for formatted last cigarette time
    public var lastCigaretteFormatted: String {
        guard let lastCigaretteTime = lastCigaretteTime else {
            return NSLocalizedString("widget.never", comment: "Never smoked today")
        }
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: lastCigaretteTime)
    }
}

// MARK: - Widget Data Provider
public class WidgetDataProvider {
    
    public init() {}
    
    public func getTodayStats() async -> WidgetTodayStats {
        // Read from the widget store
        let snapshot = WidgetStore.readSnapshot()
        
        // Get today count from snapshot
        let todayCount = snapshot.todayCount
        
        // For daily average, we'll use a placeholder value
        let dailyAverage: Double = 8.5
        
        // For last cigarette time, we don't have actual Date object, just string
        let lastCigaretteTime: Date? = nil
        
        return WidgetTodayStats(
            todayCount: todayCount,
            dailyAverage: dailyAverage,
            lastCigaretteTime: lastCigaretteTime
        )
    }
    
    public func addCigaretteFromWidget() async -> Bool {
        // Add cigarette using the widget store
        await WidgetStore.shared.addCigaretteFromWidget()
        return true
    }
}