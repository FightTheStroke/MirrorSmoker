//
//  Product.swift
//  Mirror Smoker
//
//  Created by Roberto D'Angelo on 27/08/24.
//

import Foundation
import SwiftData

@Model
final class Product {
    @Attribute(.unique) var id: UUID
    var name: String
    var brand: String
    var nicotineContent: Double
    
    init(id: UUID = UUID(), name: String = "", brand: String = "", nicotineContent: Double = 0.0) {
        self.id = id
        self.name = name
        self.brand = brand
        self.nicotineContent = nicotineContent
    }
}