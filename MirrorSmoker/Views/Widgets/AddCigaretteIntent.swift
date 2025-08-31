//
//  AddCigaretteIntent.swift
//  Mirror Smoker
//
//  Created by Roberto D'Angelo on 31/08/25.
//

#if os(iOS) && canImport(AppIntents)
import AppIntents
import SwiftData

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
        // In a real app, you would access the SwiftData context here
        // and insert the new cigarette
        
        let timestamp = Date()
        let noteText = note ?? ""
        let tagNames = tags ?? []
        
        // This is a placeholder - in reality you'd need to:
        // 1. Access the shared ModelContainer
        // 2. Create a new Cigarette
        // 3. Find or create the specified tags
        // 4. Insert the cigarette into the context
        
        return .result(value: "Added cigarette at \(timestamp.formatted(date: .omitted, time: .shortened))")
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
