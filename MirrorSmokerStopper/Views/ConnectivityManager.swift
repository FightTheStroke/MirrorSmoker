//
//  ConnectivityManager.swift
//  Mirror Smoker
//
//  Created by Roberto D'Angelo on 27/08/24.
//

import Foundation
import WatchConnectivity
import os.log
import SwiftData
import Combine

class ConnectivityManager: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = ConnectivityManager()
    
    private var session: WCSession?
    private var modelContext: ModelContext?
    private var isActivated = false
    private static let logger = Logger(subsystem: "com.fightthestroke.MirrorSmokerStopper", category: "ConnectivityManager")

    override private init() {
        super.init()
    }
    
    func activate() {
        // WCSession disabled for performance optimization
        // Watch connectivity handled through App Groups instead
        return
    }
    
    func configure(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - WCSessionDelegate
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            if let error = error {
                Self.logger.error("WCSession activation failed: \(error.localizedDescription)")
                return
            }
            
            switch activationState {
            case .activated:
                Self.logger.info("WCSession activated successfully")
            case .inactive:
                Self.logger.warning("WCSession is inactive")
            case .notActivated:
                Self.logger.warning("WCSession not activated")
            @unknown default:
                Self.logger.error("WCSession unknown state")
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        // Handle received user info
    }
    
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {

    }
    
    func sessionDidDeactivate(_ session: WCSession) {

    }
    #endif

    // MARK: - Message Sending
    
    func sendAddCigarette(_ dto: CigaretteDTO) {
        guard let session = session, 
              session.isReachable else {
            Self.logger.warning("WCSession not reachable, cannot send data to watch.")
            return
        }
        
        let message = [
            "type": "addCigarette",
            "data": dto.toDictionary()
        ] as [String : Any]
        
        // Send on background queue
        DispatchQueue.global(qos: .utility).async {
            session.sendMessage(message, replyHandler: nil) { error in
                Self.logger.error("Error sending message: \(error.localizedDescription)")
            }
        }
    }
    
    func sendTodaySnapshot(from cigarettes: [Cigarette]) {
        guard let session = session,
              session.isReachable else {
            Self.logger.warning("WCSession not reachable for snapshot")
            return
        }
        
        let today = Calendar.current.startOfDay(for: Date())
        guard let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today) else {
            Self.logger.warning("Failed to calculate tomorrow's date")
            return
        }
        let todayCount = cigarettes.filter { $0.timestamp >= today && $0.timestamp < tomorrow }.count
        
        let message = [
            "type": "todaySnapshot",
            "todayCount": todayCount
        ] as [String : Any]
        
        // Send on background queue
        DispatchQueue.global(qos: .utility).async {
            session.sendMessage(message, replyHandler: nil) { error in
                Self.logger.error("Error sending snapshot: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - CigaretteDTO

struct CigaretteDTO: Codable {
    let id: UUID
    let timestamp: Date
    let note: String
    let tagNames: [String]
    
    init(from cigarette: Cigarette) {
        self.id = cigarette.id
        self.timestamp = cigarette.timestamp
        self.note = cigarette.note
        // Safely unwrap optional tags and map to tag names
        self.tagNames = cigarette.tags?.map { $0.name } ?? []
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "id": id.uuidString,
            "timestamp": timestamp.timeIntervalSince1970,
            "note": note,
            "tagNames": tagNames
        ]
    }
}
