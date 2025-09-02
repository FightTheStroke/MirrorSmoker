//
//  WidgetDataProvider.swift
//  HomeWidget
//
//  Created by Roberto D'Angelo on 02/09/25.
//

import Foundation
import WidgetKit
import SwiftData

// We need to access the shared WidgetStore from the main app
// This requires using the App Group container
public class WidgetStore {
    public static let shared = WidgetStore()
    
    private let appGroupID = "group.com.fightthestroke.mirrorsmoker"
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
        // Try to get real data from shared model container
        if let stats = await getRealTodayStats() {
            return stats
        }
        
        // Fallback to widget store for basic data
        let snapshot = WidgetStore.readSnapshot()
        return WidgetTodayStats(
            todayCount: snapshot.todayCount,
            dailyAverage: 8.5,
            lastCigaretteTime: nil
        )
    }
    
    private func getRealTodayStats() async -> WidgetTodayStats? {
        guard let sharedContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.fightthestroke.mirrorsmoker") else {
            print("⚠️ App Group not available, falling back to local container")
            return nil
        }
        
        let storeURL = sharedContainer.appendingPathComponent("MirrorSmoker.sqlite")
        
        do {
            let config = ModelConfiguration(url: storeURL, cloudKitDatabase: .automatic)
            let container = try ModelContainer(for: Cigarette.self, Tag.self, UserProfile.self, configurations: config)
            let context = ModelContext(container)
            
            // Get today's cigarettes
            let today = Calendar.current.startOfDay(for: Date())
            let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
            
            let todayPredicate = #Predicate<Cigarette> { cigarette in
                cigarette.timestamp >= today && cigarette.timestamp < tomorrow
            }
            
            let todayDescriptor = FetchDescriptor<Cigarette>(
                predicate: todayPredicate,
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )
            
            let todayCigarettes = try context.fetch(todayDescriptor)
            
            // Get last 30 days for average
            let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
            let avgPredicate = #Predicate<Cigarette> { cigarette in
                cigarette.timestamp >= thirtyDaysAgo
            }
            
            let avgDescriptor = FetchDescriptor<Cigarette>(predicate: avgPredicate)
            let recentCigarettes = try context.fetch(avgDescriptor)
            
            let dailyAverage = recentCigarettes.isEmpty ? 0.0 : Double(recentCigarettes.count) / 30.0
            
            return WidgetTodayStats(
                todayCount: todayCigarettes.count,
                dailyAverage: dailyAverage,
                lastCigaretteTime: todayCigarettes.first?.timestamp
            )
            
        } catch {
            print("❌ Failed to access shared data: \(error)")
            return nil
        }
    }
    
    public func addCigaretteFromWidget() async -> Bool {
        // Try to add to shared model container first
        if await addCigaretteToSharedContainer() {
            return true
        }
        
        // Fallback to widget store
        await WidgetStore.shared.addCigaretteFromWidget()
        return true
    }
    
    private func addCigaretteToSharedContainer() async -> Bool {
        guard let sharedContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.fightthestroke.mirrorsmoker") else {
            return false
        }
        
        let storeURL = sharedContainer.appendingPathComponent("MirrorSmoker.sqlite")
        
        do {
            let config = ModelConfiguration(url: storeURL, cloudKitDatabase: .automatic)
            let container = try ModelContainer(for: Cigarette.self, Tag.self, UserProfile.self, configurations: config)
            let context = ModelContext(container)
            
            let newCigarette = Cigarette(timestamp: Date(), note: "", tags: nil)
            context.insert(newCigarette)
            try context.save()
            
            return true
        } catch {
            print("❌ Failed to add cigarette to shared container: \(error)")
            return false
        }
    }
}