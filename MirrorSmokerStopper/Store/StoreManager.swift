//
//  StoreManager.swift
//  MirrorSmokerStopper
//
//  Created by Assistant on 03/09/25.
//

import Foundation
import StoreKit
import SwiftUI
import os.log

// MARK: - Subscription Status
enum SubscriptionStatus {
    case loading
    case active
    case inactive
    case failed(Error)
}

// MARK: - Purchase Result
enum PurchaseResult {
    case success
    case cancelled
    case failed(Error)
    case pending
}

// MARK: - Store Manager
@MainActor
class StoreManager: ObservableObject {
    static let shared = StoreManager()
    
    private let logger = Logger(subsystem: "com.fightthestroke.MirrorSmokerStopper", category: "StoreManager")
    
    // MARK: - Published Properties
    @Published var subscriptionStatus: SubscriptionStatus = .loading
    @Published var products: [StoreKit.Product] = []
    @Published var isSubscribed: Bool = false
    @Published var currentProductID: String?
    
    // MARK: - Private Properties
    private var updateListenerTask: Task<Void, Error>?
    
    private init() {
        guard StoreConfiguration.isStoreEnabled else {
            logger.info("🏪 Store is DISABLED - All features are free")
            subscriptionStatus = .inactive
            isSubscribed = true // All features available when store disabled
            return
        }
        
        logger.info("🏪 Store is ENABLED - Initializing StoreKit")
        
        // Start listening for transaction updates
        updateListenerTask = listenForTransactions()
        
        Task {
            await loadProducts()
            await updateSubscriptionStatus()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Product Loading
    func loadProducts() async {
        guard StoreConfiguration.isStoreEnabled else { return }
        
        do {
            let products = try await StoreKit.Product.products(for: StoreConfiguration.ProductIDs.allProductIDs)
            self.products = products.sorted { $0.price < $1.price }
            logger.info("✅ Loaded \(products.count) products successfully")
        } catch {
            logger.error("❌ Failed to load products: \(error.localizedDescription)")
            await MainActor.run {
                self.subscriptionStatus = .failed(error)
            }
        }
    }
    
    // MARK: - Purchase
    func purchase(_ product: StoreKit.Product) async -> PurchaseResult {
        guard StoreConfiguration.isStoreEnabled else { 
            return .success // Simulate success when store disabled
        }
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                await handleSuccessfulPurchase(verification)
                return .success
            case .userCancelled:
                logger.info("🚫 User cancelled purchase")
                return .cancelled
            case .pending:
                logger.info("⏳ Purchase is pending")
                return .pending
            @unknown default:
                logger.warning("❓ Unknown purchase result")
                return .failed(StoreError.unknown)
            }
        } catch {
            logger.error("❌ Purchase failed: \(error.localizedDescription)")
            return .failed(error)
        }
    }
    
    // MARK: - Restore Purchases
    func restorePurchases() async throws {
        guard StoreConfiguration.isStoreEnabled else { return }
        
        try await AppStore.sync()
        await updateSubscriptionStatus()
        logger.info("🔄 Purchases restored")
    }
    
    // MARK: - Subscription Status Update
    private func updateSubscriptionStatus() async {
        guard StoreConfiguration.isStoreEnabled else {
            await MainActor.run {
                self.isSubscribed = true
                self.subscriptionStatus = .inactive
            }
            return
        }
        
        var hasActiveSubscription = false
        var activeProductID: String?
        
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                
                if transaction.productType == .autoRenewable {
                    hasActiveSubscription = true
                    activeProductID = transaction.productID
                    break
                } else if transaction.productType == .nonConsumable {
                    // Lifetime purchase
                    hasActiveSubscription = true
                    activeProductID = transaction.productID
                    break
                }
            } catch {
                logger.error("❌ Failed to verify transaction: \(error.localizedDescription)")
            }
        }
        
        await MainActor.run {
            self.isSubscribed = hasActiveSubscription
            self.currentProductID = activeProductID
            self.subscriptionStatus = hasActiveSubscription ? .active : .inactive
            
            // Store in UserDefaults for offline access
            UserDefaults.standard.set(hasActiveSubscription, forKey: "isProUser")
            UserDefaults.standard.set(activeProductID, forKey: "activeProductID")
        }
        
        logger.info("📊 Subscription status updated: \(hasActiveSubscription ? "ACTIVE" : "INACTIVE")")
    }
    
    // MARK: - Transaction Listening
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try await self.checkVerified(result)
                    await self.updateSubscriptionStatus()
                    await transaction.finish()
                } catch {
                    self.logger.error("❌ Transaction verification failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Transaction Verification
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    // MARK: - Handle Successful Purchase
    private func handleSuccessfulPurchase(_ verificationResult: VerificationResult<StoreKit.Transaction>) async {
        do {
            let transaction = try checkVerified(verificationResult)
            await updateSubscriptionStatus()
            await transaction.finish()
            
            // Trigger celebration/success UI
            NotificationCenter.default.post(name: .purchaseSuccessful, object: transaction.productID)
            
            logger.info("🎉 Purchase successful: \(transaction.productID)")
        } catch {
            logger.error("❌ Failed to handle successful purchase: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Feature Access Helpers
    func hasAccess(to feature: String) -> Bool {
        guard StoreConfiguration.isStoreEnabled else { return true }
        return isSubscribed || !StoreConfiguration.PremiumFeatures.allFeatures.contains(feature)
    }
    
    func remainingLimit(for feature: String, used: Int) -> Int {
        guard StoreConfiguration.isStoreEnabled else { return Int.max }
        guard !isSubscribed else { return Int.max }
        
        switch feature {
        case StoreConfiguration.PremiumFeatures.unlimitedTags:
            return max(0, StoreConfiguration.Limits.freeTagsLimit - used)
        case StoreConfiguration.PremiumFeatures.advancedAICoaching:
            return max(0, StoreConfiguration.Limits.freeCoachingTipsPerDay - used)
        default:
            return Int.max
        }
    }
    
    // MARK: - Product Helpers
    func product(for productID: String) -> StoreKit.Product? {
        return products.first { $0.id == productID }
    }
    
    var monthlyProduct: StoreKit.Product? {
        return product(for: StoreConfiguration.ProductIDs.monthlySubscription)
    }
    
    var yearlyProduct: StoreKit.Product? {
        return product(for: StoreConfiguration.ProductIDs.yearlySubscription)
    }
    
    var lifetimeProduct: StoreKit.Product? {
        return product(for: StoreConfiguration.ProductIDs.lifetimeUnlock)
    }
}

// MARK: - Store Errors
enum StoreError: Error, LocalizedError {
    case failedVerification
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return "store.error.verification".local()
        case .unknown:
            return "store.error.unknown".local()
        }
    }
}

// MARK: - Notifications
extension NSNotification.Name {
    static let purchaseSuccessful = NSNotification.Name("purchaseSuccessful")
    static let purchaseFailed = NSNotification.Name("purchaseFailed")
}