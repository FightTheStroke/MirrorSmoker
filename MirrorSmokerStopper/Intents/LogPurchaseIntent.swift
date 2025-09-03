//
//  LogPurchaseIntent.swift
//  MirrorSmokerStopper
//
//  Created by Assistant on 03/09/25.
//

import AppIntents
import SwiftData
import SwiftUI
import os.log

// MARK: - Logger
private let logger = Logger(subsystem: "com.fightthestroke.MirrorSmokerStopper", category: "LogPurchaseIntent")

@available(iOS 16.0, macOS 13.0, watchOS 9.0, *)
struct LogPurchaseIntent: AppIntent {
    static var title: LocalizedStringResource = "intent.log.purchase.title"
    static var description = IntentDescription("Log a tobacco product purchase")
    
    static var suggestedInvocationPhrase: String = "I bought cigarettes"
    
    @Parameter(title: "Product Name", description: "Name of the tobacco product purchased")
    var productName: String
    
    @Parameter(title: "Amount", description: "Price of the product")
    var amount: Double
    
    @Parameter(title: "Currency", description: "Currency code (e.g. USD, EUR)")
    var currencyCode: String = "USD"
    
    @Parameter(title: "Quantity", description: "Number of items purchased")
    var quantity: Int = 1
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let modelContext = ModelContext(sharedModelContainer)
        
        // Create the purchase record
        let purchase = Purchase()
        purchase.timestamp = Date()
        purchase.productName = productName
        purchase.setAmountFromCurrency(amount)
        purchase.currencyCode = currencyCode.uppercased()
        purchase.quantity = max(1, quantity)
        
        // Save the purchase
        modelContext.insert(purchase)
        try modelContext.save()
        
        let message = "Purchase of \(productName) for \(formatCurrency(amount, currencyCode)) recorded successfully"
        
        return .result(dialog: IntentDialog(stringLiteral: message))
    }
    
    private func formatCurrency(_ amount: Double, _ currencyCode: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode.uppercased()
        return formatter.string(from: NSNumber(value: amount)) ?? "\(amount) \(currencyCode.uppercased())"
    }
}