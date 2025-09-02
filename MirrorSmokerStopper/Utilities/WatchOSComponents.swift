//
//  WatchOSComponents.swift
//  MirrorSmokerStopper
//
//  Created by Claude on 02/09/25.
//

import SwiftUI

#if os(watchOS)
import WatchKit

// MARK: - watchOS-Specific Design System
extension DS {
    struct WatchOS {
        // watchOS-optimized spacing
        static let edgeSpacing: CGFloat = 8
        static let contentSpacing: CGFloat = 6
        static let minTapTarget: CGFloat = 44
        
        // watchOS-safe colors for better contrast
        struct Colors {
            static let primary = Color.white
            static let secondary = Color.gray
            static let background = Color.black
            static let accent = Color.blue
            static let success = Color.green
            static let warning = Color.orange
            static let danger = Color.red
        }
        
        // watchOS-optimized sizes
        struct Size {
            static let cardRadius: CGFloat = 8
            static let buttonRadius: CGFloat = 6
            static let tagRadius: CGFloat = 4
            static let iconSize: CGFloat = 16
            static let buttonHeight: CGFloat = 35
            static let fabSize: CGFloat = 44 // Minimum tap target
        }
    }
}

// MARK: - watchOS-Optimized Components
struct WatchOSCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(DS.WatchOS.contentSpacing)
            .background(Color(.systemGray6))
            .cornerRadius(DS.WatchOS.Size.cardRadius)
            // No shadows on watchOS - they don't render well
    }
}

struct WatchOSButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DS.WatchOS.contentSpacing) {
                Image(systemName: systemImage)
                    .font(.system(size: DS.WatchOS.Size.iconSize, weight: .medium))
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .frame(minHeight: DS.WatchOS.Size.buttonHeight)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, DS.WatchOS.contentSpacing)
            .background(DS.WatchOS.Colors.accent)
            .foregroundColor(.white)
            .cornerRadius(DS.WatchOS.Size.buttonRadius)
        }
        .buttonStyle(.plain)
    }
}

struct WatchOSProgressRing: View {
    let progress: Double
    let size: CGFloat
    let lineWidth: CGFloat
    let color: Color
    
    init(
        progress: Double,
        size: CGFloat = 40,
        lineWidth: CGFloat = 4,
        color: Color = DS.WatchOS.Colors.accent
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
                    Color(.systemGray4),
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
        }
    }
}

struct WatchOSStatCard: View {
    let title: String
    let value: String
    let color: Color
    let subtitle: String?
    
    init(title: String, value: String, color: Color = DS.WatchOS.Colors.primary, subtitle: String? = nil) {
        self.title = title
        self.value = value
        self.color = color
        self.subtitle = subtitle
    }
    
    var body: some View {
        WatchOSCard {
            VStack(spacing: 2) {
                Text(title)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                
                Text(value)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(color)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundColor(.tertiary)
                }
            }
        }
    }
}

// MARK: - watchOS-Specific Cigarette Tracker Components
struct WatchOSCigaretteCounter: View {
    let count: Int
    let target: Int
    
    private var statusColor: Color {
        if count == 0 { return DS.WatchOS.Colors.success }
        if count <= target { return DS.WatchOS.Colors.warning }
        return DS.WatchOS.Colors.danger
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(statusColor)
            
            Text(NSLocalizedString("widget.today", comment: ""))
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
        }
    }
}

struct WatchOSAddButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .frame(width: DS.WatchOS.Size.fabSize, height: DS.WatchOS.Size.fabSize)
                .background(DS.WatchOS.Colors.accent)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Crown Rotation Support
struct CrownRotationHandler<T: Hashable>: ViewModifier {
    @Binding var selection: T
    let values: [T]
    
    func body(content: Content) -> some View {
        content
            .focusable(true)
            .digitalCrownRotation(
                $selection,
                from: values,
                by: 1,
                sensitivity: .medium,
                isContinuous: false,
                isHapticFeedbackEnabled: true
            )
    }
}

extension View {
    func crownRotation<T: Hashable>(_ binding: Binding<T>, from values: [T]) -> some View {
        modifier(CrownRotationHandler(selection: binding, values: values))
    }
}

// MARK: - watchOS Widget Components
struct WatchOSCigaretteWidget: View {
    let todayCount: Int
    let statusColor: Color
    let addAction: () -> Void
    
    var body: some View {
        VStack(spacing: DS.WatchOS.contentSpacing) {
            // Today count with optimized sizing
            VStack(spacing: 2) {
                Text("\(todayCount)")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(statusColor)
                
                Text(NSLocalizedString("widget.today", comment: ""))
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
            }
            
            // Add button optimized for watch
            WatchOSAddButton(action: addAction)
        }
        .padding(DS.WatchOS.edgeSpacing)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DS.WatchOS.Colors.background)
    }
}

// MARK: - watchOS Preview Helpers
struct WatchOSPreview<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .frame(width: 184, height: 224) // 40mm watch frame
            .background(Color.black)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .previewDisplayName("Apple Watch 40mm")
    }
}

// MARK: - Platform Testing Preview
#Preview("watchOS Component Test") {
    WatchOSPreview {
        VStack(spacing: DS.WatchOS.contentSpacing) {
            WatchOSStatCard(
                title: "Test",
                value: "42",
                color: DS.WatchOS.Colors.success,
                subtitle: "platform test"
            )
            
            WatchOSCigaretteCounter(count: 5, target: 10)
            
            WatchOSAddButton { }
            
            WatchOSProgressRing(progress: 0.7)
        }
        .padding(DS.WatchOS.edgeSpacing)
    }
}

#endif