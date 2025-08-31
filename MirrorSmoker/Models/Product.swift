//
//  Product.swift
//  Mirror Smoker
//
//  Created by Roberto D'Angelo on 31/08/25.
//

import Foundation
import SwiftData

@Model
final class Product: Identifiable {
    var id: UUID = UUID()
    var name: String
    var brand: String
    var nicotineContent: Double // mg per cigarette
    var tarContent: Double // mg per cigarette
    var isActive: Bool
    var createdAt: Date
    
    // Relationship with cigarettes
    @Relationship(inverse: \Cigarette.product)
    var cigarettes: [Cigarette]
    
    init(name: String, 
         brand: String, 
         nicotineContent: Double = 0.0, 
         tarContent: Double = 0.0) {
        self.id = UUID()
        self.name = name
        self.brand = brand
        self.nicotineContent = nicotineContent
        self.tarContent = tarContent
        self.isActive = true
        self.createdAt = Date()
        self.cigarettes = []
    }
}
