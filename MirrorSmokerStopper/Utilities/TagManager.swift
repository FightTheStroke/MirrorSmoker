//
//  TagManager.swift
//  MirrorSmokerStopper
//
//  Unified tag management system
//

import SwiftUI
import SwiftData
import os.log

@MainActor
class TagManager: ObservableObject {
    static let shared = TagManager()
    
    private static let logger = Logger(subsystem: "com.fightthestroke.MirrorSmokerStopper", category: "TagManager")
    
    // Predefined tags with localized names and colors
    static let defaultTags: [(nameKey: String, color: String, icon: String)] = [
        ("tag.stress", "#FF6B6B", "brain.head.profile"),
        ("tag.work", "#4DABF7", "briefcase.fill"),
        ("tag.coffee", "#8B6F3A", "cup.and.saucer.fill"),
        ("tag.social", "#F06595", "person.2.fill"),
        ("tag.meal", "#FFA94D", "fork.knife"),
        ("tag.alcohol", "#CC5DE8", "wineglass.fill"),
        ("tag.driving", "#69DB7C", "car.fill"),
        ("tag.morning", "#FFD43B", "sunrise.fill"),
        ("tag.evening", "#748FFC", "moon.fill"),
        ("tag.boredom", "#868E96", "clock.fill"),
        ("tag.anxiety", "#FF8787", "exclamationmark.triangle.fill"),
        ("tag.celebration", "#A9E34B", "party.popper.fill")
    ]
    
    // Initialize default tags if none exist
    func initializeDefaultTags(in context: ModelContext) async {
        do {
            // Check if tags already exist
            let descriptor = FetchDescriptor<Tag>()
            let existingTags = try context.fetch(descriptor)
            
            if existingTags.isEmpty {
                Self.logger.info("No tags found, creating default tags")
                
                // Create default tags
                for tagInfo in Self.defaultTags {
                    let tag = Tag(
                        name: tagInfo.nameKey, // Store the key instead of localized string
                        colorHex: tagInfo.color
                    )
                    context.insert(tag)
                }
                
                // Save the context
                try context.save()
                Self.logger.info("Created \(Self.defaultTags.count) default tags")
            } else {
                Self.logger.info("Found \(existingTags.count) existing tags")
                // Migrate existing localized tags to use keys
                await migrateExistingTagsToKeys(existingTags, in: context)
            }
        } catch {
            Self.logger.error("Failed to initialize tags: \(error)")
        }
    }
    
    private func migrateExistingTagsToKeys(_ tags: [Tag], in context: ModelContext) async {
        var migratedCount = 0
        
        for tag in tags {
            // Check if this tag matches any of our default localized names
            for tagInfo in Self.defaultTags {
                let localizedName = NSLocalizedString(tagInfo.nameKey, comment: "")
                if tag.name == localizedName && !tag.name.hasPrefix("tag.") {
                    // This tag needs migration - update to use the key
                    tag.name = tagInfo.nameKey
                    migratedCount += 1
                    Self.logger.info("Migrated tag '\(localizedName)' to key '\(tagInfo.nameKey)'")
                    break
                }
            }
        }
        
        if migratedCount > 0 {
            do {
                try context.save()
                Self.logger.info("Migrated \(migratedCount) tags to use localization keys")
            } catch {
                Self.logger.error("Failed to save migrated tags: \(error)")
            }
        }
    }
    
    // MARK: - Localization Helper
    
    static func localizedName(for tag: Tag) -> String {
        // Check if this is a default tag (starts with "tag.")
        if tag.name.hasPrefix("tag.") {
            return NSLocalizedString(tag.name, comment: "")
        } else {
            // Custom tag - return name as is
            return tag.name
        }
    }
    
    // Add a new custom tag
    func addTag(name: String, colorHex: String, in context: ModelContext) throws {
        // Check if tag with same name exists
        let descriptor = FetchDescriptor<Tag>(
            predicate: #Predicate { tag in
                tag.name == name
            }
        )
        
        let existing = try context.fetch(descriptor)
        if !existing.isEmpty {
            throw TagError.duplicateName
        }
        
        let newTag = Tag(name: name, colorHex: colorHex)
        context.insert(newTag)
        try context.save()
        
        // Sync with widget and watch
        SyncCoordinator.shared.tagAdded(from: .app, tag: newTag)
        
        Self.logger.info("Added new tag: \(name)")
    }
    
    // Update an existing tag
    func updateTag(_ tag: Tag, name: String? = nil, colorHex: String? = nil, in context: ModelContext) throws {
        if let name = name {
            tag.name = name
        }
        if let colorHex = colorHex {
            tag.colorHex = colorHex
        }
        
        try context.save()
        
        // Sync with widget and watch
        SyncCoordinator.shared.tagUpdated(from: .app, tag: tag)
        
        Self.logger.info("Updated tag: \(tag.name)")
    }
    
    // Delete a tag
    func deleteTag(_ tag: Tag, in context: ModelContext) throws {
        context.delete(tag)
        try context.save()
        Self.logger.info("Deleted tag: \(tag.name)")
    }
    
    // Toggle tag selection for a cigarette
    func toggleTag(_ tag: Tag, for cigarette: Cigarette, in context: ModelContext) throws {
        if cigarette.tags == nil {
            cigarette.tags = []
        }
        
        if let index = cigarette.tags?.firstIndex(where: { $0.id == tag.id }) {
            cigarette.tags?.remove(at: index)
            Self.logger.info("Removed tag \(tag.name) from cigarette")
        } else {
            cigarette.tags?.append(tag)
            Self.logger.info("Added tag \(tag.name) to cigarette")
        }
        
        try context.save()
    }
}

enum TagError: LocalizedError {
    case duplicateName
    
    var errorDescription: String? {
        switch self {
        case .duplicateName:
            return NSLocalizedString("tag.error.duplicate", comment: "A tag with this name already exists")
        }
    }
}

// MARK: - Tag Color Extension
extension Tag {
    var uiColor: UIColor {
        UIColor(hex: colorHex) ?? .systemBlue
    }
}

// MARK: - UIColor Hex Extension
extension UIColor {
    convenience init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        
        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
}