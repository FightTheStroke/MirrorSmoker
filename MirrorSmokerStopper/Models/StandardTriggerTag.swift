//
//  StandardTriggerTag.swift
//  MirrorSmokerStopper
//
//  Created by Claude on 09/01/25.
//

import Foundation
import SwiftUI
import SwiftData

/// Pre-defined standard tags for common smoking triggers
enum StandardTriggerTag: String, CaseIterable {
    // Most common smoking triggers
    case stress = "tag.stress"
    case coffee = "tag.coffee"
    case afterMeal = "tag.meal"
    case work = "tag.work"
    case alcohol = "tag.alcohol"
    
    /// Localized name for the tag
    var localizedName: String {
        NSLocalizedString(self.rawValue, comment: "")
    }
    
    /// Emoji representation for the tag
    var emoji: String {
        switch self {
        case .stress: return "😰"
        case .coffee: return "☕"
        case .afterMeal: return "🍽️"
        case .work: return "💼"
        case .alcohol: return "🍺"
        }
    }
    
    /// Default color for the standard tag
    var defaultColor: String {
        switch self {
        case .stress:
            return "#FF3B30"  // Red for stress
        case .coffee:
            return "#8B4513"  // Brown for coffee
        case .afterMeal:
            return "#34C759"  // Green for meal
        case .work:
            return "#007AFF"  // Blue for work
        case .alcohol:
            return "#FFCC00"  // Yellow for alcohol
        }
    }
    
    /// Check if a tag name matches a standard tag
    static func isStandardTag(name: String) -> Bool {
        let lowercasedName = name.lowercased()
        return Self.allCases.contains { tag in
            tag.localizedName.lowercased() == lowercasedName ||
            tag.rawValue.replacingOccurrences(of: "tag.", with: "").lowercased() == lowercasedName
        }
    }
    
    /// Create or get existing Tag model for this standard tag
    func getOrCreateTag(in context: ModelContext) -> Tag? {
        let tagName = self.localizedName
        
        // First check if tag already exists
        let descriptor = FetchDescriptor<Tag>(
            predicate: #Predicate { tag in
                tag.name == tagName
            }
        )
        
        do {
            let existingTags = try context.fetch(descriptor)
            if let existingTag = existingTags.first {
                return existingTag
            }
            
            // Create new tag if it doesn't exist
            let newTag = Tag(
                name: tagName,
                colorHex: self.defaultColor
            )
            context.insert(newTag)
            return newTag
            
        } catch {
            // Error fetching/creating standard tag
            return nil
        }
    }
}

// MARK: - Tag Extension for Standard Tags
extension Tag {
    /// Check if this tag corresponds to a standard tag
    var isStandardTag: Bool {
        StandardTriggerTag.isStandardTag(name: self.name)
    }
    
    /// Get the corresponding standard tag enum if this is a standard tag
    var standardTag: StandardTriggerTag? {
        StandardTriggerTag.allCases.first { standardTag in
            standardTag.localizedName.lowercased() == self.name.lowercased()
        }
    }
    
    /// Get emoji for the tag (standard tags have emojis, custom tags don't)
    var emoji: String? {
        standardTag?.emoji
    }
}