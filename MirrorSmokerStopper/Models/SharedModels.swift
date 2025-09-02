//
//  SharedModels.swift
//  Mirror Smoker
//
//  Created by Roberto D'Angelo on 31/08/25.
//

import Foundation

// Shared struct to represent a cigarette in widget data
public struct WidgetCigarette: Codable {
    public let timestamp: TimeInterval
    public let note: String
    public let tagIds: [String]
    
    public init(timestamp: TimeInterval, note: String = "", tagIds: [String] = []) {
        self.timestamp = timestamp
        self.note = note
        self.tagIds = tagIds
    }
}

// Extension to convert between Cigarette and WidgetCigarette
extension Cigarette {
    func toWidgetCigarette() -> WidgetCigarette {
        return WidgetCigarette(
            timestamp: timestamp.timeIntervalSince1970,
            note: note,
            tagIds: tags?.map { $0.id.uuidString } ?? []
        )
    }
}