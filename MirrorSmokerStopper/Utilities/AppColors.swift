//
//  AppColors.swift
//  Mirror Smoker
//
//  Created by Roberto D'Angelo on 27/08/24.
//

import SwiftUI
import UIKit

enum AppColors {
    // MARK: - Primary Brand Colors
    static let primary = Color(red: 0.0, green: 0.48, blue: 1.0) // Modern iOS blue
    static let primaryLight = Color(red: 0.32, green: 0.78, blue: 0.98) // Light blue accent
    static let primaryDark = Color(red: 0.0, green: 0.35, blue: 0.8) // Darker blue
    
    // MARK: - Semantic Colors
    static let success = Color(red: 0.20, green: 0.78, blue: 0.35) // iOS green
    static let warning = Color(red: 1.0, green: 0.58, blue: 0.0) // iOS orange
    static let danger = Color(red: 0.95, green: 0.23, blue: 0.19) // Softer red
    static let info = Color(red: 0.35, green: 0.34, blue: 0.84) // iOS purple
    
    // MARK: - Neutral Colors
    static let background = Color(.systemGroupedBackground)
    static let backgroundSecondary = Color(.secondarySystemGroupedBackground)
    static let card = Color(.systemBackground)
    static let cardSecondary = Color(.secondarySystemBackground)
    static let separator = Color(.separator)
    
    // MARK: - Text Colors
    static let textPrimary = Color.primary
    static let textSecondary = Color.secondary
    static let textTertiary = Color(.tertiaryLabel)
    static let textInverse = Color.white
    
    // MARK: - Health & Smoking Specific Colors
    static let cigarette = Color(red: 0.85, green: 0.25, blue: 0.25) // Muted red
    static let smoke = Color(red: 0.6, green: 0.6, blue: 0.65) // Neutral smoke
    static let health = Color(red: 0.0, green: 0.78, blue: 0.55) // Mint green
    static let progress = Color(red: 0.0, green: 0.7, blue: 0.4) // Progress green
    
    // MARK: - Chart Colors (Harmonious Palette)
    static let chart1 = Color(red: 0.0, green: 0.48, blue: 1.0) // Blue
    static let chart2 = Color(red: 0.32, green: 0.78, blue: 0.98) // Light blue
    static let chart3 = Color(red: 0.88, green: 0.38, blue: 0.98) // Purple
    static let chart4 = Color(red: 1.0, green: 0.58, blue: 0.0) // Orange
    static let chart5 = Color(red: 0.20, green: 0.78, blue: 0.35) // Green
    
    // MARK: - Tag Colors (Carefully Selected)
    static let tagWork = Color(red: 0.85, green: 0.25, blue: 0.25) // Muted red
    static let tagStress = Color(red: 0.6, green: 0.4, blue: 0.8) // Muted purple
    static let tagCoding = Color(red: 0.4, green: 0.6, blue: 0.8) // Muted blue
    static let tagSocial = Color(red: 0.8, green: 0.6, blue: 0.4) // Muted orange
    static let tagHealth = Color(red: 0.4, green: 0.8, blue: 0.6) // Muted green
    
    // MARK: - Status Colors
    static let statusGood = success
    static let statusWarning = warning
    static let statusCritical = danger
    static let statusNeutral = Color(.systemGray3)
    
    // MARK: - Interactive Colors
    static let buttonPrimary = primary
    static let buttonSecondary = Color(.systemGray5)
    static let buttonDisabled = Color(.systemGray4)
    static let link = primary
    static let linkVisited = primaryDark
}