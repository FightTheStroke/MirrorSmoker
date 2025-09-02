//
//  DesignSystemPreviews.swift
//  MirrorSmokerStopper
//
//  Created by Claude on 02/09/25.
//

import SwiftUI

#if DEBUG
// MARK: - DSCard Previews
struct DSCard_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: DS.Space.lg) {
                Group {
                    // Plain variants
                    DSCard(variant: .plain, elevation: .none) {
                        sampleCardContent(title: "Plain - No Elevation")
                    }
                    
                    DSCard(variant: .plain, elevation: .small) {
                        sampleCardContent(title: "Plain - Small Elevation")
                    }
                    
                    DSCard(variant: .plain, elevation: .medium) {
                        sampleCardContent(title: "Plain - Medium Elevation")
                    }
                    
                    DSCard(variant: .plain, elevation: .large) {
                        sampleCardContent(title: "Plain - Large Elevation")
                    }
                }
                
                Group {
                    // Bordered variants
                    DSCard(variant: .bordered, elevation: .none) {
                        sampleCardContent(title: "Bordered - No Elevation")
                    }
                    
                    DSCard(variant: .bordered, elevation: .small) {
                        sampleCardContent(title: "Bordered - Small Elevation")
                    }
                }
                
                Group {
                    // Elevated variants
                    DSCard(variant: .elevated, elevation: .medium) {
                        sampleCardContent(title: "Elevated - Medium")
                    }
                    
                    DSCard(variant: .elevated, elevation: .large) {
                        sampleCardContent(title: "Elevated - Large")
                    }
                }
                
                Group {
                    // Interactive variants
                    DSCard(variant: .plain, elevation: .small, interactive: true) {
                        sampleCardContent(title: "Interactive Card")
                    }
                }
            }
            .padding()
        }
        .background(DS.Colors.background)
        .previewDisplayName("DSCard Variants")
    }
    
    private static func sampleCardContent(title: String) -> some View {
        VStack(alignment: .leading, spacing: DS.Space.sm) {
            Text(title)
                .font(DS.Text.headline)
                .foregroundColor(DS.Colors.textPrimary)
            
            Text("Sample card content with description text that demonstrates the card layout and typography.")
                .font(DS.Text.body)
                .foregroundColor(DS.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DS.Space.md)
    }
}

// MARK: - DSTag Previews
struct DSTag_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: DS.Space.lg) {
                VStack(alignment: .leading, spacing: DS.Space.md) {
                    Text("Filled Style")
                        .font(DS.Text.headline)
                        .foregroundColor(DS.Colors.textPrimary)
                    
                    HStack(spacing: DS.Space.sm) {
                        DSTag("Work", style: .filled, color: DS.Colors.primary)
                        DSTag("Stress", style: .filled, color: DS.Colors.danger)
                        DSTag("Social", style: .filled, color: DS.Colors.success)
                        DSTag("Break", style: .filled, color: DS.Colors.warning)
                    }
                }
                
                VStack(alignment: .leading, spacing: DS.Space.md) {
                    Text("Outline Style")
                        .font(DS.Text.headline)
                        .foregroundColor(DS.Colors.textPrimary)
                    
                    HStack(spacing: DS.Space.sm) {
                        DSTag("Work", style: .outline, color: DS.Colors.primary)
                        DSTag("Stress", style: .outline, color: DS.Colors.danger)
                        DSTag("Social", style: .outline, color: DS.Colors.success)
                        DSTag("Break", style: .outline, color: DS.Colors.warning)
                    }
                }
                
                VStack(alignment: .leading, spacing: DS.Space.md) {
                    Text("Subtle Style")
                        .font(DS.Text.headline)
                        .foregroundColor(DS.Colors.textPrimary)
                    
                    HStack(spacing: DS.Space.sm) {
                        DSTag("Work", style: .subtle, color: DS.Colors.primary)
                        DSTag("Stress", style: .subtle, color: DS.Colors.danger)
                        DSTag("Social", style: .subtle, color: DS.Colors.success)
                        DSTag("Break", style: .subtle, color: DS.Colors.warning)
                    }
                }
                
                VStack(alignment: .leading, spacing: DS.Space.md) {
                    Text("Custom Colors")
                        .font(DS.Text.headline)
                        .foregroundColor(DS.Colors.textPrimary)
                    
                    VStack(spacing: DS.Space.sm) {
                        HStack(spacing: DS.Space.sm) {
                            DSTag("Custom Blue", style: .filled, color: Color(hex: "#007AFF") ?? Color.blue)
                            DSTag("Custom Purple", style: .filled, color: Color(hex: "#AF52DE") ?? Color.purple)
                        }
                        HStack(spacing: DS.Space.sm) {
                            DSTag("Custom Blue", style: .outline, color: Color(hex: "#007AFF") ?? Color.blue)
                            DSTag("Custom Purple", style: .outline, color: Color(hex: "#AF52DE") ?? Color.purple)
                        }
                    }
                }
            }
            .padding()
        }
        .background(DS.Colors.background)
        .previewDisplayName("DSTag Styles")
    }
}

// MARK: - Button Style Previews  
struct DSButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: DS.Space.lg) {
            VStack(spacing: DS.Space.md) {
                Text("Button Styles")
                    .font(DS.Text.title)
                    .foregroundColor(DS.Colors.textPrimary)
                
                Button("Primary Button") { }
                    .buttonStyle(DSPrimaryButtonStyle())
                
                Button("Secondary Button") { }
                    .buttonStyle(DSSecondaryButtonStyle())
                
                Button("Destructive Button") { }
                    .buttonStyle(DSDestructiveButtonStyle())
            }
            
            VStack(spacing: DS.Space.md) {
                Text("Disabled States")
                    .font(DS.Text.headline)
                    .foregroundColor(DS.Colors.textPrimary)
                
                Button("Disabled Primary") { }
                    .buttonStyle(DSPrimaryButtonStyle())
                    .disabled(true)
                
                Button("Disabled Secondary") { }
                    .buttonStyle(DSSecondaryButtonStyle())
                    .disabled(true)
            }
            
            VStack(spacing: DS.Space.md) {
                Text("Floating Action Button")
                    .font(DS.Text.headline)
                    .foregroundColor(DS.Colors.textPrimary)
                
                DSFloatingActionButton(
                    action: { print("FAB tapped") },
                    onLongPress: { print("FAB long pressed") }
                )
            }
        }
        .padding()
        .background(DS.Colors.background)
        .previewDisplayName("Button Styles")
    }
}

// MARK: - Progress Ring Previews
struct DSProgressRing_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: DS.Space.lg) {
            Text("Progress Rings")
                .font(DS.Text.title)
                .foregroundColor(DS.Colors.textPrimary)
            
            HStack(spacing: DS.Space.lg) {
                VStack {
                    DSProgressRing(progress: 0.25, size: 60)
                    Text("25%")
                        .font(DS.Text.caption)
                        .foregroundColor(DS.Colors.textSecondary)
                }
                
                VStack {
                    DSProgressRing(progress: 0.5, size: 80, color: DS.Colors.success)
                    Text("50%")
                        .font(DS.Text.caption)
                        .foregroundColor(DS.Colors.textSecondary)
                }
                
                VStack {
                    DSProgressRing(progress: 0.75, size: 100, color: DS.Colors.warning)
                    Text("75%")
                        .font(DS.Text.caption)
                        .foregroundColor(DS.Colors.textSecondary)
                }
                
                VStack {
                    DSProgressRing(progress: 1.0, size: 60, color: DS.Colors.danger)
                    Text("100%")
                        .font(DS.Text.caption)
                        .foregroundColor(DS.Colors.textSecondary)
                }
            }
        }
        .padding()
        .background(DS.Colors.background)
        .previewDisplayName("Progress Rings")
    }
}

// MARK: - Typography Previews
struct DSTypography_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DS.Space.md) {
                Group {
                    Text("Display Text (JetBrains Mono)")
                        .font(DS.Text.display)
                        .foregroundColor(DS.Colors.textPrimary)
                    
                    Text("Large Title")
                        .font(DS.Text.largeTitle)
                        .foregroundColor(DS.Colors.textPrimary)
                    
                    Text("Title")
                        .font(DS.Text.title)
                        .foregroundColor(DS.Colors.textPrimary)
                    
                    Text("Title 2")
                        .font(DS.Text.title2)
                        .foregroundColor(DS.Colors.textPrimary)
                    
                    Text("Title 3")
                        .font(DS.Text.title3)
                        .foregroundColor(DS.Colors.textPrimary)
                }
                
                Group {
                    Text("Headline")
                        .font(DS.Text.headline)
                        .foregroundColor(DS.Colors.textPrimary)
                    
                    Text("Subheadline")
                        .font(DS.Text.subheadline)
                        .foregroundColor(DS.Colors.textPrimary)
                    
                    Text("Body text with regular font weight")
                        .font(DS.Text.body)
                        .foregroundColor(DS.Colors.textPrimary)
                    
                    Text("Body Bold")
                        .font(DS.Text.bodyBold)
                        .foregroundColor(DS.Colors.textPrimary)
                    
                    Text("Monospace Body (JetBrains Mono)")
                        .font(DS.Text.bodyMono)
                        .foregroundColor(DS.Colors.textPrimary)
                }
                
                Group {
                    Text("Callout")
                        .font(DS.Text.callout)
                        .foregroundColor(DS.Colors.textSecondary)
                    
                    Text("Caption")
                        .font(DS.Text.caption)
                        .foregroundColor(DS.Colors.textSecondary)
                    
                    Text("Caption 2")
                        .font(DS.Text.caption2)
                        .foregroundColor(DS.Colors.textTertiary)
                    
                    Text("Monospace Caption (JetBrains Mono)")
                        .font(DS.Text.captionMono)
                        .foregroundColor(DS.Colors.textSecondary)
                    
                    Text("Inline Code (JetBrains Mono)")
                        .font(DS.Text.code)
                        .foregroundColor(DS.Colors.textPrimary)
                }
            }
            .padding()
        }
        .background(DS.Colors.background)
        .previewDisplayName("Typography Scale")
    }
}

// MARK: - Color Palette Previews
struct DSColors_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: DS.Space.lg) {
                colorSection("Primary Colors", colors: [
                    ("Primary", DS.Colors.primary),
                    ("Success", DS.Colors.success),
                    ("Warning", DS.Colors.warning),
                    ("Danger", DS.Colors.danger),
                    ("Info", DS.Colors.info)
                ])
                
                colorSection("Background Colors", colors: [
                    ("Background", DS.Colors.background),
                    ("Background Secondary", DS.Colors.backgroundSecondary),
                    ("Card", DS.Colors.card),
                    ("Card Secondary", DS.Colors.cardSecondary)
                ])
                
                colorSection("Text Colors", colors: [
                    ("Text Primary", DS.Colors.textPrimary),
                    ("Text Secondary", DS.Colors.textSecondary),
                    ("Text Tertiary", DS.Colors.textTertiary),
                    ("Text Inverse", DS.Colors.textInverse)
                ])
            }
            .padding()
        }
        .background(DS.Colors.background)
        .previewDisplayName("Color Palette")
    }
    
    private static func colorSection(_ title: String, colors: [(String, Color)]) -> some View {
        VStack(alignment: .leading, spacing: DS.Space.sm) {
            Text(title)
                .font(DS.Text.headline)
                .foregroundColor(DS.Colors.textPrimary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: DS.Space.sm) {
                ForEach(colors, id: \.0) { name, color in
                    HStack {
                        RoundedRectangle(cornerRadius: DS.Size.cardRadiusSmall)
                            .fill(color)
                            .frame(width: 40, height: 40)
                        
                        Text(name)
                            .font(DS.Text.body)
                            .foregroundColor(DS.Colors.textPrimary)
                        
                        Spacer()
                    }
                    .padding(DS.Space.sm)
                    .background(DS.Colors.backgroundSecondary)
                    .cornerRadius(DS.Size.cardRadiusSmall)
                }
            }
        }
    }
}

#endif