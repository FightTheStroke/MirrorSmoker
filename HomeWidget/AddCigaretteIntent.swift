//
//  AddCigaretteIntent.swift
//  HomeWidget
//
//  Created by Claude on 02/09/25.
//

import AppIntents
import WidgetKit

// MARK: - Add Cigarette Intent
struct AddCigaretteIntent: AppIntent {
    static var title: LocalizedStringResource = "widget.intent.add.cigarette"
    static var description = IntentDescription("widget.intent.add.cigarette.description")
    
    // No parameters needed - just add a cigarette with current timestamp
    
    func perform() async throws -> some IntentResult {
        let dataProvider = WidgetDataProvider()
        
        let success = await dataProvider.addCigaretteFromWidget()
        
        if success {
            // Refresh all widget timelines
            WidgetCenter.shared.reloadAllTimelines()
            
            return .result(dialog: IntentDialog("widget.intent.success"))
        } else {
            throw IntentError.addFailed
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