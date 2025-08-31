//
//  Cigarette.swift
//  Mirror Smoker
//
//  Created by Roberto D'Angelo on 31/08/25.
//

import Foundation
import SwiftData

@Model
final class Cigarette: Identifiable {
    var id: UUID = UUID()
    var timestamp: Date
    var note: String
    
    // Many-to-many relationship with Tag
    var tags: [Tag]
    
    // Optional relationship with Product
    var product: Product?
    
    // Custom convenience init
    init(timestamp: Date = Date(), note: String = "", tags: [Tag] = [], product: Product? = nil) {
        self.id = UUID()
        self.timestamp = timestamp
        self.note = note
        self.tags = tags
        self.product = product
    }
    
    // Computed property per ottenere solo la data (senza orario)
    var dayOnly: Date {
        Calendar.current.startOfDay(for: timestamp)
    }
}