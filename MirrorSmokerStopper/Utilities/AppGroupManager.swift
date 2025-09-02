//
//  AppGroupManager.swift
//  MirrorSmokerStopper
//
//  Created by Claude on 02/09/25.
//

import Foundation
import SwiftData

// MARK: - App Group Configuration
struct AppGroupManager {
    static let groupIdentifier = "group.com.mirror-labs.mirrorsmoker"
    
    static var sharedContainer: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupIdentifier)
    }
    
    static var sharedModelContainer: ModelContainer? {
        guard let url = sharedContainer else {
            print("❌ App Group container not found")
            return nil
        }
        
        let storeURL = url.appendingPathComponent("MirrorSmoker.sqlite")
        
        do {
            let config = ModelConfiguration(url: storeURL, cloudKitDatabase: .automatic)
            return try ModelContainer(for: Cigarette.self, Tag.self, UserProfile.self, configurations: config)
        } catch {
            print("❌ Failed to create shared model container: \(error)")
            return nil
        }
    }
}

// MARK: - Widget Data Provider
@MainActor
class WidgetDataProvider: ObservableObject {
    private let modelContext: ModelContext?
    
    init() {
        self.modelContext = AppGroupManager.sharedModelContainer?.mainContext
    }
    
    // MARK: - Today's Data
    func getTodayStats() -> WidgetTodayStats {
        guard let context = modelContext else {
            return WidgetTodayStats.empty
        }
        
        let todayCigarettes = DateQueryHelpers.fetchCigarettesSafely(
            with: DateQueryHelpers.todayPredicate(),
            from: context
        )
        
        let last30DaysCigarettes = DateQueryHelpers.fetchCigarettesSafely(
            with: DateQueryHelpers.last30DaysPredicate(),
            from: context
        )
        
        let dailyAverage = last30DaysCigarettes.isEmpty ? 0.0 : Double(last30DaysCigarettes.count) / 30.0
        
        let lastCigaretteTime: Date? = todayCigarettes.first?.timestamp
        
        return WidgetTodayStats(
            todayCount: todayCigarettes.count,
            dailyAverage: dailyAverage,
            lastCigaretteTime: lastCigaretteTime
        )
    }
    
    // MARK: - Add Cigarette from Widget
    func addCigaretteFromWidget() -> Bool {
        guard let context = modelContext else {
            return false
        }
        
        let newCigarette = Cigarette(timestamp: Date())
        context.insert(newCigarette)
        
        do {
            try context.save()
            
            // Notify the main app to refresh
            NotificationCenter.default.post(
                name: NSNotification.Name("CigaretteAddedFromWidget"),
                object: nil
            )
            
            return true
        } catch {
            print("❌ Failed to add cigarette from widget: \(error)")
            return false
        }
    }
}

// MARK: - Widget Data Models
struct WidgetTodayStats {
    let todayCount: Int
    let dailyAverage: Double
    let lastCigaretteTime: Date?
    
    static let empty = WidgetTodayStats(
        todayCount: 0,
        dailyAverage: 0.0,
        lastCigaretteTime: nil
    )
    
    var lastCigaretteFormatted: String {
        guard let time = lastCigaretteTime else {
            return NSLocalizedString("widget.no.cigarettes.today", comment: "")
        }
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return NSLocalizedString("widget.last.at", comment: "") + " " + formatter.string(from: time)
    }
    
    var statusColor: String {
        let target = max(1, Int(dailyAverage))
        
        if todayCount == 0 {
            return "#34C759" // Success green
        } else if todayCount < Int(Double(target) * 0.8) {
            return "#FF9500" // Warning orange  
        } else {
            return "#FF3B30" // Danger red
        }
    }
}