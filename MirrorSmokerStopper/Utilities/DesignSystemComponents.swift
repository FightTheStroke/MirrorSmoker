//
//  DesignSystemComponents.swift
//  MirrorSmokerStopper
//
//  Created by Assistant on 01/09/25.
//

import SwiftUI

// MARK: - Modern Button Styles (Motion-Aware)

struct DSPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding(.vertical, DS.Space.md)
            .padding(.horizontal, DS.Space.lg)
            .background(
                DS.Colors.buttonPrimary
                    .opacity(configuration.isPressed ? 0.8 : 1.0)
            )
            .foregroundColor(DS.Colors.textInverse)
            .cornerRadius(DS.Size.buttonRadius)
            .scaleEffect(shouldAnimate ? (configuration.isPressed ? 0.98 : 1.0) : 1.0)
            .animation(DS.Animation.fast, value: configuration.isPressed)
    }
    
    private var shouldAnimate: Bool {
        !UIAccessibility.isReduceMotionEnabled
    }
}

struct DSSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding(.vertical, DS.Space.md)
            .padding(.horizontal, DS.Space.lg)
            .background(
                DS.Colors.buttonSecondary
                    .opacity(configuration.isPressed ? 0.8 : 1.0)
            )
            .foregroundColor(DS.Colors.textPrimary)
            .cornerRadius(DS.Size.buttonRadius)
            .overlay(
                RoundedRectangle(cornerRadius: DS.Size.buttonRadius)
                    .stroke(DS.Colors.separator, lineWidth: 1)
            )
            .scaleEffect(shouldAnimate ? (configuration.isPressed ? 0.98 : 1.0) : 1.0)
            .animation(DS.Animation.fast, value: configuration.isPressed)
    }
    
    private var shouldAnimate: Bool {
        !UIAccessibility.isReduceMotionEnabled
    }
}

struct DSDestructiveButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding(.vertical, DS.Space.md)
            .padding(.horizontal, DS.Space.lg)
            .background(
                DS.Colors.danger
                    .opacity(configuration.isPressed ? 0.8 : 1.0)
            )
            .foregroundColor(DS.Colors.textInverse)
            .cornerRadius(DS.Size.buttonRadius)
            .scaleEffect(shouldAnimate ? (configuration.isPressed ? 0.98 : 1.0) : 1.0)
            .animation(DS.Animation.fast, value: configuration.isPressed)
    }
    
    private var shouldAnimate: Bool {
        !UIAccessibility.isReduceMotionEnabled
    }
}

struct DSFABStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: DS.Size.fabSize, height: DS.Size.fabSize)
            .background(
                DS.Colors.primary
                    .opacity(configuration.isPressed ? 0.8 : 1.0)
            )
            .foregroundColor(DS.Colors.textInverse)
            .clipShape(Circle())
            .scaleEffect(shouldAnimate ? (configuration.isPressed ? 0.95 : 1.0) : 1.0)
            .dsAdaptiveShadow(.medium)
            .animation(DS.Animation.bouncy, value: configuration.isPressed)
    }
    
    private var shouldAnimate: Bool {
        !UIAccessibility.isReduceMotionEnabled
    }
}

// MARK: - DSButton

struct DSButton: View {
    enum Style {
        case primary
        case secondary
        case destructive
    }
    
    let title: String
    let icon: String?
    let style: Style
    let action: () -> Void
    
    init(_ title: String, icon: String? = nil, style: Style = .primary, action: @escaping () -> Void) {
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
                        .font(.system(size: DS.Size.iconSize))
                }
                Text(title)
                    .fontWeight(.semibold)
            }
        }
        .buttonStyle(buttonStyle)
    }
    
    private var buttonStyle: some ButtonStyle {
        switch style {
        case .primary:
            return AnyButtonStyle(DSPrimaryButtonStyle())
        case .secondary:
            return AnyButtonStyle(DSSecondaryButtonStyle())
        case .destructive:
            return AnyButtonStyle(DSDestructiveButtonStyle())
        }
    }
}

// Helper to type-erase ButtonStyle
struct AnyButtonStyle: ButtonStyle {
    private let _makeBody: (Configuration) -> AnyView
    
    init<S: ButtonStyle>(_ style: S) {
        _makeBody = { configuration in
            AnyView(style.makeBody(configuration: configuration))
        }
    }
    
    func makeBody(configuration: Configuration) -> some View {
        _makeBody(configuration)
    }
}

// MARK: - DSHealthCard

struct DSHealthCard: View {
    enum TrendDirection {
        case up
        case down
        case stable
    }
    
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    let trend: TrendDirection?
    
    var trendIcon: String {
        switch trend {
        case .up: return "arrow.up"
        case .down: return "arrow.down"
        case .stable: return "minus"
        case .none: return ""
        }
    }
    
    var trendColor: Color {
        switch trend {
        case .up: return DS.Colors.danger
        case .down: return DS.Colors.success
        case .stable: return DS.Colors.warning
        case .none: return Color.clear
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Space.sm) {
            HStack(spacing: DS.Space.sm) {
                Image(systemName: icon)
                    .font(.system(size: DS.Size.iconSizeLarge))
                    .foregroundColor(color)
                
                if trend != nil {
                    Image(systemName: trendIcon)
                        .font(.system(size: DS.Size.iconSizeSmall))
                        .foregroundColor(trendColor)
                        .padding(4)
                        .background(trendColor.opacity(0.1))
                        .clipShape(Circle())
                }
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: DS.Space.xs) {
                Text(value)
                    .font(DS.Text.title2)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                
                Text(title)
                    .font(DS.Text.caption)
                    .foregroundColor(DS.Colors.textSecondary)
                
                Text(subtitle)
                    .font(DS.Text.caption2)
                    .foregroundColor(DS.Colors.textTertiary)
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DS.AdaptiveSpace.md)
        .background(DS.Colors.cardSecondary)
        .cornerRadius(DS.AdaptiveSize.cardRadiusSmall)
        .dsAdaptiveShadow(.small)
    }
}

// MARK: - Unified DSCard

struct DSCard<Content: View>: View {
    enum Variant {
        case plain
        case bordered
        case elevated
    }
    
    enum Elevation {
        case none
        case small
        case medium
        case large
        
        var shadowLevel: ShadowLevel {
            switch self {
            case .none, .small:
                return .small
            case .medium:
                return .medium
            case .large:
                return .large
            }
        }
    }
    
    let variant: Variant
    let elevation: Elevation
    let interactive: Bool
    private let content: Content
    
    init(
        variant: Variant = .plain,
        elevation: Elevation = .small,
        interactive: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.variant = variant
        self.elevation = elevation
        self.interactive = interactive
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Space.md) {
            content
        }
        .padding(DS.AdaptiveSpace.md)
        .background(backgroundColor)
        .cornerRadius(DS.AdaptiveSize.cardRadius)
        .overlay(borderOverlay)
        .dsAdaptiveShadow(elevation.shadowLevel)
        .scaleEffect(shouldScale ? (interactive ? 0.98 : 1.0) : 1.0)
        .animation(DS.Animation.fast, value: interactive)
    }
    
    private var backgroundColor: Color {
        switch variant {
        case .plain, .bordered:
            return DS.Colors.card
        case .elevated:
            return DS.Colors.card
        }
    }
    
    @ViewBuilder
    private var borderOverlay: some View {
        if variant == .bordered {
            RoundedRectangle(cornerRadius: DS.Size.cardRadius)
                .stroke(DS.Colors.separator, lineWidth: 1)
        }
    }
    
    private var shouldScale: Bool {
        !UIAccessibility.isReduceMotionEnabled
    }
}

// Legacy DSCard for backward compatibility
struct LegacyDSCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        DSCard(variant: .plain, elevation: .small) {
            content
        }
    }
}

// MARK: - DSTag Component

struct DSTag: View {
    enum Style {
        case filled
        case outline
        case subtle
    }
    
    let text: String
    let style: Style
    let color: Color
    
    init(_ text: String, style: Style = .filled, color: Color = DS.Colors.primary) {
        self.text = text
        self.style = style
        self.color = color
    }
    
    var body: some View {
        Text(text)
            .font(DS.Text.caption)
            .fontWeight(.medium)
            .padding(.horizontal, DS.Space.sm)
            .padding(.vertical, DS.Space.xs)
            .background(backgroundColor)
            .foregroundColor(textColor)
            .cornerRadius(DS.Size.tagRadius)
            .overlay(
                borderOverlay
            )
    }
    
    private var backgroundColor: Color {
        switch style {
        case .filled:
            return color
        case .outline, .subtle:
            return color.opacity(style == .outline ? 0.1 : 0.05)
        }
    }
    
    private var textColor: Color {
        switch style {
        case .filled:
            return contrastColor(for: color)
        case .outline, .subtle:
            return color
        }
    }
    
    @ViewBuilder
    private var borderOverlay: some View {
        if style == .outline {
            RoundedRectangle(cornerRadius: DS.Size.tagRadius)
                .stroke(color, lineWidth: 1)
        }
    }
    
    private func contrastColor(for backgroundColor: Color) -> Color {
        let uiColor = UIColor(backgroundColor)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let luminance = 0.299 * red + 0.587 * green + 0.114 * blue
        return luminance > 0.5 ? Color.black : Color.white
    }
}

// MARK: - DSListRow

struct DSListRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String?
    let accessory: AnyView?
    let action: (() -> Void)?
    
    init(
        icon: String,
        iconColor: Color = DS.Colors.primary,
        title: String,
        value: String? = nil,
        accessory: AnyView? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.value = value
        self.accessory = accessory
        self.action = action
    }
    
    var body: some View {
        Button(action: action ?? {}) {
            HStack(spacing: DS.Space.md) {
                Image(systemName: icon)
                    .font(.system(size: DS.Size.iconSize))
                    .foregroundColor(iconColor)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: DS.Space.xs) {
                    Text(title)
                        .font(DS.Text.body)
                        .foregroundColor(DS.Colors.textPrimary)
                    
                    if let value = value, !value.isEmpty {
                        Text(value)
                            .font(DS.Text.caption)
                            .foregroundColor(DS.Colors.textSecondary)
                    }
                }
                
                Spacer()
                
                if let accessory = accessory {
                    accessory
                } else if action != nil {
                    Image(systemName: "chevron.right")
                        .font(.system(size: DS.Size.iconSizeSmall))
                        .foregroundColor(DS.Colors.textSecondary)
                }
            }
            .padding(.vertical, DS.Space.sm)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(action == nil)
    }
}

// MARK: - DSProgressRing

struct DSProgressRing: View {
    let progress: Double
    let size: CGFloat
    let lineWidth: CGFloat
    let color: Color
    
    init(
        progress: Double,
        size: CGFloat = DS.Size.progressRingSize,
        lineWidth: CGFloat = 6,
        color: Color = DS.Colors.primary
    ) {
        self.progress = max(0, min(1, progress))
        self.size = size
        self.lineWidth = lineWidth
        self.color = color
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    color.opacity(0.2),
                    lineWidth: lineWidth
                )
                .frame(width: size, height: size)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    color,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))
                .animation(DS.Animation.spring, value: progress)
        }
    }
}

// MARK: - DSFloatingActionButton (Modern ButtonStyle)

struct DSFloatingActionButton: View {
    let action: () -> Void
    let onLongPress: (() -> Void)?
    
    init(action: @escaping () -> Void, onLongPress: (() -> Void)? = nil) {
        self.action = action
        self.onLongPress = onLongPress
    }
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.system(size: DS.Size.iconSizeLarge, weight: .bold))
        }
        .buttonStyle(DSFABStyle())
        .onLongPressGesture(minimumDuration: 0.5) {
            onLongPress?()
        }
        .accessibilityLabel(NSLocalizedString("a11y.new.cigarette", comment: ""))
        .accessibilityHint(NSLocalizedString("a11y.new.cigarette.hint", comment: ""))
        .accessibilityAddTraits(.isButton)
    }
}