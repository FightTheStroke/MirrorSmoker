//
//  AddCigaretteIntent.swift
//  MirrorStokerStopper Widget
//
//  Created by Roberto D'Angelo on 31/08/25.
//

#if os(iOS) && canImport(AppIntents)
import AppIntents
import SwiftData
import WidgetKit
import Foundation

@available(iOS 16.0, *)
struct AddCigaretteIntent: AppIntent {
    static var title: LocalizedStringResource = "Add Cigarette"
    static var description: IntentDescription = IntentDescription("Add a new cigarette to your tracker")
    
    @Parameter(title: "Note", description: "Optional note for this cigarette")
    var note: String?
    
    @Parameter(title: "Tags", description: "Tags to associate with this cigarette")
    var tags: [String]?
    
    init() {}
    
    init(note: String? = nil, tags: [String]? = nil) {
        self.note = note
        self.tags = tags
    }
    
    func perform() async throws -> some IntentResult {
        let success = await addCigaretteToSharedDatabase()
        
        if success {
            // Refresh all widget timelines immediately
            WidgetCenter.shared.reloadAllTimelines()
            
            return .result(dialog: IntentDialog("Cigarette added successfully"))
        } else {
            throw IntentError.addFailed
        }
    }
    
    // MARK: - Database Access
    private func addCigaretteToSharedDatabase() async -> Bool {
        guard let container = AppGroupManager.sharedModelContainer else {
            return false
        }
        
        let context = ModelContext(container)
        
        do {
            // Create and save cigarette using the real Cigarette model
            let cigarette = Cigarette(
                timestamp: Date(),
                note: note ?? "Added from widget"
            )
            
            context.insert(cigarette)
            try context.save()
            
            // Update shared UserDefaults for synchronization
            if let userDefaults = UserDefaults(suiteName: "group.fightthestroke.mirrorsmoker") {
                // Update timestamp and source for sync detection
                userDefaults.set(Date(), forKey: "lastUpdated")
                userDefaults.set("widget", forKey: "lastUpdateSource")
                
                // Update today's count for quick access
                let today = Calendar.current.startOfDay(for: Date())
                let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
                
                let todayDescriptor = FetchDescriptor<Cigarette>(
                    predicate: #Predicate<Cigarette> { c in
                        c.timestamp >= today && c.timestamp < tomorrow
                    }
                )
                
                let todayCigarettes = try context.fetch(todayDescriptor)
                userDefaults.set(todayCigarettes.count, forKey: "todayCount")
                
                // Save cigarette data for Watch sync
                let cigarettesData = todayCigarettes.map { cig in
                    [
                        "id": cig.id.uuidString,
                        "timestamp": cig.timestamp.timeIntervalSince1970,
                        "note": cig.note
                    ]
                }
                
                if let encoded = try? JSONSerialization.data(withJSONObject: cigarettesData) {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    userDefaults.set(encoded, forKey: "cigarettes_\(formatter.string(from: Date()))")
                }
                
                // Notify the main app that a cigarette was added from widget
                userDefaults.set(true, forKey: "widget_cigarette_added")
            }
            
            return true
            
        } catch {
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
            return "Failed to add cigarette"
        }
    }
}

@available(iOS 16.0, *)
struct AddCigaretteShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddCigaretteIntent(),
            phrases: [
                // English
                "Add cigarette in \(.applicationName)",
                "Log cigarette in \(.applicationName)",
                "Track cigarette in \(.applicationName)",
                "I smoked a cigarette with \(.applicationName)",
                // Italian
                "Aggiungi sigaretta in \(.applicationName)",
                "Registra sigaretta in \(.applicationName)",
                "Traccia sigaretta in \(.applicationName)",
                "Ho fumato una sigaretta con \(.applicationName)"
            ],
            shortTitle: "Add Cigarette",
            systemImageName: "plus.circle"
        )
    }
}
#endif
