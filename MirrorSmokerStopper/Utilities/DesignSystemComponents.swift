//
//  DesignSystemComponents.swift
//  MirrorSmokerStopper
//
//  Created by Assistant on 01/09/25.
//

import SwiftUI

// MARK: - DSButton

struct DSButton: View {
    enum Style {
        case primary
        case secondary
        case destructive
        
        var backgroundColor: Color {
            switch self {
            case .primary: return DS.Colors.buttonPrimary
            case .secondary: return DS.Colors.buttonSecondary
            case .destructive: return DS.Colors.danger
            }
        }
        
        var textColor: Color {
            switch self {
            case .primary: return DS.Colors.textInverse
            case .secondary: return DS.Colors.textPrimary
            case .destructive: return DS.Colors.textInverse
            }
        }
        
        var borderColor: Color {
            switch self {
            case .primary: return DS.Colors.buttonPrimary
            case .secondary: return DS.Colors.separator
            case .destructive: return DS.Colors.danger
            }
        }
    }
    
    let title: String
    let icon: String?
    let style: Style
    let action: () -> Void
    @State private var isPressed = false
    
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
            .frame(maxWidth: .infinity)
            .padding(.vertical, DS.Space.md)
            .padding(.horizontal, DS.Space.lg)
            .background(
                style.backgroundColor
                    .opacity(isPressed ? 0.8 : 1.0)
            )
            .foregroundColor(style.textColor)
            .cornerRadius(DS.Size.buttonRadius)
            .overlay(
                RoundedRectangle(cornerRadius: DS.Size.buttonRadius)
                    .stroke(style.borderColor, lineWidth: style == .secondary ? 1 : 0)
            )
            .animation(DS.Animation.fast, value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    isPressed = true
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
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
                
                if let trend = trend {
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
        .padding(DS.Space.md)
        .background(DS.Colors.cardSecondary)
        .cornerRadius(DS.Size.cardRadiusSmall)
        .dsShadow(DS.Shadow.small)
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
            // Background ring
            Circle()
                .stroke(
                    color.opacity(0.2),
                    lineWidth: lineWidth
                )
                .frame(width: size, height: size)
            
            // Progress ring
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

// MARK: - DSFloatingActionButton

struct DSFloatingActionButton: View {
    let action: () -> Void
    @State private var isPressed = false
    
    init(action: @escaping () -> Void) {
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.system(size: DS.Size.iconSizeLarge, weight: .bold))
                .foregroundColor(DS.Colors.textInverse)
                .frame(width: DS.Size.fabSize, height: DS.Size.fabSize)
                .background(
                    DS.Colors.primary
                        .opacity(isPressed ? 0.8 : 1.0)
                )
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                .scaleEffect(isPressed ? 0.95 : 1.0)
                .animation(DS.Animation.fast, value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    isPressed = true
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
    }
}