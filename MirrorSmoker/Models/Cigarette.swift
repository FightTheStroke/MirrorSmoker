//
//  Cigarette.swift
//  Mirror Smoker
//
//  Created by Roberto D'Angelo on 27/08/24.
//

import Foundation
import SwiftData

@Model
final class Cigarette {
    @Attribute(.unique) var id: UUID
    var timestamp: Date
    var note: String
    var tags: [Tag]?
    
    init(id: UUID = UUID(), timestamp: Date = Date(), note: String = "", tags: [Tag]? = nil) {
        self.id = id
        self.timestamp = timestamp
        self.note = note
        self.tags = tags
    }
}