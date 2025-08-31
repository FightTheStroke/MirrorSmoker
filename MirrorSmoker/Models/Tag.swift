//
//  Tag.swift
//  Mirror Smoker
//
//  Created by Roberto D'Angelo on 31/08/25.
//

import Foundation
import SwiftData

@Model
final class Tag: Identifiable {
    var id: UUID = UUID()
    var name: String
    var color: String // Store color as hex string
    var createdAt: Date
    
    // Many-to-many relationship with Cigarette
    @Relationship(inverse: \Cigarette.tags)
    var cigarettes: [Cigarette]
    
    init(name: String, color: String = "#FF0000", createdAt: Date = Date()) {
        self.id = UUID()
        self.name = name
        self.color = color
        self.createdAt = createdAt
        self.cigarettes = []
    }
}
