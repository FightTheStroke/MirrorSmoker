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
    var id: UUID = UUID()
    var name: String = ""
    var brand: String = ""
    var nicotineContent: Double = 0.0
    var price: Double = 0.0
    var cigarettesPerPack: Int = 20
    
    init(id: UUID = UUID(), name: String = "", brand: String = "", nicotineContent: Double = 0.0, price: Double = 0.0, cigarettesPerPack: Int = 20) {
        self.id = id
        self.name = name
        self.brand = brand
        self.nicotineContent = nicotineContent
        self.price = price
        self.cigarettesPerPack = cigarettesPerPack
    }
}