//
//  Purchase.swift
//  MirrorSmokerStopper
//
//  Created by Assistant on 03/09/25.
//

import Foundation
import SwiftData

@Model
final class Purchase {
    var id: UUID = UUID()
    var timestamp: Date = Date()
    var amountInCents: Int = 0 // Store amounts in cents to avoid floating point precision issues
    var currencyCode: String = "USD" // ISO 4217 currency code
    var productName: String = ""
    var quantity: Int = 1
    
    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        amountInCents: Int = 0,
        currencyCode: String = "USD",
        productName: String = "",
        quantity: Int = 1
    ) {
        self.id = id
        self.timestamp = timestamp
        self.amountInCents = amountInCents
        self.currencyCode = currencyCode
        self.productName = productName
        self.quantity = quantity
    }
    
    // Computed property to get amount in dollars (or main currency unit)
    var amountInCurrency: Double {
        return Double(amountInCents) / 100.0
    }
    
    // Helper method to set amount from currency value
    func setAmountFromCurrency(_ amount: Double) {
        self.amountInCents = Int(amount * 100)
    }
}