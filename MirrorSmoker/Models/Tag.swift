//
//  Tag.swift
//  Mirror Smoker
//
//  Created by Roberto D'Angelo on 27/08/24.
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class Tag {
    var id: UUID = UUID()
    var name: String = ""
    var colorHex: String = "#007AFF"
    var cigarettes: [Cigarette]?
    
    init(id: UUID = UUID(), name: String = "", colorHex: String = "#007AFF", cigarettes: [Cigarette]? = nil) {
        self.id = id
        self.name = name
        self.colorHex = colorHex
        self.cigarettes = cigarettes
    }
    
    // Computed property for SwiftUI Color
    var color: Color {
        Color.fromHex(colorHex) ?? .blue
    }
}