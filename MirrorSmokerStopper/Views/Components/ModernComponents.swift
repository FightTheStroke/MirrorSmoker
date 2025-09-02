//
//  ModernComponents.swift
//  MirrorSmokerStopper
//
//  Created by Assistant on 09/01/25.
//

import SwiftUI

// MARK: - Modern Card Component
struct ModernCard<Content: View>: View {
    let content: Content
    let padding: CGFloat
    let backgroundColor: Color
    
    init(
        padding: CGFloat = DS.Space.lg,
        backgroundColor: Color = DS.Colors.card,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.backgroundColor = backgroundColor
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(backgroundColor)
            .cornerRadius(DS.AdaptiveSize.cardRadius)
            .dsAdaptiveShadow(.small)
    }
}

// MARK: - Section Header
struct ModernSectionHeader: View {
    let title: String
    let subtitle: String?
    let action: (() -> Void)?
    let actionTitle: String?
    
    init(
        _ title: String,
        subtitle: String? = nil,
        action: (() -> Void)? = nil,
        actionTitle: String? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.action = action
        self.actionTitle = actionTitle
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: DS.Space.xs) {
                Text(title)
                    .font(DS.Text.title3)
                    .foregroundStyle(DS.Colors.textPrimary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(DS.Text.caption)
                        .foregroundStyle(DS.Colors.textSecondary)
                }
            }
            
            Spacer()
            
            if let action = action, let actionTitle = actionTitle {
                Button(action: action) {
                    Text(actionTitle)
                        .font(DS.Text.caption)
                        .foregroundStyle(DS.Colors.link)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Modern Button
struct ModernButton: View {
    let title: String
    let icon: String?
    let style: ButtonStyle
    let size: ButtonSize
    let action: () -> Void
    
    enum ButtonStyle {
        case primary, secondary, danger, ghost
        
        var backgroundColor: Color {
            switch self {
            case .primary: return DS.Colors.buttonPrimary
            case .secondary: return DS.Colors.buttonSecondary
            case .danger: return DS.Colors.buttonPrimary
            case .ghost: return Color.clear
            }
        }
        
        var textColor: Color {
            switch self {
            case .primary, .danger: return DS.Colors.textInverse
            case .secondary, .ghost: return DS.Colors.textPrimary
            }
        }
        
        var borderColor: Color {
            switch self {
            case .ghost: return DS.Colors.separator
            default: return Color.clear
            }
        }
    }
    
    enum ButtonSize {
        case small, medium, large
        
        var height: CGFloat {
            switch self {
            case .small: return DS.Size.buttonHeightSmall
            case .medium: return DS.Size.buttonHeight
            case .large: return DS.Size.buttonHeightLarge
            }
        }
        
        var fontSize: Font {
            switch self {
            case .small: return DS.Text.caption
            case .medium: return DS.Text.headline
            case .large: return DS.Text.title3
            }
        }
    }
    
    init(
        _ title: String,
        icon: String? = nil,
        style: ButtonStyle = .primary,
        size: ButtonSize = .medium,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.size = size
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
                    .font(size.fontSize)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .frame(height: size.height)
            .foregroundStyle(style.textColor)
            .background(style.backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: DS.Size.buttonRadius)
                    .stroke(style.borderColor, lineWidth: 1)
            )
            .cornerRadius(DS.Size.buttonRadius)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Modern Tag
struct ModernTag: View {
    let text: String
    let color: Color
    let size: TagSize
    
    enum TagSize {
        case small, medium, large
        
        var padding: EdgeInsets {
            switch self {
            case .small:
                return EdgeInsets(top: DS.Space.xs, leading: DS.Space.sm, bottom: DS.Space.xs, trailing: DS.Space.sm)
            case .medium:
                return EdgeInsets(top: DS.Space.sm, leading: DS.Space.md, bottom: DS.Space.sm, trailing: DS.Space.md)
            case .large:
                return EdgeInsets(top: DS.Space.md, leading: DS.Space.lg, bottom: DS.Space.md, trailing: DS.Space.lg)
            }
        }
        
        var fontSize: Font {
            switch self {
            case .small: return DS.Text.caption2
            case .medium: return DS.Text.caption
            case .large: return DS.Text.footnote
            }
        }
    }
    
    init(
        _ text: String,
        color: Color = DS.Colors.tagWork,
        size: TagSize = .medium
    ) {
        self.text = text
        self.color = color
        self.size = size
    }
    
    var body: some View {
        Text(text)
            .font(size.fontSize)
            .fontWeight(.medium)
            .padding(size.padding)
            .background(color)
            .foregroundColor(DS.Colors.textInverse)
            .cornerRadius(DS.Size.tagRadius)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
    }
}

// MARK: - Modern Stat Card
struct ModernStatCard: View {
    let title: String
    let value: String
    let subtitle: String?
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
    
    init(
        title: String,
        value: String,
        subtitle: String? = nil,
        icon: String,
        color: Color,
        trend: TrendDirection? = nil
    ) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.icon = icon
        self.color = color
        self.trend = trend
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
                            .foregroundStyle(trend.color)
                    }
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
                
                if let subtitle = subtitle, trend == nil {
                    Text(subtitle)
                        .font(DS.Text.caption2)
                        .foregroundStyle(DS.Colors.textSecondary)
                }
            }
        }
        .padding(DS.Space.lg)
        .background(DS.Colors.card)
        .clipShape(RoundedRectangle(cornerRadius: DS.Size.cardRadius))
        .dsAdaptiveShadow(.small)
    }
}

// MARK: - Modern Progress Ring
struct ModernProgressRing: View {
    let progress: Double
    let size: CGFloat
    let lineWidth: CGFloat
    let color: Color
    let showPercentage: Bool
    
    init(
        progress: Double,
        size: CGFloat = DS.Size.progressRingSize,
        lineWidth: CGFloat = 6,
        color: Color = DS.Colors.primary,
        showPercentage: Bool = false
    ) {
        self.progress = max(0, min(1, progress))
        self.size = size
        self.lineWidth = lineWidth
        self.color = color
        self.showPercentage = showPercentage
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
            
            if showPercentage {
                Text("\(Int(progress * 100))%")
                    .font(DS.Text.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(DS.Colors.textPrimary)
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Modern Floating Action Button
struct ModernFloatingActionButton: View {
    let icon: String
    let action: () -> Void
    
    init(icon: String = "plus", action: @escaping () -> Void) {
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(DS.Colors.textInverse)
                .frame(width: DS.Size.fabSize, height: DS.Size.fabSize)
                .background(DS.Colors.buttonPrimary)
                .clipShape(Circle())
                .dsAdaptiveShadow(.medium)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Modern List Row
struct ModernListRow: View {
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
