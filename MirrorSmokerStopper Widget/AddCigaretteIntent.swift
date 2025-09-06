//
//  AddCigaretteIntent.swift
//  MirrorStokerStopper Widget
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
        // Enqueue a pending cigarette in the shared App Group for the main app to process
        let groupIdentifier = "group.fightthestroke.mirrorsmoker"
        guard let ud = UserDefaults(suiteName: groupIdentifier) else {
            return .result(value: "Shared group not available")
        }
        var pending = ud.array(forKey: "widget_pending_cigarettes") as? [Double] ?? []
        pending.append(Date().timeIntervalSince1970)
        ud.set(pending, forKey: "widget_pending_cigarettes")
        // Bump lastUpdated so the app's SyncCoordinator detects external changes
        ud.set(Date(), forKey: "lastUpdated")
        
        // Ask WidgetKit to refresh
        WidgetKit.WidgetCenter.shared.reloadAllTimelines()
        
        let ts = Date()
        return .result(value: "Added at \(ts.formatted(date: .omitted, time: .shortened))")
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
