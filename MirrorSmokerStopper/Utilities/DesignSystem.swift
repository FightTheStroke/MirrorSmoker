//  DesignSystem.swift
//  MirrorSmokerStopper
//
//  Created by Assistant on 09/01/25.
//

import SwiftUI

// MARK: - Modern Design System
struct DS {
    // MARK: - Colors (Using AppColors)
    struct Colors {
        // Primary colors
        static let primary = AppColors.primary
        static let primaryLight = AppColors.primaryLight
        static let primaryDark = AppColors.primaryDark
        
        // Semantic colors
        static let success = AppColors.success
        static let warning = AppColors.warning
        static let danger = AppColors.danger
        static let info = AppColors.info
        
        // Background colors
        static let background = AppColors.background
        static let backgroundSecondary = AppColors.backgroundSecondary
        static let card = AppColors.card
        static let cardSecondary = AppColors.cardSecondary
        static let separator = AppColors.separator
        
        // Text colors
        static let textPrimary = AppColors.textPrimary
        static let textSecondary = AppColors.textSecondary
        static let textTertiary = AppColors.textTertiary
        static let textInverse = AppColors.textInverse
        
        // Health & Smoking specific colors
        static let cigarette = AppColors.cigarette
        static let smoke = AppColors.smoke
        static let health = AppColors.health
        static let progress = AppColors.progress
        
        // Chart colors
        static let chart1 = AppColors.chart1
        static let chart2 = AppColors.chart2
        static let chart3 = AppColors.chart3
        static let chart4 = AppColors.chart4
        static let chart5 = AppColors.chart5
        
        // Chart colors (consolidated naming)
        static let chartSecondary = AppColors.chart2
        static let chartTertiary = AppColors.chart3
        
        // Tag colors
        static let tagWork = AppColors.tagWork
        static let tagStress = AppColors.tagStress
        static let tagCoding = AppColors.tagCoding
        static let tagSocial = AppColors.tagSocial
        static let tagHealth = AppColors.tagHealth
        
        // Status colors
        static let statusGood = AppColors.statusGood
        static let statusWarning = AppColors.statusWarning
        static let statusCritical = AppColors.statusCritical
        static let statusNeutral = AppColors.statusNeutral
        
        // Interactive colors
        static let buttonPrimary = AppColors.buttonPrimary
        static let buttonSecondary = AppColors.buttonSecondary
        static let buttonDisabled = AppColors.buttonDisabled
        static let link = AppColors.link
        static let linkVisited = AppColors.linkVisited
        
        // DEPRECATED: Use specific semantic colors instead
        // static let secondary = AppColors.textSecondary // Use DS.Colors.textSecondary directly
        // static let accent = AppColors.primary // Use DS.Colors.primary directly
        
        // New intermediate warning color
        static let attention = Color.orange
    }
    
    // MARK: - Typography (JetBrains Mono NL + System Fonts)
    struct Text {
        // Custom font helper
        private static func jetBrainsMono(size: CGFloat, weight: Font.Weight = .regular) -> Font {
            Font.custom("JetBrains Mono NL", size: size).weight(weight)
        }
        
        // Large text
        static let largeTitle = Font.largeTitle.weight(.bold)
        static let display = jetBrainsMono(size: 34, weight: .heavy) // Custom font for display
        
        // Titles
        static let title = Font.title.weight(.semibold)
        static let title2 = Font.title2.weight(.semibold)
        static let title3 = Font.title3.weight(.semibold)
        
        // Headlines
        static let headline = Font.headline.weight(.medium)
        static let subheadline = Font.subheadline.weight(.medium)
        
        // Body text
        static let body = Font.body
        static let bodyBold = Font.body.weight(.semibold)
        static let bodyMono = jetBrainsMono(size: 17) // For code/monospace content
        static let callout = Font.callout
        
        // Captions
        static let caption = Font.caption
        static let caption2 = Font.caption2
        static let captionMono = jetBrainsMono(size: 12) // For small monospace content
        static let footnote = Font.footnote
        
        // Special
        static let small = Font.caption
        static let micro = Font.caption2
        static let code = jetBrainsMono(size: 14) // For inline code
    }
    
    // MARK: - Spacing (8pt Grid System)
    struct Space {
        static let xxs: CGFloat = 2
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 40
        static let xxxl: CGFloat = 48
        static let xxxxl: CGFloat = 64
    }
    
    // MARK: - Sizes
    struct Size {
        // Button sizes
        static let buttonHeight: CGFloat = 50
        static let buttonHeightSmall: CGFloat = 36
        static let buttonHeightLarge: CGFloat = 56
        
        // Corner radius
        static let cardRadius: CGFloat = 16
        static let cardRadiusSmall: CGFloat = 12
        static let buttonRadius: CGFloat = 12
        static let buttonRadiusSmall: CGFloat = 8
        static let tagRadius: CGFloat = 6
        
        // Icon sizes
        static let iconSize: CGFloat = 20
        static let iconSizeSmall: CGFloat = 16
        static let iconSizeLarge: CGFloat = 24
        static let iconSizeXLarge: CGFloat = 32
        
        // Special sizes
        static let fabSize: CGFloat = 56
        static let chartHeight: CGFloat = 200
        static let chartHeightSmall: CGFloat = 120
        static let progressRingSize: CGFloat = 60
    }
    
    // MARK: - Shadows
    struct Shadow {
        static let small = DSShadow(
            color: Color.black.opacity(0.05),
            radius: 2,
            x: 0,
            y: 1
        )
        static let medium = DSShadow(
            color: Color.black.opacity(0.1),
            radius: 8,
            x: 0,
            y: 4
        )
        static let large = DSShadow(
            color: Color.black.opacity(0.15),
            radius: 16,
            x: 0,
            y: 8
        )
    }
    
    // MARK: - Animations (Motion-Aware)
    struct Animation {
        // Basic animations that respect reduce motion
        static var fast: SwiftUI.Animation {
            UIAccessibility.isReduceMotionEnabled ? 
                .linear(duration: 0.1) : .easeInOut(duration: 0.2)
        }
        
        static var medium: SwiftUI.Animation {
            UIAccessibility.isReduceMotionEnabled ? 
                .linear(duration: 0.15) : .easeInOut(duration: 0.3)
        }
        
        static var slow: SwiftUI.Animation {
            UIAccessibility.isReduceMotionEnabled ? 
                .linear(duration: 0.2) : .easeInOut(duration: 0.5)
        }
        
        // Spring animations - reduced when motion is disabled
        static var spring: SwiftUI.Animation {
            UIAccessibility.isReduceMotionEnabled ? 
                .linear(duration: 0.2) : .spring(response: 0.5, dampingFraction: 0.8)
        }
        
        static var bouncy: SwiftUI.Animation {
            UIAccessibility.isReduceMotionEnabled ? 
                .linear(duration: 0.15) : .spring(response: 0.6, dampingFraction: 0.6)
        }
        
        // Decorative animations - disabled when reduce motion is on
        static var decorative: SwiftUI.Animation? {
            UIAccessibility.isReduceMotionEnabled ? nil : .spring(response: 0.4, dampingFraction: 0.7)
        }
    }
}

// MARK: - Shadow Helper
struct DSShadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
    
    // REMOVED: apply() method was misleading (returned EmptyView)
    // Use View.dsShadow(_:) extension instead
}

// MARK: - View Extensions
extension View {
    func dsShadow(_ shadow: DSShadow) -> some View {
        self.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
    
    func dsCard() -> some View {
        self
            .background(DS.Colors.card)
            .cornerRadius(DS.AdaptiveSize.cardRadius)
            .dsAdaptiveShadow(.small)
    }
    
    func dsTag() -> some View {
        self
            .padding(.horizontal, DS.AdaptiveSpace.sm)
            .padding(.vertical, DS.AdaptiveSpace.xs)
            .background(DS.Colors.tagWork)
            .foregroundColor(DS.Colors.textInverse)
            .cornerRadius(DS.AdaptiveSize.tagRadius)
            .font(DS.Text.caption)
    }
}
