//
//  WatchConnectivityManager.swift
//  MirrorSmokerStopper Watch App
//
//  Created by Claude on 04/09/25.
//

import Foundation
@preconcurrency import WatchConnectivity
import os.log
import SwiftUI

// Watch-specific cigarette model
struct WatchCigarette: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let note: String
    
    init(id: UUID = UUID(), timestamp: Date = Date(), note: String = "") {
        self.id = id
        self.timestamp = timestamp
        self.note = note
    }
}


@MainActor
class WatchConnectivityManager: NSObject, ObservableObject {
    static let shared = WatchConnectivityManager()
    
    private let logger = Logger(subsystem: "com.fightthestroke.MirrorSmokerStopper", category: "WatchConnectivity")
    
    @Published var isPhoneConnected = false
    @Published var todayCount = 0
    @Published var yesterdayCount = 0
    @Published var weekCount = 0
    @Published var todayCigarettes: [WatchCigarette] = []
    
    private override init() {
        super.init()
        setupWatchConnectivity()
    }
    
    // MARK: - Helper Functions
    
    private func logWatchConnectivityError(_ error: Error, operation: String) {
        let nsError = error as NSError
        if nsError.domain == WCErrorDomain && nsError.code == WCError.notReachable.rawValue {
            logger.debug("iPhone not reachable for \(operation) - this is normal when iPhone is not connected")
        } else {
            logger.error("Failed to \(operation): \(error)")
        }
    }
    
    // MARK: - Setup
    
    private func setupWatchConnectivity() {
        guard WCSession.isSupported() else {
            logger.error("WatchConnectivity not supported on Watch")
            return
        }
        
        let session = WCSession.default
        session.delegate = self
        session.activate()
        
        logger.info("Watch WatchConnectivity session activated")
    }
    
    // MARK: - Send Messages to iPhone
    
    func addCigarette(note: String = "") {
        // Send to iPhone as central source of truth
        guard WCSession.default.isReachable else {
            logger.info("iPhone not reachable, cannot add cigarette")
            // Add locally as fallback when iPhone is not reachable
            addCigaretteLocally(note: note)
            return
        }
        
        let message: [String: Any] = [
            "action": "addCigarette",
            "timestamp": Date().timeIntervalSince1970,
            "note": note
        ]
        
        WCSession.default.sendMessage(message, replyHandler: { reply in
            Task { @MainActor in
                if let success = reply["success"] as? Bool, success {
                    self.logger.info("Cigarette added successfully via iPhone")
                    // iPhone will send updated data back via handleCigaretteAddedFromiPhone
                    // Also update local SharedDataManager immediately
                    self.requestStats()
                } else {
                    self.logger.error("iPhone rejected cigarette addition")
                    // Add locally as fallback
                    self.addCigaretteLocally(note: note)
                }
            }
        }, errorHandler: { error in
            Task { @MainActor in
                self.logWatchConnectivityError(error, operation: "add cigarette via iPhone")
                // Add locally as fallback when communication fails
                self.addCigaretteLocally(note: note)
            }
        })
    }
    
    private func addCigaretteLocally(note: String) {
        let cigarette = WatchCigarette(timestamp: Date(), note: note)
        todayCigarettes.append(cigarette)
        todayCigarettes.sort { $0.timestamp > $1.timestamp }
        todayCount = todayCigarettes.count
        
        // Update SharedDataManager for local persistence
        SharedDataManager.shared.syncFromiPhone(cigarettes: todayCigarettes)
        
        logger.info("Cigarette added locally as fallback: \(cigarette.id)")
    }
    
    func requestSync() {
        guard WCSession.default.isReachable else {
            logger.info("iPhone not reachable for sync")
            // Load from local storage as fallback
            SharedDataManager.shared.loadSharedData()
            return
        }
        
        let message: [String: Any] = ["action": "requestSync"]
        
        WCSession.default.sendMessage(message, replyHandler: { reply in
            Task { @MainActor in
                self.handleSyncResponse(reply)
            }
        }, errorHandler: { error in
            Task { @MainActor in
                self.logger.warning("Sync request failed: \(error.localizedDescription)")
                // Load from local storage as fallback
                SharedDataManager.shared.loadSharedData()
            }
        })
    }
    
    func requestStats() {
        guard WCSession.default.isReachable else {
            logger.info("iPhone not reachable for stats")
            // Load from local storage as fallback
            SharedDataManager.shared.loadSharedData()
            return
        }
        
        let message: [String: Any] = ["action": "getStats"]
        
        WCSession.default.sendMessage(message, replyHandler: { reply in
            Task { @MainActor in
                self.handleStatsResponse(reply)
            }
        }, errorHandler: { error in
            Task { @MainActor in
                self.logger.warning("Stats request failed: \(error.localizedDescription)")
                // Load from local storage as fallback
                SharedDataManager.shared.loadSharedData()
            }
        })
    }
    
    // MARK: - Response Handlers
    
    private func handleSyncResponse(_ response: [String: Any]) {
        guard let success = response["success"] as? Bool, success else {
            logger.error("Sync response failed: \(response)")
            return
        }
        
        if let count = response["todayCount"] as? Int {
            todayCount = count
        }
        
        if let cigarettesData = response["cigarettes"] as? [[String: Any]] {
            todayCigarettes = cigarettesData.compactMap { data -> WatchCigarette? in
                guard let idString = data["id"] as? String,
                      let id = UUID(uuidString: idString),
                      let timestamp = data["timestamp"] as? TimeInterval else {
                    return nil
                }
                
                let note = data["note"] as? String ?? ""
                return WatchCigarette(
                    id: id,
                    timestamp: Date(timeIntervalSince1970: timestamp),
                    note: note
                )
            }
        }
        
        logger.info("Sync completed: \(self.todayCount) cigarettes today")
    }
    
    private func handleStatsResponse(_ response: [String: Any]) {
        guard let success = response["success"] as? Bool, success else {
            logger.error("Stats response failed: \(response)")
            return
        }
        
        if let count = response["todayCount"] as? Int {
            todayCount = count
        }
        
        if let count = response["yesterdayCount"] as? Int {
            yesterdayCount = count
        }
        
        if let count = response["weekCount"] as? Int {
            weekCount = count
        }
        
        logger.info("Stats updated: today=\(self.todayCount), yesterday=\(self.yesterdayCount), week=\(self.weekCount)")
    }
}

// MARK: - WCSessionDelegate

extension WatchConnectivityManager: WCSessionDelegate {
    
    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            self.isPhoneConnected = activationState == .activated && session.isReachable
            
            if let error = error {
                self.logger.error("Watch WCSession activation failed: \(error)")
            } else {
                self.logger.info("Watch WCSession activated with state: \(activationState.rawValue)")
                
                // Request initial sync when connection is established
                if activationState == .activated && session.isReachable {
                    self.requestStats()
                }
            }
        }
    }
    
    nonisolated func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isPhoneConnected = session.isReachable
            self.logger.info("iPhone reachability changed: \(session.isReachable)")
            
            // Request stats when iPhone becomes reachable
            if session.isReachable {
                self.requestStats()
            }
        }
    }
    
    // Note: watchOS doesn't need sessionDidBecomeInactive and sessionDidDeactivate
    
    // MARK: - Receive Messages from iPhone
    
    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        guard let action = message["action"] as? String else {
            logger.warning("Invalid message format from iPhone")
            return
        }
        
        logger.info("Received message from iPhone: \(action)")
        
        DispatchQueue.main.async {
            switch action {
            case "cigaretteAdded":
                self.handleCigaretteAddedFromiPhone(message: message)
                
            case "fullSync":
                self.handleFullSyncFromiPhone(message: message)
                
            case "purchaseAdded":
                self.handlePurchaseAddedFromiPhone(message: message)
                
            default:
                self.logger.warning("Unknown action from iPhone: \(action)")
            }
        }
    }

    // Handle messages that expect a reply to avoid WCErrorCodeDeliveryFailed when iPhone uses sendMessage(replyHandler:errorHandler:)
    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        guard let action = message["action"] as? String else {
            replyHandler(["success": false, "error": "Invalid message format"]) 
            return
        }
        
        logger.info("Received message with reply from iPhone: \(action)")
        
        DispatchQueue.main.async {
            switch action {
            case "cigaretteAdded":
                self.handleCigaretteAddedFromiPhone(message: message)
                replyHandler(["success": true])
            case "fullSync":
                self.handleFullSyncFromiPhone(message: message)
                replyHandler(["success": true])
            case "purchaseAdded":
                self.handlePurchaseAddedFromiPhone(message: message)
                replyHandler(["success": true])
            default:
                self.logger.warning("Unknown action from iPhone: \(action)")
                replyHandler(["success": false, "error": "Unknown action"]) 
            }
        }
    }
    
    private func handleCigaretteAddedFromiPhone(message: [String: Any]) {
        guard let idString = message["cigaretteId"] as? String,
              let id = UUID(uuidString: idString),
              let timestamp = message["timestamp"] as? TimeInterval else {
            logger.error("Invalid cigarette data from iPhone")
            return
        }
        
        let note = message["note"] as? String ?? ""
        let cigarette = WatchCigarette(
            id: id,
            timestamp: Date(timeIntervalSince1970: timestamp),
            note: note
        )
        
        // Check if we already have this cigarette to avoid duplicates
        if !todayCigarettes.contains(where: { $0.id == cigarette.id }) {
            // Check if this is today's cigarette
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            if cigarette.timestamp >= today {
                todayCigarettes.append(cigarette)
                todayCigarettes.sort { $0.timestamp > $1.timestamp } // Most recent first
                todayCount = todayCigarettes.count
                
                logger.info("Cigarette added from iPhone: \(cigarette.id)")
                
                // Update SharedDataManager immediately
                SharedDataManager.shared.syncFromiPhone(cigarettes: self.todayCigarettes)
            }
        }
        
        // Always request fresh stats to ensure accuracy
        requestStats()
    }
    
    private func handleFullSyncFromiPhone(message: [String: Any]) {
        guard let cigarettesData = message["cigarettes"] as? [[String: Any]] else {
            logger.error("Invalid full sync data from iPhone")
            return
        }
        
        let cigarettes = cigarettesData.compactMap { data -> WatchCigarette? in
            guard let idString = data["id"] as? String,
                  let id = UUID(uuidString: idString),
                  let timestamp = data["timestamp"] as? TimeInterval else {
                return nil
            }
            
            let note = data["note"] as? String ?? ""
            return WatchCigarette(
                id: id,
                timestamp: Date(timeIntervalSince1970: timestamp),
                note: note
            )
        }
        
        todayCigarettes = cigarettes.sorted { $0.timestamp > $1.timestamp }
        todayCount = todayCigarettes.count
        
        // Persist to shared storage for fallback coherence
        SharedDataManager.shared.syncFromiPhone(cigarettes: todayCigarettes)
        
        logger.info("Full sync completed from iPhone: \(self.todayCount) cigarettes and persisted locally")
    }
    
    private func handlePurchaseAddedFromiPhone(message: [String: Any]) {
        // Watch doesn't need to display purchase details, but we can log it
        if let productName = message["productName"] as? String {
            logger.info("Purchase added from iPhone: \(productName)")
        }
    }
    
    // Note: Watch doesn't need to handle messages with reply handlers from iPhone
    
    #if os(iOS)
    // These methods are required for iOS but not for watchOS
    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {
        // Handle session becoming inactive
    }
    
    nonisolated func sessionDidDeactivate(_ session: WCSession) {
        // Handle session deactivation
        // Reactivate the session
        session.activate()
    }
    #endif
}
