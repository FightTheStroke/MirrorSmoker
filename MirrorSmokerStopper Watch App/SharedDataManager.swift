//
//  SharedDataManager.swift
//  MirrorSmokerStopper Watch App
//
//  Created by Claude on 05/09/25.
//

import Foundation
import SwiftUI
import WidgetKit

// MARK: - Shared Data Manager for Watch App
@MainActor
class SharedDataManager: ObservableObject {
    static let shared = SharedDataManager()
    
    private let groupIdentifier = "group.fightthestroke.mirrorsmoker"
    private let userDefaults = UserDefaults(suiteName: "group.fightthestroke.mirrorsmoker")
    
    @Published var todayCount: Int = 0
    @Published var todayCigarettes: [WatchCigarette] = []
    
    private init() {
        loadSharedData()
    }
    
    // MARK: - Add Cigarette (from Watch)
    func addCigarette(note: String = "") {
        let cigarette = WatchCigarette(note: note.isEmpty ? "Added from Watch" : note)
        
        // Add to local state
        todayCigarettes.append(cigarette)
        todayCount = todayCigarettes.count
        
        // Save to shared UserDefaults for synchronization
        saveCigaretteToSharedStorage(cigarette)
        
        // Update widgets
        WidgetCenter.shared.reloadAllTimelines()
        
        // Also try to send via WatchConnectivity if available
        WatchConnectivityManager.shared.addCigarette(note: note)
    }
    
    // MARK: - Shared Storage Management
    private func saveCigaretteToSharedStorage(_ cigarette: WatchCigarette) {
        guard let userDefaults = userDefaults else { return }
        
        // Get existing cigarettes from today
        let todayKey = dateKey(for: Date())
        var cigarettes = loadCigarettesFromStorage(for: todayKey)
        
        // Add new cigarette
        cigarettes.append(cigarette)
        
        // Save back to UserDefaults
        if let encoded = try? JSONEncoder().encode(cigarettes) {
            userDefaults.set(encoded, forKey: todayKey)
            
            // Also update the quick access count
            userDefaults.set(cigarettes.count, forKey: "todayCount")
            userDefaults.set(Date(), forKey: "lastUpdated")
        }
    }
    
    private func loadSharedData() {
        guard userDefaults != nil else { return }
        
        // Load today's cigarettes
        let todayKey = dateKey(for: Date())
        todayCigarettes = loadCigarettesFromStorage(for: todayKey)
        todayCount = todayCigarettes.count
        
        // Clean up old data (keep only last 7 days)
        cleanupOldData()
    }
    
    private func loadCigarettesFromStorage(for key: String) -> [WatchCigarette] {
        guard let userDefaults = userDefaults,
              let data = userDefaults.data(forKey: key),
              let cigarettes = try? JSONDecoder().decode([WatchCigarette].self, from: data) else {
            return []
        }
        return cigarettes
    }
    
    private func dateKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "cigarettes_\(formatter.string(from: date))"
    }
    
    private func cleanupOldData() {
        guard let userDefaults = userDefaults else { return }
        
        let calendar = Calendar.current
        let today = Date()
        
        // Remove data older than 7 days
        for i in 8...30 {
            if let oldDate = calendar.date(byAdding: .day, value: -i, to: today) {
                let key = dateKey(for: oldDate)
                userDefaults.removeObject(forKey: key)
            }
        }
    }
    
    // MARK: - Sync from iPhone
    func syncFromiPhone(cigarettes: [WatchCigarette]) {
        // Filter to only today's cigarettes
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        todayCigarettes = cigarettes.filter { cigarette in
            calendar.isDate(cigarette.timestamp, inSameDayAs: today)
        }.sorted { $0.timestamp > $1.timestamp }
        
        todayCount = todayCigarettes.count
        
        // Save to shared storage
        let todayKey = dateKey(for: Date())
        if let encoded = try? JSONEncoder().encode(todayCigarettes) {
            userDefaults?.set(encoded, forKey: todayKey)
            userDefaults?.set(todayCount, forKey: "todayCount")
            userDefaults?.set(Date(), forKey: "lastUpdated")
        }
        
        // Update widgets
        WidgetCenter.shared.reloadAllTimelines()
    }
}