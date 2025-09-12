import Foundation

/// Global configuration for app versions
public enum KeyVersion: String, CaseIterable {
    case SIMPLE = "SIMPLE"
    case FULL = "FULL"
    
    var displayName: String {
        switch self {
        case .SIMPLE:
            return "Mirror Smoker"
        case .FULL:
            return "Mirror Smoker Pro"
        }
    }
    
    var hasAIFeatures: Bool {
        switch self {
        case .SIMPLE:
            return false
        case .FULL:
            return true
        }
    }
    
    var hasAdvancedAnalytics: Bool {
        switch self {
        case .SIMPLE:
            return false
        case .FULL:
            return true
        }
    }
    
    var hasCompleteStatistics: Bool {
        switch self {
        case .SIMPLE:
            return false
        case .FULL:
            return true
        }
    }
    
    var bundleIdentifierSuffix: String {
        switch self {
        case .SIMPLE:
            return ""
        case .FULL:
            return ".pro"
        }
    }
}

/// Global app configuration
public struct AppConfiguration {
    
    /// Current version of the app - CHANGE THIS TO SWITCH VERSIONS
    public static let KEYVERSION: KeyVersion = .SIMPLE
    
    /// Check if AI features are enabled
    public static var hasAIFeatures: Bool {
        return KEYVERSION.hasAIFeatures
    }
    
    /// Check if advanced analytics are enabled
    public static var hasAdvancedAnalytics: Bool {
        return KEYVERSION.hasAdvancedAnalytics
    }
    
    /// Check if complete statistics are enabled
    public static var hasCompleteStatistics: Bool {
        return KEYVERSION.hasCompleteStatistics
    }
    
    /// Get display name for current version
    public static var displayName: String {
        return KEYVERSION.displayName
    }
    
    /// Get bundle identifier suffix
    public static var bundleIdentifierSuffix: String {
        return KEYVERSION.bundleIdentifierSuffix
    }
}
