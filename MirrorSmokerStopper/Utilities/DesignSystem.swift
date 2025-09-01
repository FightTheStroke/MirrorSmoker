//
//  DesignSystem.swift
//  MirrorSmokerStopper
//
//  Created by Assistant on 09/01/25.
//

import SwiftUI

// MARK: - Design System
struct DS {
    // MARK: - Colors
    struct Colors {
        // Modern primary colors
        static let primary = Color(red: 0.0, green: 0.48, blue: 1.0) // Modern iOS blue
        static let secondary = Color(red: 0.55, green: 0.55, blue: 0.58) // Modern gray
        static let accent = Color(red: 0.32, green: 0.78, blue: 0.98) // Light blue accent
        
        // Semantic colors
        static let success = Color(red: 0.20, green: 0.78, blue: 0.35) // iOS green
        static let warning = Color(red: 1.0, green: 0.58, blue: 0.0) // iOS orange  
        static let danger = Color(red: 1.0, green: 0.23, blue: 0.19) // iOS red
        static let info = Color(red: 0.35, green: 0.34, blue: 0.84) // iOS purple
        
        // Background colors
        static let background = Color(.systemGroupedBackground)
        static let backgroundSecondary = Color(.secondarySystemGroupedBackground)
        static let card = Color(.systemBackground)
        static let cardSecondary = Color(.secondarySystemBackground)
        
        // Text colors
        static let textPrimary = Color.primary
        static let textSecondary = Color.secondary
        static let textTertiary = Color(.tertiaryLabel)
        
        // Health & Smoking specific colors
        static let cigarette = Color(red: 0.85, green: 0.25, blue: 0.25)
        static let smoke = Color.gray.opacity(0.6)
        static let health = Color(red: 0.0, green: 0.78, blue: 0.55) // Mint green
        static let progress = Color(red: 0.0, green: 0.7, blue: 0.4) // Progress green
        
        // Chart colors
        static let chartPrimary = Color(red: 0.0, green: 0.48, blue: 1.0)
        static let chartSecondary = Color(red: 0.32, green: 0.78, blue: 0.98)
        static let chartTertiary = Color(red: 0.88, green: 0.38, blue: 0.98)
        static let chartQuaternary = Color(red: 1.0, green: 0.58, blue: 0.0)
    }
    
    // MARK: - Typography
    struct Text {
        static let largeTitle = Font.largeTitle.weight(.bold)
        static let title = Font.title.weight(.semibold)
        static let title2 = Font.title2.weight(.semibold)
        static let title3 = Font.title3.weight(.medium)
        static let headline = Font.headline.weight(.medium)
        static let subheadline = Font.subheadline.weight(.medium)
        static let body = Font.body
        static let bodyBold = Font.body.weight(.semibold)
        static let callout = Font.callout
        static let caption = Font.caption
        static let caption2 = Font.caption2
        static let footnote = Font.footnote
    }
    
    // MARK: - Spacing
    struct Space {
        static let xxs: CGFloat = 2
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 40
        static let xxxl: CGFloat = 48
    }
    
    // MARK: - Sizes
    struct Size {
        static let buttonHeight: CGFloat = 50
        static let buttonHeightSmall: CGFloat = 36
        static let cardRadius: CGFloat = 16
        static let cardRadiusSmall: CGFloat = 12
        static let buttonRadius: CGFloat = 12
        static let buttonRadiusSmall: CGFloat = 8
        static let iconSize: CGFloat = 20
        static let iconSizeSmall: CGFloat = 16
        static let iconSizeLarge: CGFloat = 24
        static let fabSize: CGFloat = 56
        static let chartHeight: CGFloat = 200
        static let chartHeightSmall: CGFloat = 120
    }
    
    // MARK: - Animations
    struct Animation {
        static let fast = SwiftUI.Animation.easeInOut(duration: 0.2)
        static let medium = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let slow = SwiftUI.Animation.easeInOut(duration: 0.5)
        static let spring = SwiftUI.Animation.spring(response: 0.5, dampingFraction: 0.8)
    }
}

// MARK: - Reusable Card Component
struct DSCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(DS.Space.lg)
            .background(DS.Colors.card)
            .cornerRadius(DS.Size.cardRadius)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Section Header
struct DSSectionHeader: View {
    let title: String
    let subtitle: String?
    
    init(_ title: String, subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Space.xs) {
            Text(title)
                .font(DS.Text.headline)
                .foregroundStyle(DS.Colors.textPrimary)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(DS.Text.caption)
                    .foregroundStyle(DS.Colors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Stat Card
struct DSStatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Space.md) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: DS.Space.xs) {
                Text(title)
                    .font(DS.Text.caption)
                    .foregroundStyle(DS.Colors.textSecondary)
                
                Text(value)
                    .font(DS.Text.largeTitle)
                    .foregroundStyle(color)
                    .minimumScaleFactor(0.8)
                
                Text(subtitle)
                    .font(DS.Text.caption)
                    .foregroundStyle(DS.Colors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DS.Space.lg)
        .background(DS.Colors.card)
        .cornerRadius(DS.Size.cardRadius)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Primary Button
struct DSButton: View {
    let title: String
    let icon: String?
    let style: ButtonStyle
    let action: () -> Void
    
    enum ButtonStyle {
        case primary, secondary, danger
        
        var backgroundColor: Color {
            switch self {
            case .primary: return DS.Colors.primary
            case .secondary: return DS.Colors.secondary.opacity(0.1)
            case .danger: return DS.Colors.danger
            }
        }
        
        var textColor: Color {
            switch self {
            case .primary, .danger: return .white
            case .secondary: return DS.Colors.textPrimary
            }
        }
    }
    
    init(_ title: String, icon: String? = nil, style: ButtonStyle = .primary, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.style = style
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DS.Space.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: DS.Size.iconSize, weight: .medium))
                }
                
                Text(title)
                    .font(DS.Text.headline)
            }
            .frame(maxWidth: .infinity)
            .frame(height: DS.Size.buttonHeight)
            .foregroundStyle(style.textColor)
            .background(style.backgroundColor)
            .cornerRadius(DS.Size.buttonRadius)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Floating Action Button (Fixed Position)
struct DSFloatingActionButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(width: DS.Size.fabSize, height: DS.Size.fabSize)
                .background(DS.Colors.primary)
                .clipShape(Circle())
                .shadow(color: DS.Colors.primary.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Enhanced Health Card
struct DSHealthCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    let trend: TrendDirection?
    
    enum TrendDirection {
        case up, down, stable
        
        var icon: String {
            switch self {
            case .up: return "arrow.up"
            case .down: return "arrow.down"
            case .stable: return "minus"
            }
        }
        
        var color: Color {
            switch self {
            case .up: return DS.Colors.danger
            case .down: return DS.Colors.success
            case .stable: return DS.Colors.warning
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Space.md) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                    .frame(width: 28, height: 28)
                    .background(color.opacity(0.1))
                    .clipShape(Circle())
                
                Spacer()
                
                if let trend = trend {
                    HStack(spacing: DS.Space.xs) {
                        Image(systemName: trend.icon)
                            .font(.caption)
                        Text(subtitle)
                            .font(DS.Text.caption)
                    }
                    .foregroundStyle(trend.color)
                    .padding(.horizontal, DS.Space.sm)
                    .padding(.vertical, DS.Space.xs)
                    .background(trend.color.opacity(0.1))
                    .clipShape(Capsule())
                }
            }
            
            VStack(alignment: .leading, spacing: DS.Space.xs) {
                Text(title)
                    .font(DS.Text.caption)
                    .foregroundStyle(DS.Colors.textSecondary)
                
                Text(value)
                    .font(DS.Text.title2)
                    .foregroundStyle(color)
                    .fontWeight(.bold)
                    .minimumScaleFactor(0.8)
                
                if trend == nil {
                    Text(subtitle)
                        .font(DS.Text.caption2)
                        .foregroundStyle(DS.Colors.textSecondary)
                }
            }
        }
        .padding(DS.Space.lg)
        .background(DS.Colors.card)
        .clipShape(RoundedRectangle(cornerRadius: DS.Size.cardRadius))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Modern List Row
struct DSListRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String?
    let value: String?
    let accessory: AnyView?
    let action: (() -> Void)?
    
    init(
        icon: String,
        iconColor: Color = DS.Colors.primary,
        title: String,
        subtitle: String? = nil,
        value: String? = nil,
        accessory: AnyView? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.subtitle = subtitle
        self.value = value
        self.accessory = accessory
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            action?()
        }) {
            HStack(spacing: DS.Space.md) {
                Image(systemName: icon)
                    .font(.system(size: DS.Size.iconSize))
                    .foregroundStyle(iconColor)
                    .frame(width: 28, alignment: .center)
                
                VStack(alignment: .leading, spacing: DS.Space.xs) {
                    Text(title)
                        .font(DS.Text.body)
                        .foregroundStyle(DS.Colors.textPrimary)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(DS.Text.caption)
                            .foregroundStyle(DS.Colors.textSecondary)
                    }
                }
                
                Spacer()
                
                if let value = value {
                    Text(value)
                        .font(DS.Text.bodyBold)
                        .foregroundStyle(iconColor)
                }
                
                if let accessory = accessory {
                    accessory
                }
                
                if action != nil {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(DS.Colors.textTertiary)
                }
            }
            .padding(.vertical, DS.Space.md)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(action == nil)
    }
}

// MARK: - Progress Ring
struct DSProgressRing: View {
    let progress: Double
    let size: CGFloat
    let lineWidth: CGFloat
    let color: Color
    
    init(progress: Double, size: CGFloat = 60, lineWidth: CGFloat = 6, color: Color = DS.Colors.primary) {
        self.progress = max(0, min(1, progress))
        self.size = size
        self.lineWidth = lineWidth
        self.color = color
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: lineWidth)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    color,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(DS.Animation.medium, value: progress)
        }
        .frame(width: size, height: size)
    }
}
