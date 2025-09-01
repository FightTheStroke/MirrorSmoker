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
        static let primary = Color.blue
        static let secondary = Color.gray
        static let success = Color.green
        static let warning = Color.orange
        static let danger = Color.red
        static let background = Color(.systemGroupedBackground)
        static let card = Color(.systemBackground)
        static let textPrimary = Color.primary
        static let textSecondary = Color.secondary
        
        // Cigarette-specific colors
        static let cigarette = Color.red
        static let smoke = Color.gray.opacity(0.6)
    }
    
    // MARK: - Typography
    struct Text {
        static let largeTitle = Font.largeTitle.weight(.bold)
        static let title = Font.title2.weight(.semibold)
        static let headline = Font.headline.weight(.medium)
        static let body = Font.body
        static let caption = Font.caption
        static let small = Font.caption2
    }
    
    // MARK: - Spacing
    struct Space {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 40
    }
    
    // MARK: - Sizes
    struct Size {
        static let buttonHeight: CGFloat = 50
        static let cardRadius: CGFloat = 16
        static let buttonRadius: CGFloat = 12
        static let iconSize: CGFloat = 20
        static let fabSize: CGFloat = 56
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
                    .font(DS.Text.small)
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