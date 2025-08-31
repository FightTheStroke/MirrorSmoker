//
//  WidgetStore.swift
//  Mirror Smoker
//
//  Created by Roberto D'Angelo on 31/08/25.
//

import WidgetKit
import SwiftData

// Make WidgetStore a singleton class
class WidgetStore {
    static let shared = WidgetStore()
    
    private var modelContext: ModelContext?
    
    private init() {}
    
    func configure(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    static func readSnapshot() -> (todayCount: Int, lastCigaretteTime: String) {
        // Placeholder implementation
        return (todayCount: 0, lastCigaretteTime: "--:--")
    }
    
    // Add the missing enqueueQuickAdd method
    static func enqueueQuickAdd(note: String, tagNames: [String]) {
        // Placeholder implementation
        print("Enqueue quick add: \(note), tags: \(tagNames)")
    }
}