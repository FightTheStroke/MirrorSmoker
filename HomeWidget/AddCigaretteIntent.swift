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
    
    // No parameters needed - just add a cigarette with current timestamp
    
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
        guard let url = WidgetAppGroupManager.sharedContainer else {
            return false
        }
        
        let storeURL = url.appendingPathComponent("MirrorSmoker.sqlite")
        
        do {
            let schema = Schema([WidgetCigarette.self])
            let config = ModelConfiguration(url: storeURL, cloudKitDatabase: .automatic)
            let container = try ModelContainer(for: schema, configurations: [config])
            let context = ModelContext(container)
            
            // Create and save cigarette
            let cigarette = WidgetCigarette(
                timestamp: Date(),
                note: NSLocalizedString("added.from.widget", comment: "Added from widget")
            )
            
            context.insert(cigarette)
            try context.save()
            
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