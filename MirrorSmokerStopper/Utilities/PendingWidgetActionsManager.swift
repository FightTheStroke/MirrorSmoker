//
//  PendingWidgetActionsManager.swift
//  MirrorSmokerStopper
//
//  Created by Assistant on 06/09/25.
//

import Foundation
import SwiftData
import os.log

@MainActor
final class PendingWidgetActionsManager {
    static let shared = PendingWidgetActionsManager()
    
    private let logger = Logger(subsystem: "com.fightthestroke.MirrorSmokerStopper", category: "PendingWidgetActions")
    private let groupIdentifier = "group.fightthestroke.mirrorsmoker"
    private let pendingKey = "widget_pending_cigarettes"
    
    private init() {}
    
    /// Process pending cigarettes enqueued by the widget into the shared App Group UserDefaults
    func processPendingIfAny() {
        guard let userDefaults = UserDefaults(suiteName: groupIdentifier) else { return }
        guard let timestamps = userDefaults.array(forKey: pendingKey) as? [Double], !timestamps.isEmpty else { return }
        
        let context = PersistenceController.shared.container.mainContext
        var processed = 0
        
        for ts in timestamps {
            let date = Date(timeIntervalSince1970: ts)
            let cig = Cigarette(timestamp: date)
            context.insert(cig)
            processed += 1
        }
        
        do {
            if processed > 0 {
                try context.save()
                logger.info("Processed \(processed) pending widget cigarettes")
                // Clear pending queue
                userDefaults.removeObject(forKey: pendingKey)
                // Mark lastUpdated so SyncCoordinator picks up
                userDefaults.set(Date(), forKey: "lastUpdated")
            }
        } catch {
            logger.error("Failed to save pending widget cigarettes: \(error.localizedDescription)")
        }
    }
}

