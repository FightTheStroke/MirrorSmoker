//
//  Item.swift
//  testios26p1
//
//  Created by Roberto D’Angelo on 31/08/25.
//

import Foundation
import SwiftData

@Model
final class Cigarette {
    var timestamp: Date
    var note: String
    
    init(timestamp: Date = Date(), note: String = "") {
        self.timestamp = timestamp
        self.note = note
    }
    
    // Computed property per ottenere solo la data (senza orario)
    var dayOnly: Date {
        Calendar.current.startOfDay(for: timestamp)
    }
}
