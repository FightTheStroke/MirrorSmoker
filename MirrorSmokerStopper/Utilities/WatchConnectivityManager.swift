//
//  WatchConnectivityManager.swift
//  MirrorSmokerStopper
//
//  Created by Claude on 04/09/25.
//

import Foundation
import WatchConnectivity
import SwiftData
import os.log

@MainActor
class WatchConnectivityManager: NSObject, ObservableObject {
    static let shared = WatchConnectivityManager()
    
    private let logger = Logger(subsystem: "com.fightthestroke.MirrorSmokerStopper", category: "WatchConnectivity")
    private var modelContext: ModelContext?
    
    @Published var isWatchConnected = false
    @Published var isWatchAppInstalled = false
    
    private override init() {
        super.init()
        setupWatchConnectivity()
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    // MARK: - Setup
    
    private func setupWatchConnectivity() {
        guard WCSession.isSupported() else {
            logger.error("WatchConnectivity not supported on this device")
            return
        }
        
        let session = WCSession.default
        session.delegate = self
        session.activate()
        
        logger.info("WatchConnectivity session activated")
    }
    
    // MARK: - Send Messages to Watch
    
    func sendCigaretteAdded(_ cigarette: Cigarette) {
        guard WCSession.default.isReachable else {
            logger.info("Watch not reachable, data will sync via App Group")
            return
        }
        
        let message: [String: Any] = [
            "action": "cigaretteAdded",
            "cigaretteId": cigarette.id.uuidString,
            "timestamp": cigarette.timestamp.timeIntervalSince1970,
            "note": cigarette.note
        ]
        
        WCSession.default.sendMessage(message, replyHandler: { reply in
            Task { @MainActor in
                self.logger.info("Watch confirmed cigarette sync: \(reply)")
            }
        }, errorHandler: { error in
            Task { @MainActor in
                self.logger.error("Failed to send cigarette to Watch: \(error)")
            }
        })
    }
    
    func sendDataSync() {
        guard WCSession.default.isReachable else {
            logger.info("Watch not reachable for full sync")
            return
        }
        
        guard let context = modelContext else {
            logger.error("No model context available for sync")
            return
        }
        
        // Get today's cigarettes
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        
        let descriptor = FetchDescriptor<Cigarette>(
            predicate: #Predicate<Cigarette> { cigarette in
                cigarette.timestamp >= today && cigarette.timestamp < tomorrow
            },
            sortBy: [SortDescriptor(\.timestamp)]
        )
        
        do {
            let todayCigarettes = try context.fetch(descriptor)
            let cigarettesData = todayCigarettes.map { cigarette in
                [
                    "id": cigarette.id.uuidString,
                    "timestamp": cigarette.timestamp.timeIntervalSince1970,
                    "note": cigarette.note
                ]
            }
            
            let message: [String: Any] = [
                "action": "fullSync",
                "cigarettes": cigarettesData
            ]
            
            WCSession.default.sendMessage(message, replyHandler: { reply in
                Task { @MainActor in
                    self.logger.info("Full sync completed: \(reply)")
                }
            }, errorHandler: { error in
                Task { @MainActor in
                    self.logger.error("Full sync failed: \(error)")
                }
            })
            
        } catch {
            logger.error("Failed to fetch cigarettes for sync: \(error)")
        }
    }
    
    func sendPurchaseAdded(_ purchase: Purchase) {
        guard WCSession.default.isReachable else {
            logger.info("Watch not reachable, purchase will sync via App Group")
            return
        }
        
        let message: [String: Any] = [
            "action": "purchaseAdded",
            "purchaseId": purchase.id.uuidString,
            "timestamp": purchase.timestamp.timeIntervalSince1970,
            "productName": purchase.productName,
            "quantity": purchase.quantity,
            "amount": purchase.amountInCurrency,
            "currency": purchase.currencyCode
        ]
        
        WCSession.default.sendMessage(message, replyHandler: nil, errorHandler: { error in
            Task { @MainActor in
                self.logger.error("Failed to send purchase to Watch: \(error)")
            }
        })
    }
}

// MARK: - WCSessionDelegate

extension WatchConnectivityManager: WCSessionDelegate {
    
    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            self.isWatchConnected = activationState == .activated
            
            if let error = error {
                self.logger.error("WCSession activation failed: \(error)")
            } else {
                self.logger.info("WCSession activated with state: \(activationState.rawValue)")
                self.isWatchAppInstalled = session.isWatchAppInstalled
                
                // Send initial sync when connection is established
                if activationState == .activated && session.isReachable {
                    self.sendDataSync()
                }
            }
        }
    }
    
    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {
        DispatchQueue.main.async {
            self.logger.info("WCSession became inactive")
            self.isWatchConnected = false
        }
    }
    
    nonisolated func sessionDidDeactivate(_ session: WCSession) {
        DispatchQueue.main.async {
            self.logger.info("WCSession deactivated")
            self.isWatchConnected = false
        }
    }
    
    nonisolated func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.logger.info("Watch reachability changed: \(session.isReachable)")
            
            // Send sync when Watch becomes reachable
            if session.isReachable {
                self.sendDataSync()
            }
        }
    }
    
    // MARK: - Receive Messages from Watch
    
    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        
        guard let action = message["action"] as? String else {
            replyHandler(["error": "Invalid message format"])
            return
        }
        
        logger.info("Received message from Watch: \(action)")
        
        switch action {
        case "addCigarette":
            Task { @MainActor in
                handleAddCigaretteFromWatch(message: message, replyHandler: replyHandler)
            }
            
        case "requestSync":
            Task { @MainActor in
                handleSyncRequest(replyHandler: replyHandler)
            }
            
        case "getStats":
            Task { @MainActor in
                handleStatsRequest(replyHandler: replyHandler)
            }
            
        default:
            logger.warning("Unknown action from Watch: \(action)")
            replyHandler(["error": "Unknown action"])
        }
    }
    
    private func handleAddCigaretteFromWatch(message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        guard let context = modelContext else {
            replyHandler(["error": "No model context"])
            return
        }
        
        let timestamp = message["timestamp"] as? TimeInterval ?? Date().timeIntervalSince1970
        let note = message["note"] as? String ?? ""
        
        let cigarette = Cigarette(
            timestamp: Date(timeIntervalSince1970: timestamp),
            note: note
        )
        
        context.insert(cigarette)
        
        do {
            try context.save()
            logger.info("Cigarette added from Watch successfully")
            
            // Notify main app UI to refresh
            NotificationCenter.default.post(
                name: NSNotification.Name("CigaretteAddedFromWatch"),
                object: cigarette
            )
            
            // Also update widget data via App Group
            WidgetManager.shared.updateWidgetData()
            
            replyHandler([
                "success": true,
                "cigaretteId": cigarette.id.uuidString
            ])
            
        } catch {
            logger.error("Failed to save cigarette from Watch: \(error)")
            replyHandler(["error": error.localizedDescription])
        }
    }
    
    private func handleSyncRequest(replyHandler: @escaping ([String: Any]) -> Void) {
        guard let context = modelContext else {
            replyHandler(["error": "No model context"])
            return
        }
        
        // Get today's stats
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        
        let descriptor = FetchDescriptor<Cigarette>(
            predicate: #Predicate<Cigarette> { cigarette in
                cigarette.timestamp >= today && cigarette.timestamp < tomorrow
            }
        )
        
        do {
            let todayCigarettes = try context.fetch(descriptor)
            let cigarettesData = todayCigarettes.map { cigarette in
                [
                    "id": cigarette.id.uuidString,
                    "timestamp": cigarette.timestamp.timeIntervalSince1970,
                    "note": cigarette.note
                ]
            }
            
            replyHandler([
                "success": true,
                "todayCount": todayCigarettes.count,
                "cigarettes": cigarettesData
            ])
            
        } catch {
            logger.error("Failed to fetch data for sync: \(error)")
            replyHandler(["error": error.localizedDescription])
        }
    }
    
    private func handleStatsRequest(replyHandler: @escaping ([String: Any]) -> Void) {
        guard let context = modelContext else {
            replyHandler(["error": "No model context"])
            return
        }
        
        let calendar = Calendar.current
        let now = Date()
        
        // Today
        let today = calendar.startOfDay(for: now)
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        
        // Yesterday  
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        
        // Week
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: now)!
        
        do {
            // Today's cigarettes
            let todayDescriptor = FetchDescriptor<Cigarette>(
                predicate: #Predicate<Cigarette> { cigarette in
                    cigarette.timestamp >= today && cigarette.timestamp < tomorrow
                }
            )
            let todayCigarettes = try context.fetch(todayDescriptor)
            
            // Yesterday's cigarettes
            let yesterdayDescriptor = FetchDescriptor<Cigarette>(
                predicate: #Predicate<Cigarette> { cigarette in
                    cigarette.timestamp >= yesterday && cigarette.timestamp < today
                }
            )
            let yesterdayCigarettes = try context.fetch(yesterdayDescriptor)
            
            // Week's cigarettes
            let weekDescriptor = FetchDescriptor<Cigarette>(
                predicate: #Predicate<Cigarette> { cigarette in
                    cigarette.timestamp >= weekAgo
                }
            )
            let weekCigarettes = try context.fetch(weekDescriptor)
            
            replyHandler([
                "success": true,
                "todayCount": todayCigarettes.count,
                "yesterdayCount": yesterdayCigarettes.count,
                "weekCount": weekCigarettes.count,
                "weeklyAverage": Double(weekCigarettes.count) / 7.0
            ])
            
        } catch {
            logger.error("Failed to fetch stats: \(error)")
            replyHandler(["error": error.localizedDescription])
        }
    }
}