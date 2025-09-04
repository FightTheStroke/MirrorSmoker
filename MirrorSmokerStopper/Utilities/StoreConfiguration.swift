//
//  StoreConfiguration.swift
//  MirrorSmokerStopper
//
//  Created by Assistant on 03/09/25.
//

import Foundation

// MARK: - Global Store Configuration
/// Global flag to enable/disable all store-related functionality
/// Set to `true` for App Store builds, `false` for development/testing
public let STORE_ENABLED = false // 🔧 CHANGE THIS TO `true` TO ENABLE STORE FUNCTIONALITY

// MARK: - Store Configuration
struct StoreConfiguration {
    
    // MARK: - Store Status
    static var isStoreEnabled: Bool {
        return STORE_ENABLED
    }
    
    // MARK: - Product IDs (App Store Connect Configuration)
    struct ProductIDs {
        static let monthlySubscription = "com.fightthestroke.mirrorsmoker.monthly"
        static let yearlySubscription = "com.fightthestroke.mirrorsmoker.yearly"
        static let lifetimeUnlock = "com.fightthestroke.mirrorsmoker.lifetime"
        
        static var allProductIDs: [String] {
            return [monthlySubscription, yearlySubscription, lifetimeUnlock]
        }
    }
    
    // MARK: - Premium Features Configuration
    struct PremiumFeatures {
        // AI Coach Advanced Features
        static let advancedAICoaching = "advanced_ai_coaching"
        static let jitaiNotifications = "jitai_notifications" 
        static let behavioralInsights = "behavioral_insights"
        
        // Social & Sharing
        static let socialSharing = "social_sharing"
        static let supportCircles = "support_circles"
        static let milestoneSharing = "milestone_sharing"
        
        // Advanced Analytics
        static let detailedAnalytics = "detailed_analytics"
        static let exportData = "export_data"
        static let trendPredictions = "trend_predictions"
        
        // Customization
        static let customThemes = "custom_themes"
        static let advancedWidgets = "advanced_widgets"
        static let unlimitedTags = "unlimited_tags"
        
        // Health Integration
        static let advancedHealthKit = "advanced_healthkit"
        static let nrtTracking = "nrt_tracking"
        static let biometricsIntegration = "biometrics_integration"
        
        static var allFeatures: [String] {
            return [
                advancedAICoaching, jitaiNotifications, behavioralInsights,
                socialSharing, supportCircles, milestoneSharing,
                detailedAnalytics, exportData, trendPredictions,
                customThemes, advancedWidgets, unlimitedTags,
                advancedHealthKit, nrtTracking, biometricsIntegration
            ]
        }
    }
    
    // MARK: - Free vs Premium Limits
    struct Limits {
        // Tags
        static let freeTagsLimit = 5
        static let premiumTagsLimit = Int.max
        
        // AI Coaching
        static let freeCoachingTipsPerDay = 3
        static let premiumCoachingTipsPerDay = Int.max
        
        // Data Export
        static let freeExportDays = 7
        static let premiumExportDays = Int.max
        
        // Analytics History
        static let freeAnalyticsDays = 30
        static let premiumAnalyticsDays = Int.max
    }
    
    // MARK: - Pricing Display (for UI)
    struct Pricing {
        static let monthlyPrice = "$3.99"
        static let yearlyPrice = "$31.99"
        static let lifetimePrice = "$79.99"
        
        static let yearlyDiscount = "33%"
    }
    
    // MARK: - Feature Availability Check
    @MainActor static func isFeatureAvailable(_ feature: String) -> Bool {
        // If store is disabled, all features are free
        guard isStoreEnabled else { return true }
        
        // Check if user has premium subscription
        return StoreManager.shared.isSubscribed || !PremiumFeatures.allFeatures.contains(feature)
    }
    
    // MARK: - Paywall Triggers
    enum PaywallTrigger: String, CaseIterable {
        case aiCoachingLimit = "ai_coaching_limit"
        case tagsLimit = "tags_limit" 
        case analyticsAccess = "analytics_access"
        case exportData = "export_data"
        case socialSharing = "social_sharing"
        case advancedWidgets = "advanced_widgets"
        case onboarding = "onboarding"
        case settingsUpgrade = "settings_upgrade"
        
        var title: String {
            switch self {
            case .aiCoachingLimit: return "paywall.ai.coaching.title".local()
            case .tagsLimit: return "paywall.tags.limit.title".local()
            case .analyticsAccess: return "paywall.analytics.title".local()
            case .exportData: return "paywall.export.title".local()
            case .socialSharing: return "paywall.social.title".local()
            case .advancedWidgets: return "paywall.widgets.title".local()
            case .onboarding: return "paywall.onboarding.title".local()
            case .settingsUpgrade: return "paywall.settings.title".local()
            }
        }
        
        var subtitle: String {
            switch self {
            case .aiCoachingLimit: return "paywall.ai.coaching.subtitle".local()
            case .tagsLimit: return "paywall.tags.limit.subtitle".local()
            case .analyticsAccess: return "paywall.analytics.subtitle".local()
            case .exportData: return "paywall.export.subtitle".local()
            case .socialSharing: return "paywall.social.subtitle".local()
            case .advancedWidgets: return "paywall.widgets.subtitle".local()
            case .onboarding: return "paywall.onboarding.subtitle".local()
            case .settingsUpgrade: return "paywall.settings.subtitle".local()
            }
        }
    }
}

// MARK: - Debug Helpers
extension StoreConfiguration {
    
    #if DEBUG
    @MainActor static func debugInfo() -> String {
        return """
        🏪 STORE CONFIGURATION DEBUG INFO
        ═══════════════════════════════════
        Store Enabled: \(isStoreEnabled)
        Product IDs: \(ProductIDs.allProductIDs.count)
        Premium Features: \(PremiumFeatures.allFeatures.count)
        Current Subscription: \(StoreManager.shared.isSubscribed ? "ACTIVE" : "INACTIVE")
        ═══════════════════════════════════
        """
    }
    #endif
}
