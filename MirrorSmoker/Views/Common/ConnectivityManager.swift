//
//  ConnectivityManager.swift
//  Mirror Smoker
//
//  Created by Roberto D'Angelo on 27/08/24.
//

import Foundation
import WatchConnectivity
import SwiftData
import Combine

class ConnectivityManager: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = ConnectivityManager()
    
    private var session: WCSession?
    private var modelContext: ModelContext?
    
    override private init() {
        super.init()
    }
    
    func activate() {
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
    }
    
    func configure(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - WCSessionDelegate
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // Handle activation completion
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        // Handle session becoming inactive
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        // Handle session deactivation
    }
    
    // MARK: - Message Sending
    
    func sendAddCigarette(_ dto: CigaretteDTO) {
        let message = [
            "type": "addCigarette",
            "data": dto.toDictionary()
        ] as [String : Any]
        
        session?.sendMessage(message, replyHandler: nil) { error in
            print("Error sending message: \(error)")
        }
    }
    
    func sendTodaySnapshot(from cigarettes: [Cigarette]) {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        let todayCount = cigarettes.filter { $0.timestamp >= today && $0.timestamp < tomorrow }.count
        
        let message = [
            "type": "todaySnapshot",
            "todayCount": todayCount
        ] as [String : Any]
        
        session?.sendMessage(message, replyHandler: nil) { error in
            print("Error sending snapshot: \(error)")
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