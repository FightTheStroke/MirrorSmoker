//
//  ColorExtensions.swift
//  MirrorSmokerStopper
//
//  Created by Claude on 02/09/25.
//

import SwiftUI

// MARK: - Color Extensions (Consolidating Hex Utilities)
extension Color {
    /// Unified hex color conversion utility
    /// Replaces both `Color(hex:)` and `Color.fromHex(...)` across the app
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0) // Default to black for invalid hex
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    /// Deprecated: Use init(hex:) instead
    @available(*, deprecated, message: "Use Color(hex:) instead")
    static func fromHex(_ hex: String) -> Color? {
        return Color(hex: hex)
    }
    
    /// Calculate the luminance of a color for contrast calculations
    func luminance() -> Double {
        let components = UIColor(self).cgColor.components ?? [0, 0, 0, 1]
        let red = components[0]
        let green = components[1]
        let blue = components[2]
        
        // Convert to linear RGB
        func linearize(_ value: CGFloat) -> CGFloat {
            return value <= 0.03928 ? value / 12.92 : pow((value + 0.055) / 1.055, 2.4)
        }
        
        let r = linearize(red)
        let g = linearize(green)
        let b = linearize(blue)
        
        // Calculate luminance using standard weights
        return 0.2126 * Double(r) + 0.7152 * Double(g) + 0.0722 * Double(b)
    }
    
    /// Calculate contrast ratio between two colors (WCAG guidelines)
    func contrastRatio(with other: Color) -> Double {
        let lum1 = self.luminance()
        let lum2 = other.luminance()
        let lighter = max(lum1, lum2)
        let darker = min(lum1, lum2)
        return (lighter + 0.05) / (darker + 0.05)
    }
    
    /// Check if color combination meets WCAG AA contrast standards
    func meetsWCAGAA(with background: Color) -> Bool {
        return contrastRatio(with: background) >= 4.5
    }
    
    /// Check if color combination meets WCAG AAA contrast standards
    func meetsWCAGAAA(with background: Color) -> Bool {
        return contrastRatio(with: background) >= 7.0
    }
    
    /// Get appropriate text color (black or white) for maximum contrast
    func appropriateTextColor() -> Color {
        return luminance() > 0.5 ? .black : .white
    }
}