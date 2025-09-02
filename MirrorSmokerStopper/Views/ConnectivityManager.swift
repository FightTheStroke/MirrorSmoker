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
    private var isActivated = false
    
    override private init() {
        super.init()
    }
    
    func activate() {
        // Temporarily disable WCSession to fix performance issues
        // TODO: Re-enable once Watch connectivity is stable
        return
        
        // COMMENTED OUT: WCSession code temporarily disabled
        // guard WCSession.isSupported() else { return }
        // guard !isActivated else { return }
        // DispatchQueue.main.async { [weak self] in
        //     guard let self = self else { return }
        //     self.session = WCSession.default
        //     self.session?.delegate = self
        //     DispatchQueue.global(qos: .utility).async {
        //         self.session?.activate()
        //         DispatchQueue.main.async {
        //             self.isActivated = true
        //         }
        //     }
        // }
    }
    
    func configure(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - WCSessionDelegate
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async { [weak self] in
            guard let _ = self else { return }
            if let error = error {
                print("WCSession activation failed: \(error.localizedDescription)")
                return
            }
            
            switch activationState {
            case .activated:
                print("WCSession activated successfully")
            case .inactive:
                print("WCSession is inactive")
            case .notActivated:
                print("WCSession not activated")
            @unknown default:
                print("WCSession unknown state")
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
            print("WCSession not reachable")
            return
        }
        
        let message = [
            "type": "addCigarette",
            "data": dto.toDictionary()
        ] as [String : Any]
        
        // Send on background queue
        DispatchQueue.global(qos: .utility).async {
            session.sendMessage(message, replyHandler: nil) { error in
                print("Error sending message: \(error.localizedDescription)")
            }
        }
    }
    
    func sendTodaySnapshot(from cigarettes: [Cigarette]) {
        guard let session = session,
              session.isReachable else {
            print("WCSession not reachable for snapshot")
            return
        }
        
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        let todayCount = cigarettes.filter { $0.timestamp >= today && $0.timestamp < tomorrow }.count
        
        let message = [
            "type": "todaySnapshot",
            "todayCount": todayCount
        ] as [String : Any]
        
        // Send on background queue
        DispatchQueue.global(qos: .utility).async {
            session.sendMessage(message, replyHandler: nil) { error in
                print("Error sending snapshot: \(error.localizedDescription)")
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
