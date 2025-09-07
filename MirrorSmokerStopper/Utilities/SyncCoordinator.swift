//
//  SyncCoordinator.swift
//  MirrorSmokerStopper
//
//  Created by Claude on 05/09/25.
//
//  Central coordinator for real-time synchronization between App, Widget, and Watch
//

import Foundation
import SwiftData
import WidgetKit
import Combine
import UIKit
import os.log

@MainActor
class SyncCoordinator: ObservableObject {
    static let shared = SyncCoordinator()
    
    private let logger = Logger(subsystem: "com.fightthestroke.mirrorsmoker", category: "SyncCoordinator")
    private let groupIdentifier = "group.fightthestroke.mirrorsmoker"
    private var userDefaults: UserDefaults?
    private var cancellables = Set<AnyCancellable>()
    private var lastSyncTime: Date = Date()
    
    @Published var isSyncing = false
    
    private init() {
        self.userDefaults = UserDefaults(suiteName: groupIdentifier)
        setupObservers()
        startPeriodicSync()
    }
    
    // MARK: - Setup
    
    private func setupObservers() {
        // Monitor UserDefaults changes (for Watch updates) - reduced debounce for faster sync
        NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)
            .debounce(for: .milliseconds(100), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                Task { @MainActor in
                    self?.checkForExternalChanges()
                }
            }
            .store(in: &cancellables)
        
        // Monitor app becoming active
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                Task { @MainActor in
                    self?.performFullSync()
                }
            }
            .store(in: &cancellables)
        
        // Monitor cigarette additions from any source
        NotificationCenter.default.publisher(for: NSNotification.Name("CigaretteAddedFromWidget"))
            .sink { [weak self] _ in
                Task { @MainActor in
                    self?.handleCigaretteAddedFromWidget()
                }
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: NSNotification.Name("CigaretteAddedFromWatch"))
            .sink { [weak self] _ in
                Task { @MainActor in
                    self?.handleCigaretteAddedFromWatch()
                }
            }
            .store(in: &cancellables)
    }
    
    private func startPeriodicSync() {
        // Check for changes every 10 seconds when app is active (reduced for faster sync)
        Timer.publish(every: 10, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task { @MainActor in
                    self?.checkForExternalChanges()
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Immediate Sync Handlers
    
    private func handleCigaretteAddedFromWidget() {
        logger.info("Cigarette added from widget - performing immediate sync")
        
        // Update shared UserDefaults immediately
        updateSharedUserDefaults()
        
        // Update Widget timelines
        WidgetCenter.shared.reloadAllTimelines()
        
        // Update Watch via WatchConnectivity
        WatchConnectivityManager.shared.sendDataSync()
        
        lastSyncTime = Date()
    }
    
    private func handleCigaretteAddedFromWatch() {
        logger.info("Cigarette added from watch - performing immediate sync")
        
        // Update shared UserDefaults immediately
        updateSharedUserDefaults()
        
        // Update Widget timelines
        WidgetCenter.shared.reloadAllTimelines()
        
        lastSyncTime = Date()
    }
    
    // MARK: - Sync Operations
    
    func tagAdded(from source: SyncSource, tag: Tag? = nil) {
        logger.info("Tag added from \(source.rawValue)")
        
        switch source {
        case .app:
            // Update Widget (tags affect quick actions)
            WidgetCenter.shared.reloadAllTimelines()
            
            // Update Watch via WatchConnectivity
            WatchConnectivityManager.shared.sendDataSync()
            
            // Update shared UserDefaults
            updateSharedUserDefaults()
            
        case .widget:
            // Not applicable - widgets don't create tags
            break
            
        case .watch:
            // Not applicable - watch doesn't create tags
            break
        }
        
        lastSyncTime = Date()
    }
    
    func tagUpdated(from source: SyncSource, tag: Tag? = nil) {
        logger.info("Tag updated from \(source.rawValue)")
        
        switch source {
        case .app:
            // Update Widget and Watch
            WidgetCenter.shared.reloadAllTimelines()
            WatchConnectivityManager.shared.sendDataSync()
            updateSharedUserDefaults()
            
        case .widget, .watch:
            // Not applicable
            break
        }
        
        lastSyncTime = Date()
    }
    
    func cigaretteAdded(from source: SyncSource, cigarette: Cigarette? = nil) {
        logger.info("Cigarette added from \(source.rawValue) - performing immediate sync")
        
        // Always update shared UserDefaults first for consistency
        updateSharedUserDefaults()
        
        switch source {
        case .app:
            // Update Widget immediately
            WidgetCenter.shared.reloadAllTimelines()
            
            // Update Watch via WatchConnectivity
            if let cigarette = cigarette {
                WatchConnectivityManager.shared.sendCigaretteAdded(cigarette)
            }
            
        case .widget:
            // Widget already saved to ModelContainer
            // Notify app UI
            NotificationCenter.default.post(
                name: NSNotification.Name("CigaretteAddedFromWidget"),
                object: nil
            )
            
            // Update Widget timelines immediately
            WidgetCenter.shared.reloadAllTimelines()
            
            // Update Watch
            WatchConnectivityManager.shared.sendDataSync()
            
        case .watch:
            // Watch already notified via WatchConnectivity
            // Notify app UI
            NotificationCenter.default.post(
                name: NSNotification.Name("CigaretteAddedFromWatch"),
                object: cigarette
            )
            
            // Update Widget immediately
            WidgetCenter.shared.reloadAllTimelines()
        }
        
        lastSyncTime = Date()
    }
    
    private func checkForExternalChanges() {
        guard let userDefaults = userDefaults else { return }
        
        // Check if data was updated externally
        if let lastUpdated = userDefaults.object(forKey: "lastUpdated") as? Date,
           lastUpdated > lastSyncTime {
            
            logger.info("External changes detected, syncing...")
            
            // Check if cigarette was added from widget
            if userDefaults.bool(forKey: "widget_cigarette_added") {
                userDefaults.removeObject(forKey: "widget_cigarette_added")
                logger.info("Cigarette added from widget detected")
                
                // Notify app UI immediately
                NotificationCenter.default.post(
                    name: NSNotification.Name("CigaretteAddedFromWidget"),
                    object: nil
                )
            }
            
            // Process any pending widget actions first
            PendingWidgetActionsManager.shared.processPendingIfAny()
            
            // Update all external components
            WidgetCenter.shared.reloadAllTimelines()
            WatchConnectivityManager.shared.sendDataSync()
            updateSharedUserDefaults()
            
            // Notify app UI
            NotificationCenter.default.post(
                name: NSNotification.Name("ExternalDataChanged"),
                object: nil
            )
            
            lastSyncTime = lastUpdated
        }
    }
    
    func performFullSync() {
        guard !isSyncing else { return }
        
        isSyncing = true
        logger.info("Performing full sync...")
        
        Task {
            // Process pending widget actions if any
            PendingWidgetActionsManager.shared.processPendingIfAny()
            // Update all components
            updateSharedUserDefaults()
            WidgetCenter.shared.reloadAllTimelines()
            WatchConnectivityManager.shared.sendDataSync()
            
            isSyncing = false
            logger.info("Full sync completed")
        }
    }
    
    // MARK: - Shared UserDefaults Management
    
    private func updateSharedUserDefaults() {
        guard let userDefaults = userDefaults else { return }
        
        let container = PersistenceController.shared.container
        
        do {
            // Get today's cigarettes
            let today = Calendar.current.startOfDay(for: Date())
            guard let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today) else {
                return
            }
            
            let descriptor = FetchDescriptor<Cigarette>(
                predicate: #Predicate<Cigarette> { cigarette in
                    cigarette.timestamp >= today && cigarette.timestamp < tomorrow
                },
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )
            
            let context = ModelContext(container)
            let cigarettes = try context.fetch(descriptor)
            
            // Save count for quick access (using consistent key)
            userDefaults.set(cigarettes.count, forKey: "todayCount")
            userDefaults.set(Date(), forKey: "lastUpdated")
            
            // Update last cigarette time
            if let lastCigarette = cigarettes.first {
                userDefaults.set(lastCigarette.timestamp, forKey: "lastCigaretteTime")
            }
            
            // Calculate and update daily average
            let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
            let recentDescriptor = FetchDescriptor<Cigarette>(
                predicate: #Predicate<Cigarette> { cigarette in
                    cigarette.timestamp >= thirtyDaysAgo
                }
            )
            let recentCigarettes = try context.fetch(recentDescriptor)
            let dailyAverage = recentCigarettes.isEmpty ? 0.0 : Double(recentCigarettes.count) / 30.0
            userDefaults.set(dailyAverage, forKey: "dailyAverage")
            
            // Save cigarettes data for Watch
            let cigarettesData = cigarettes.map { cigarette in
                [
                    "id": cigarette.id.uuidString,
                    "timestamp": cigarette.timestamp.timeIntervalSince1970,
                    "note": cigarette.note
                ]
            }
            
            if let encoded = try? JSONSerialization.data(withJSONObject: cigarettesData) {
                userDefaults.set(encoded, forKey: dateKey(for: Date()))
            }
            
            logger.info("Updated shared UserDefaults with \(cigarettes.count) cigarettes")
            
        } catch {
            logger.error("Failed to update shared UserDefaults: \(error)")
        }
    }
    
    private func dateKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "cigarettes_\(formatter.string(from: date))"
    }
}

// MARK: - Sync Source
enum SyncSource: String {
    case app = "App"
    case widget = "Widget"
    case watch = "Watch"
}
