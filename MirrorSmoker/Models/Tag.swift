//
//  Tag.swift
//  Mirror Smoker
//
//  Created by Roberto D'Angelo on 27/08/24.
//

import Foundation
import SwiftData

@Model
final class Tag {
    @Attribute(.unique) var id: UUID
    var name: String
    var colorHex: String
    
    init(id: UUID = UUID(), name: String = "", colorHex: String = "#007AFF") {
        self.id = id
        self.name = name
        self.colorHex = colorHex
    }
}