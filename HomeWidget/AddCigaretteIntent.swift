//
//  AddCigaretteIntent.swift
//  HomeWidget
//
//  Created by Claude on 02/09/25.
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
            // Refresh all widget timelines
            WidgetCenter.shared.reloadAllTimelines()
            
            return .result(dialog: IntentDialog("widget.intent.success"))
        } else {
            throw IntentError.addFailed
        }
    }
    
    // MARK: - Database Access
    private func addCigaretteToSharedDatabase() async -> Bool {
        guard let container = AppGroupManager.sharedModelContainer else {
            print("❌ Widget: Failed to get shared model container for adding cigarette")
            return false
        }
        
        let context = ModelContext(container)
        
        do {
            // Create and save cigarette using the real Cigarette model
            let cigarette = Cigarette(
                timestamp: Date(),
                note: NSLocalizedString("added.from.widget", comment: "Added from widget")
            )
            
            context.insert(cigarette)
            try context.save()
            
            print("✅ Widget successfully added cigarette to shared database")
            return true
            
        } catch {
            print("❌ Widget failed to add cigarette: \(error)")
            return false
        }
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