//
//  AddCigaretteIntent.swift
//  HomeWidget
//
//  Created by Claude on 07/09/25.
//

import AppIntents
import WidgetKit
import SwiftData
import Foundation

// MARK: - Add Cigarette Intent
struct AddCigaretteIntent: AppIntent {
    static var title: LocalizedStringResource = "widget.intent.add.cigarette"
    static var description = IntentDescription("widget.intent.add.cigarette.description")
    
    func perform() async throws -> some IntentResult {
        let success = await addCigaretteToSharedDatabase()
        
        if success {
            // Refresh all widget timelines immediately
            WidgetCenter.shared.reloadAllTimelines()
            
            return .result(dialog: IntentDialog("widget.intent.success"))
        } else {
            throw IntentError.addFailed
        }
    }
    
    // MARK: - Database Access
    private func addCigaretteToSharedDatabase() async -> Bool {
        // For widget, we'll use a simpler approach with UserDefaults
        // The main app will process this when it becomes active
        guard let userDefaults = UserDefaults(suiteName: "group.fightthestroke.mirrorsmoker") else {
            return false
        }
        
        // Add timestamp to pending queue
        let timestamp = Date().timeIntervalSince1970
        var pendingCigarettes = userDefaults.array(forKey: "widget_pending_cigarettes") as? [Double] ?? []
        pendingCigarettes.append(timestamp)
        userDefaults.set(pendingCigarettes, forKey: "widget_pending_cigarettes")
        
        // Update sync indicators
        userDefaults.set(Date(), forKey: "lastUpdated")
        userDefaults.set("widget", forKey: "lastUpdateSource")
        
        // Increment today's count immediately for UI feedback
        let currentCount = userDefaults.integer(forKey: "todayCount")
        userDefaults.set(currentCount + 1, forKey: "todayCount")
        
        // Notify the main app that a cigarette was added from widget
        userDefaults.set(true, forKey: "widget_cigarette_added")
        
        return true
    }
}

// MARK: - Intent Errors
enum IntentError: Error, LocalizedError {
    case addFailed
    
    var errorDescription: String? {
        switch self {
        case .addFailed:
            return NSLocalizedString("widget.intent.error.add.failed", comment: "")
        }
    }
}
