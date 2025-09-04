//
//  PremiumGatekeeper.swift
//  MirrorSmokerStopper
//
//  Created by Assistant on 03/09/25.
//

import SwiftUI

// MARK: - Premium Gatekeeper
@MainActor
class PremiumGatekeeper: ObservableObject {
    static let shared = PremiumGatekeeper()
    
    @Published private var storeManager = StoreManager.shared
    @Published var showingPaywall = false
    @Published var currentPaywallTrigger: StoreConfiguration.PaywallTrigger?
    
    private init() {}
    
    // MARK: - Feature Access Control
    func checkAccess(to feature: String, trigger: StoreConfiguration.PaywallTrigger) -> Bool {
        // Store disabled = all features free
        guard StoreConfiguration.isStoreEnabled else { return true }
        
        // User has subscription = all features available
        guard !storeManager.isSubscribed else { return true }
        
        // Feature is not premium = available to all
        guard StoreConfiguration.PremiumFeatures.allFeatures.contains(feature) else { return true }
        
        // Feature is premium and user doesn't have subscription = show paywall
        currentPaywallTrigger = trigger
        showingPaywall = true
        return false
    }
    
    // MARK: - Usage Limits
    func checkUsageLimit(
        for feature: String, 
        used: Int, 
        limit: Int, 
        trigger: StoreConfiguration.PaywallTrigger
    ) -> Bool {
        // Store disabled = unlimited usage
        guard StoreConfiguration.isStoreEnabled else { return true }
        
        // User has subscription = unlimited usage
        guard !storeManager.isSubscribed else { return true }
        
        // Under limit = allowed
        guard used >= limit else { return true }
        
        // Over limit = show paywall
        currentPaywallTrigger = trigger
        showingPaywall = true
        return false
    }
    
    // MARK: - Specific Feature Checks
    func canUseAdvancedAI() -> Bool {
        return checkAccess(to: StoreConfiguration.PremiumFeatures.advancedAICoaching, 
                          trigger: .aiCoachingLimit)
    }
    
    func canCreateMoreTags(currentCount: Int) -> Bool {
        return checkUsageLimit(
            for: StoreConfiguration.PremiumFeatures.unlimitedTags,
            used: currentCount,
            limit: StoreConfiguration.Limits.freeTagsLimit,
            trigger: .tagsLimit
        )
    }
    
    func canAccessDetailedAnalytics() -> Bool {
        return checkAccess(to: StoreConfiguration.PremiumFeatures.detailedAnalytics,
                          trigger: .analyticsAccess)
    }
    
    func canExportData() -> Bool {
        return checkAccess(to: StoreConfiguration.PremiumFeatures.exportData,
                          trigger: .exportData)
    }
    
    func canShareSocially() -> Bool {
        return checkAccess(to: StoreConfiguration.PremiumFeatures.socialSharing,
                          trigger: .socialSharing)
    }
    
    func canUseAdvancedWidgets() -> Bool {
        return checkAccess(to: StoreConfiguration.PremiumFeatures.advancedWidgets,
                          trigger: .advancedWidgets)
    }
    
    func canReceiveJITAI() -> Bool {
        return checkAccess(to: StoreConfiguration.PremiumFeatures.jitaiNotifications,
                          trigger: .aiCoachingLimit)
    }
    
    // MARK: - AI Coaching Limits
    func canGetMoreCoachingTips(usedToday: Int) -> Bool {
        return checkUsageLimit(
            for: StoreConfiguration.PremiumFeatures.advancedAICoaching,
            used: usedToday,
            limit: StoreConfiguration.Limits.freeCoachingTipsPerDay,
            trigger: .aiCoachingLimit
        )
    }
    
    // MARK: - Paywall Management
    func showPaywall(trigger: StoreConfiguration.PaywallTrigger) {
        currentPaywallTrigger = trigger
        showingPaywall = true
    }
    
    func hidePaywall() {
        showingPaywall = false
        currentPaywallTrigger = nil
    }
    
    // MARK: - Subscription Status
    var isSubscribed: Bool {
        return !StoreConfiguration.isStoreEnabled || storeManager.isSubscribed
    }
    
    var subscriptionStatus: String {
        if !StoreConfiguration.isStoreEnabled {
            return "All Features Unlocked (Development)"
        }
        
        return storeManager.isSubscribed ? "Premium Active" : "Free Plan"
    }
}

// MARK: - Premium Feature Wrapper
struct PremiumFeatureWrapper<Content: View>: View {
    let feature: String
    let trigger: StoreConfiguration.PaywallTrigger
    let content: Content
    let fallbackContent: (() -> AnyView)?
    
    @StateObject private var gatekeeper = PremiumGatekeeper.shared
    
    init(
        feature: String,
        trigger: StoreConfiguration.PaywallTrigger,
        fallbackContent: (() -> AnyView)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.feature = feature
        self.trigger = trigger
        self.content = content()
        self.fallbackContent = fallbackContent
    }
    
    var body: some View {
        Group {
            if gatekeeper.checkAccess(to: feature, trigger: trigger) {
                content
            } else if let fallback = fallbackContent {
                fallback()
            } else {
                premiumPlaceholder
            }
        }
        .sheet(isPresented: $gatekeeper.showingPaywall) {
            if let trigger = gatekeeper.currentPaywallTrigger {
                PaywallView(trigger: trigger)
            }
        }
    }
    
    private var premiumPlaceholder: some View {
        VStack(spacing: DS.AdaptiveSpace.md) {
            Image(systemName: "crown.fill")
                .font(.system(size: 32))
                .foregroundColor(DS.Colors.primary)
            
            Text("premium.feature.locked".local())
                .font(DS.Text.headline)
                .fontWeight(.semibold)
                .foregroundColor(DS.Colors.textPrimary)
            
            Text(trigger.subtitle)
                .font(DS.Text.body)
                .foregroundColor(DS.Colors.textSecondary)
                .multilineTextAlignment(.center)
            
            Button("premium.upgrade.now".local()) {
                gatekeeper.showPaywall(trigger: trigger)
            }
            .font(DS.Text.callout)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, DS.AdaptiveSpace.lg)
            .padding(.vertical, DS.AdaptiveSpace.sm)
            .background(DS.Colors.primary)
            .cornerRadius(DS.AdaptiveSize.buttonRadius)
        }
        .padding(DS.AdaptiveSpace.lg)
        .liquidGlassCard(elevation: DS.Shadow.medium)
    }
}

// MARK: - View Extensions
extension View {
    func premiumFeature(
        _ feature: String,
        trigger: StoreConfiguration.PaywallTrigger
    ) -> some View {
        PremiumFeatureWrapper(feature: feature, trigger: trigger) {
            self
        }
    }
    
    func premiumFeatureWithFallback<FallbackContent: View>(
        _ feature: String,
        trigger: StoreConfiguration.PaywallTrigger,
        @ViewBuilder fallback: @escaping () -> FallbackContent
    ) -> some View {
        PremiumFeatureWrapper(
            feature: feature,
            trigger: trigger,
            fallbackContent: { AnyView(fallback()) }
        ) {
            self
        }
    }
}