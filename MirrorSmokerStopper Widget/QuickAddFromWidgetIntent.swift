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
    static var title: LocalizedStringResource = "widget.quick.add.cigarette"
    static var description = IntentDescription("widget.quick.add.description")
    
    @Parameter(title: "widget.note.title", description: "widget.note.description")
    var note: String?
    
    @Parameter(title: "widget.tags.title", description: "widget.tags.description")
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