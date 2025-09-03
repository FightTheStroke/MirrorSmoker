//
//  AIConfiguration.swift
//  MirrorSmokerStopper
//
//  Created by Claude on 02/09/25.
//

import Foundation
import SwiftUI
import os.log

/// Configuration manager for AI features
@MainActor
final class AIConfiguration: ObservableObject, Sendable {
    static let shared = AIConfiguration()
    
    private let logger = Logger(subsystem: "com.fightthestroke.MirrorSmokerStopper", category: "AIConfiguration")
    private let userDefaults = UserDefaults.standard
    
    // MARK: - Published Configuration Properties
    
    @Published var isAICoachingEnabled: Bool {
        didSet {
            userDefaults.set(self.isAICoachingEnabled, forKey: "ai_coaching_enabled")
            logger.info("AI coaching enabled: \(self.isAICoachingEnabled)")
        }
    }
    
    @Published var aiCoachingFrequency: CoachingFrequency {
        didSet {
            userDefaults.set(self.aiCoachingFrequency.rawValue, forKey: "ai_coaching_frequency")
            logger.info("AI coaching frequency: \(self.aiCoachingFrequency.rawValue)")
        }
    }
    
    @Published var enableBehavioralAnalysis: Bool {
        didSet {
            userDefaults.set(self.enableBehavioralAnalysis, forKey: "behavioral_analysis_enabled")
        }
    }
    
    @Published var enableQuitPlanOptimization: Bool {
        didSet {
            userDefaults.set(self.enableQuitPlanOptimization, forKey: "quit_plan_optimization_enabled")
        }
    }
    
    @Published var enableHealthKitIntegration: Bool {
        didSet {
            userDefaults.set(self.enableHealthKitIntegration, forKey: "healthkit_integration_enabled")
            if self.enableHealthKitIntegration {
                Task {
                    await self.requestHealthKitAccess()
                }
            }
        }
    }
    
    @Published var privacyLevel: PrivacyLevel {
        didSet {
            userDefaults.set(self.privacyLevel.rawValue, forKey: "privacy_level")
        }
    }
    
    @Published var quietHoursEnabled: Bool {
        didSet {
            userDefaults.set(self.quietHoursEnabled, forKey: "quiet_hours_enabled")
        }
    }
    
    @Published var quietHoursStart: Int {
        didSet {
            userDefaults.set(self.quietHoursStart, forKey: "quiet_hours_start")
            self.updateJITAIQuietHours()
        }
    }
    
    @Published var quietHoursEnd: Int {
        didSet {
            userDefaults.set(self.quietHoursEnd, forKey: "quiet_hours_end")
            self.updateJITAIQuietHours()
        }
    }
    
    @Published var maxDailyNotifications: Int {
        didSet {
            userDefaults.set(self.maxDailyNotifications, forKey: "max_daily_notifications")
            JITAIPlanner.shared.updateConfiguration(
                enabled: self.isAICoachingEnabled,
                maxNotificationsPerDay: self.maxDailyNotifications,
                quietHours: self.quietHoursRange
            )
        }
    }
    
    // MARK: - Configuration Enums
    
    enum CoachingFrequency: String, CaseIterable, Codable {
        case minimal = "minimal"
        case balanced = "balanced"
        case proactive = "proactive"
        
        var displayName: String {
            switch self {
            case .minimal:
                return NSLocalizedString("ai.config.frequency.minimal", comment: "Minimal")
            case .balanced:
                return NSLocalizedString("ai.config.frequency.balanced", comment: "Balanced")
            case .proactive:
                return NSLocalizedString("ai.config.frequency.proactive", comment: "Proactive")
            }
        }
        
        var description: String {
            switch self {
            case .minimal:
                return NSLocalizedString("ai.config.frequency.minimal.desc", comment: "Only high-risk situations")
            case .balanced:
                return NSLocalizedString("ai.config.frequency.balanced.desc", comment: "Regular coaching with smart timing")
            case .proactive:
                return NSLocalizedString("ai.config.frequency.proactive.desc", comment: "Frequent support and insights")
            }
        }
        
        var maxDailyNotifications: Int {
            switch self {
            case .minimal: return 1
            case .balanced: return 3
            case .proactive: return 5
            }
        }
        
        var riskThreshold: Double {
            switch self {
            case .minimal: return 0.8
            case .balanced: return 0.6
            case .proactive: return 0.4
            }
        }
    }
    
    enum PrivacyLevel: String, CaseIterable, Codable {
        case minimal = "minimal"
        case standard = "standard"
        case enhanced = "enhanced"
        
        var displayName: String {
            switch self {
            case .minimal:
                return NSLocalizedString("ai.config.privacy.minimal", comment: "Minimal")
            case .standard:
                return NSLocalizedString("ai.config.privacy.standard", comment: "Standard")
            case .enhanced:
                return NSLocalizedString("ai.config.privacy.enhanced", comment: "Enhanced")
            }
        }
        
        var description: String {
            switch self {
            case .minimal:
                return NSLocalizedString("ai.config.privacy.minimal.desc", comment: "Basic smoking data only")
            case .standard:
                return NSLocalizedString("ai.config.privacy.standard.desc", comment: "Smoking data + basic patterns")
            case .enhanced:
                return NSLocalizedString("ai.config.privacy.enhanced.desc", comment: "Full behavioral analysis with HealthKit")
            }
        }
        
        var allowsHealthKitIntegration: Bool {
            return self == .enhanced
        }
        
        var allowsLocationAnalysis: Bool {
            return self != .minimal
        }
        
        var allowsDetailedBehavioralAnalysis: Bool {
            return self == .enhanced
        }
    }
    
    // MARK: - Computed Properties
    
    var isAIAvailable: Bool {
        if #available(iOS 26, *) {
            return true
        } else {
            return false // AI features require iOS 26
        }
    }
    
    var quietHoursRange: ClosedRange<Int> {
        if quietHoursStart <= quietHoursEnd {
            return quietHoursStart...quietHoursEnd
        } else {
            // Spans midnight
            return quietHoursStart...23
        }
    }
    
    var effectiveMaxNotifications: Int {
        min(maxDailyNotifications, aiCoachingFrequency.maxDailyNotifications)
    }
    
    var riskThreshold: Double {
        aiCoachingFrequency.riskThreshold
    }
    
    // MARK: - Initialization
    
    private init() {
        // Load saved configuration
        self.isAICoachingEnabled = userDefaults.bool(forKey: "ai_coaching_enabled")
        
        if let frequencyRaw = userDefaults.object(forKey: "ai_coaching_frequency") as? String,
           let frequency = CoachingFrequency(rawValue: frequencyRaw) {
            self.aiCoachingFrequency = frequency
        } else {
            self.aiCoachingFrequency = .balanced
        }
        
        self.enableBehavioralAnalysis = userDefaults.object(forKey: "behavioral_analysis_enabled") as? Bool ?? true
        self.enableQuitPlanOptimization = userDefaults.object(forKey: "quit_plan_optimization_enabled") as? Bool ?? true
        self.enableHealthKitIntegration = userDefaults.object(forKey: "healthkit_integration_enabled") as? Bool ?? false
        
        if let privacyRaw = userDefaults.object(forKey: "privacy_level") as? String,
           let privacy = PrivacyLevel(rawValue: privacyRaw) {
            self.privacyLevel = privacy
        } else {
            self.privacyLevel = .standard
        }
        
        self.quietHoursEnabled = userDefaults.object(forKey: "quiet_hours_enabled") as? Bool ?? true
        self.quietHoursStart = userDefaults.object(forKey: "quiet_hours_start") as? Int ?? 22
        self.quietHoursEnd = userDefaults.object(forKey: "quiet_hours_end") as? Int ?? 7
        self.maxDailyNotifications = userDefaults.object(forKey: "max_daily_notifications") as? Int ?? 3
        
        // Set default AI coaching enabled state based on iOS version
        if !userDefaults.bool(forKey: "ai_config_initialized") {
            self.isAICoachingEnabled = isAIAvailable
            userDefaults.set(true, forKey: "ai_config_initialized")
        }
        
        // Apply initial configuration to JITAI system
        updateJITAIConfiguration()
    }
    
    // MARK: - Configuration Methods
    
    func resetToDefaults() {
        logger.info("Resetting AI configuration to defaults")
        
        isAICoachingEnabled = isAIAvailable
        aiCoachingFrequency = .balanced
        enableBehavioralAnalysis = true
        enableQuitPlanOptimization = true
        enableHealthKitIntegration = false
        privacyLevel = .standard
        quietHoursEnabled = true
        quietHoursStart = 22
        quietHoursEnd = 7
        maxDailyNotifications = 3
    }
    
    func validateConfiguration() -> [String] {
        var issues: [String] = []
        
        if !isAIAvailable && isAICoachingEnabled {
            issues.append(NSLocalizedString("ai.config.validation.ios26", comment: "AI coaching requires iOS 26"))
        }
        
        if enableHealthKitIntegration && !privacyLevel.allowsHealthKitIntegration {
            issues.append(NSLocalizedString("ai.config.validation.healthkit.privacy", comment: "HealthKit requires enhanced privacy level"))
        }
        
        if quietHoursStart == quietHoursEnd && quietHoursEnabled {
            issues.append(NSLocalizedString("ai.config.validation.quiet.hours", comment: "Quiet hours start and end cannot be the same"))
        }
        
        if maxDailyNotifications < 1 || maxDailyNotifications > 10 {
            issues.append(NSLocalizedString("ai.config.validation.notifications", comment: "Daily notifications must be between 1 and 10"))
        }
        
        return issues
    }
    
    func exportConfiguration() -> [String: Any] {
        return [
            "ai_coaching_enabled": isAICoachingEnabled,
            "coaching_frequency": aiCoachingFrequency.rawValue,
            "behavioral_analysis_enabled": enableBehavioralAnalysis,
            "quit_plan_optimization_enabled": enableQuitPlanOptimization,
            "healthkit_integration_enabled": enableHealthKitIntegration,
            "privacy_level": privacyLevel.rawValue,
            "quiet_hours_enabled": quietHoursEnabled,
            "quiet_hours_start": quietHoursStart,
            "quiet_hours_end": quietHoursEnd,
            "max_daily_notifications": maxDailyNotifications,
            "exported_at": Date().timeIntervalSince1970
        ]
    }
    
    func importConfiguration(from data: [String: Any]) -> Bool {
        logger.info("Importing AI configuration")
        
        guard let exportedAt = data["exported_at"] as? TimeInterval,
              Date(timeIntervalSince1970: exportedAt).timeIntervalSinceNow > -30 * 24 * 3600 else {
            logger.warning("Configuration data is too old or invalid")
            return false
        }
        
        if let enabled = data["ai_coaching_enabled"] as? Bool {
            isAICoachingEnabled = enabled
        }
        
        if let frequencyRaw = data["coaching_frequency"] as? String,
           let frequency = CoachingFrequency(rawValue: frequencyRaw) {
            aiCoachingFrequency = frequency
        }
        
        if let behavioralEnabled = data["behavioral_analysis_enabled"] as? Bool {
            enableBehavioralAnalysis = behavioralEnabled
        }
        
        if let planOptEnabled = data["quit_plan_optimization_enabled"] as? Bool {
            enableQuitPlanOptimization = planOptEnabled
        }
        
        if let healthkitEnabled = data["healthkit_integration_enabled"] as? Bool {
            enableHealthKitIntegration = healthkitEnabled
        }
        
        if let privacyRaw = data["privacy_level"] as? String,
           let privacy = PrivacyLevel(rawValue: privacyRaw) {
            privacyLevel = privacy
        }
        
        if let quietEnabled = data["quiet_hours_enabled"] as? Bool {
            quietHoursEnabled = quietEnabled
        }
        
        if let quietStart = data["quiet_hours_start"] as? Int {
            quietHoursStart = quietStart
        }
        
        if let quietEnd = data["quiet_hours_end"] as? Int {
            quietHoursEnd = quietEnd
        }
        
        if let maxNotifications = data["max_daily_notifications"] as? Int {
            maxDailyNotifications = maxNotifications
        }
        
        return true
    }
    
    // MARK: - Integration Methods
    
    private func updateJITAIConfiguration() {
        let jitaiPlanner = JITAIPlanner.shared
        jitaiPlanner.updateConfiguration(
            enabled: isAICoachingEnabled && isAIAvailable,
            maxNotificationsPerDay: effectiveMaxNotifications,
            quietHours: quietHoursEnabled ? quietHoursRange : 25...25 // Invalid range = no quiet hours
        )
    }
    
    private func updateJITAIQuietHours() {
        if quietHoursEnabled {
            let jitaiPlanner = JITAIPlanner.shared
            jitaiPlanner.updateConfiguration(
                enabled: isAICoachingEnabled && isAIAvailable,
                maxNotificationsPerDay: effectiveMaxNotifications,
                quietHours: quietHoursRange
            )
        }
    }
    
    private func requestHealthKitAccess() async {
        guard enableHealthKitIntegration else { return }
        
        do {
            try await HealthKitManager.shared.requestAuthorization()
            logger.info("HealthKit access granted")
        } catch {
            logger.error("HealthKit access denied: \(error.localizedDescription)")
            
            await MainActor.run {
                enableHealthKitIntegration = false
            }
        }
    }
    
    // MARK: - Feature Flags
    
    func isFeatureEnabled(_ feature: AIFeature) -> Bool {
        switch feature {
        case .coaching:
            return isAICoachingEnabled && isAIAvailable
        case .behavioralAnalysis:
            return enableBehavioralAnalysis && privacyLevel.allowsDetailedBehavioralAnalysis
        case .quitPlanOptimization:
            return enableQuitPlanOptimization
        case .healthKitIntegration:
            return enableHealthKitIntegration && privacyLevel.allowsHealthKitIntegration
        case .locationAnalysis:
            return privacyLevel.allowsLocationAnalysis
        case .advancedInsights:
            return privacyLevel == .enhanced && isAIAvailable
        }
    }
    
    enum AIFeature {
        case coaching
        case behavioralAnalysis
        case quitPlanOptimization
        case healthKitIntegration
        case locationAnalysis
        case advancedInsights
    }
    
    // MARK: - Analytics and Diagnostics
    
    func generateConfigurationReport() -> String {
        let issues = validateConfiguration()
        let featuresEnabled = AIFeature.allCases.filter { isFeatureEnabled($0) }
        
        var report = """
        AI Configuration Report
        ======================
        
        System Information:
        - iOS Version Available for AI: \(isAIAvailable)
        - Current Privacy Level: \(privacyLevel.displayName)
        - Coaching Frequency: \(aiCoachingFrequency.displayName)
        
        Enabled Features:
        """
        
        for feature in featuresEnabled {
            report += "\n- \(feature)"
        }
        
        if !issues.isEmpty {
            report += "\n\nConfiguration Issues:"
            for issue in issues {
                report += "\n- \(issue)"
            }
        }
        
        report += "\n\nNotification Settings:"
        report += "\n- Max Daily: \(effectiveMaxNotifications)"
        report += "\n- Quiet Hours: \(quietHoursEnabled ? "\(quietHoursStart):00 - \(quietHoursEnd):00" : "Disabled")"
        
        return report
    }
}

// MARK: - Extensions

extension AIConfiguration.AIFeature: CaseIterable {}

extension AIConfiguration.CoachingFrequency {
    var icon: String {
        switch self {
        case .minimal: return "moon.zzz"
        case .balanced: return "scale.3d"
        case .proactive: return "bolt.fill"
        }
    }
}

extension AIConfiguration.PrivacyLevel {
    var icon: String {
        switch self {
        case .minimal: return "lock"
        case .standard: return "lock.shield"
        case .enhanced: return "lock.shield.fill"
        }
    }
}