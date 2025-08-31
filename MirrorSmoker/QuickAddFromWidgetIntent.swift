//
//  QuickAddFromWidgetIntent.swift
//  Mirror Smoker
//
//  Created by Roberto D'Angelo on 31/08/25.
//

#if os(iOS) && canImport(AppIntents)
import AppIntents
import WidgetKit

struct QuickAddFromWidgetIntent: AppIntent {
    static var title: LocalizedStringResource = "Quick Add Cigarette"
    static var description = IntentDescription("Quickly add a cigarette entry")
    
    @Parameter(title: "Note", description: "Optional note for the cigarette")
    var note: String?
    
    @Parameter(title: "Tags", description: "Optional tags for the cigarette")
    var tags: [String]?
    
    func perform() async throws -> some IntentResult {
        // Call the WidgetStore method to enqueue the quick add
        WidgetStore.enqueueQuickAdd(note: note ?? "", tagNames: tags ?? [])
        
        // Reload the widget timeline to update the display
        WidgetCenter.shared.reloadTimelines(ofKind: "CigaretteWidget")
        
        return .result()
    }
}
#endif