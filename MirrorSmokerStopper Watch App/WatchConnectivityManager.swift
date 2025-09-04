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
        let cigarette = WatchCigarette(note: note)
        
        // Add to local state immediately for responsiveness
        todayCigarettes.append(cigarette)
        todayCount = todayCigarettes.count
        weekCount += 1
        
        // Send to iPhone if available
        if WCSession.default.isReachable {
            let message: [String: Any] = [
                "action": "addCigarette",
                "timestamp": cigarette.timestamp.timeIntervalSince1970,
                "note": cigarette.note
            ]
            
            WCSession.default.sendMessage(message, replyHandler: { reply in
                Task { @MainActor in
                    if let success = reply["success"] as? Bool, success {
                        self.logger.info("Cigarette synced successfully with iPhone")
                    }
                }
            }, errorHandler: { error in
                Task { @MainActor in
                    self.logger.error("Failed to sync cigarette with iPhone: \(error)")
                    // Keep local data, will sync when iPhone becomes available
                }
            })
        } else {
            logger.info("iPhone not reachable, cigarette will sync when available")
            // TODO: Save to App Group for later sync
        }
    }
    
    func requestSync() {
        guard WCSession.default.isReachable else {
            logger.info("iPhone not reachable for sync")
            return
        }
        
        let message: [String: Any] = ["action": "requestSync"]
        
        WCSession.default.sendMessage(message, replyHandler: { reply in
            Task { @MainActor in
                self.handleSyncResponse(reply)
            }
        }, errorHandler: { error in
            Task { @MainActor in
                self.logger.error("Sync request failed: \(error)")
            }
        })
    }
    
    func requestStats() {
        guard WCSession.default.isReachable else {
            logger.info("iPhone not reachable for stats")
            return
        }
        
        let message: [String: Any] = ["action": "getStats"]
        
        WCSession.default.sendMessage(message, replyHandler: { reply in
            Task { @MainActor in
                self.handleStatsResponse(reply)
            }
        }, errorHandler: { error in
            Task { @MainActor in
                self.logger.error("Stats request failed: \(error)")
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

extension WatchConnectivityManager: @preconcurrency WCSessionDelegate {
    
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
    
#if os(iOS)
    // These delegate methods are only required on iOS, not watchOS
    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {
        DispatchQueue.main.async {
            self.logger.info("Watch session became inactive")
        }
    }
    
    nonisolated func sessionDidDeactivate(_ session: WCSession) {
        DispatchQueue.main.async {
            self.logger.info("Watch session deactivated")
        }
        
        // Reactivate the session for the Apple Watch
        session.activate()
    }
#endif
    
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
            todayCigarettes.append(cigarette)
            todayCigarettes.sort { $0.timestamp > $1.timestamp } // Most recent first
            todayCount = todayCigarettes.count
            weekCount += 1
            
            logger.info("Cigarette added from iPhone: \(cigarette.id)")
        }
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
        
        logger.info("Full sync completed from iPhone: \(self.todayCount) cigarettes")
    }
    
    private func handlePurchaseAddedFromiPhone(message: [String: Any]) {
        // Watch doesn't need to display purchase details, but we can log it
        if let productName = message["productName"] as? String {
            logger.info("Purchase added from iPhone: \(productName)")
        }
    }
}