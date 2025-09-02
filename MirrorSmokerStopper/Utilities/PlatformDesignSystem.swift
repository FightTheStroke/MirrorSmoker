//
//  PlatformDesignSystem.swift
//  MirrorSmokerStopper
//
//  Created by Claude on 02/09/25.
//

import SwiftUI

// MARK: - Platform-Aware Design System Extensions
extension DS {
    
    // MARK: - Platform Detection
    struct Platform {
        #if os(iOS)
        static let current: PlatformType = .iOS
        #elseif os(watchOS)
        static let current: PlatformType = .watchOS
        #elseif os(macOS)
        static let current: PlatformType = .macOS
        #else
        static let current: PlatformType = .other
        #endif
    }
    
    enum PlatformType {
        case iOS, watchOS, macOS, other
    }
    
    // MARK: - Platform-Adaptive Sizes
    struct AdaptiveSize {
        // Platform scaling factors
        private static var scaleFactor: CGFloat {
            switch Platform.current {
            case .watchOS:
                return 0.7 // Smaller for watch
            case .macOS:
                return 1.1 // Slightly larger for desktop
            case .iOS:
                return 1.0 // Standard
            case .other:
                return 1.0
            }
        }
        
        // Corner radius - watchOS prefers smaller values
        static var cardRadius: CGFloat {
            switch Platform.current {
            case .watchOS:
                return 8
            case .macOS:
                return 12
            default:
                return DS.Size.cardRadius
            }
        }
        
        static var cardRadiusSmall: CGFloat {
            switch Platform.current {
            case .watchOS:
                return 6
            case .macOS:
                return 8
            default:
                return DS.Size.cardRadiusSmall
            }
        }
        
        static var buttonRadius: CGFloat {
            switch Platform.current {
            case .watchOS:
                return 6
            case .macOS:
                return 10
            default:
                return DS.Size.buttonRadius
            }
        }
        
        static var tagRadius: CGFloat {
            switch Platform.current {
            case .watchOS:
                return 4
            default:
                return DS.Size.tagRadius
            }
        }
        
        // Button sizes with platform scaling
        static var buttonHeight: CGFloat {
            let base: CGFloat = 50
            return base * scaleFactor
        }
        
        static var buttonHeightSmall: CGFloat {
            let base: CGFloat = 36
            return base * scaleFactor
        }
        
        // FAB size - watchOS needs 44pt minimum
        static var fabSize: CGFloat {
            switch Platform.current {
            case .watchOS:
                return 44 // Apple Watch minimum tap target
            default:
                return DS.Size.fabSize
            }
        }
        
        // Icon sizes
        static var iconSize: CGFloat {
            DS.Size.iconSize * scaleFactor
        }
        
        static var iconSizeLarge: CGFloat {
            DS.Size.iconSizeLarge * scaleFactor
        }
    }
    
    // MARK: - Platform-Adaptive Shadows
    struct AdaptiveShadow {
        // watchOS doesn't support shadows well, use subtle alternatives
        static var small: DSShadow {
            switch Platform.current {
            case .watchOS:
                return DSShadow(color: Color.clear, radius: 0, x: 0, y: 0) // No shadow on watchOS
            default:
                return DS.Shadow.small
            }
        }
        
        static var medium: DSShadow {
            switch Platform.current {
            case .watchOS:
                return DSShadow(color: Color.clear, radius: 0, x: 0, y: 0) // No shadow on watchOS
            case .macOS:
                return DSShadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4) // Stronger for macOS
            default:
                return DS.Shadow.medium
            }
        }
        
        static var large: DSShadow {
            switch Platform.current {
            case .watchOS:
                return DSShadow(color: Color.clear, radius: 0, x: 0, y: 0) // No shadow on watchOS
            case .macOS:
                return DSShadow(color: Color.black.opacity(0.12), radius: 16, x: 0, y: 8) // Stronger for macOS
            default:
                return DS.Shadow.large
            }
        }
    }
    
    // MARK: - Platform-Adaptive Spacing
    struct AdaptiveSpace {
        private static var scaleFactor: CGFloat {
            switch Platform.current {
            case .watchOS:
                return 0.7 // Smaller for watch
            case .macOS:
                return 1.1 // Slightly larger for desktop
            case .iOS:
                return 1.0 // Standard
            case .other:
                return 1.0
            }
        }
        
        static var xs: CGFloat { DS.Space.xs * scaleFactor }
        static var sm: CGFloat { DS.Space.sm * scaleFactor }
        static var md: CGFloat { DS.Space.md * scaleFactor }
        static var lg: CGFloat { DS.Space.lg * scaleFactor }
        static var xl: CGFloat { DS.Space.xl * scaleFactor }
        
        // Special spacing for watchOS
        static var watchSafe: CGFloat {
            switch Platform.current {
            case .watchOS:
                return 4 // Minimal spacing for watch
            default:
                return DS.Space.sm
            }
        }
    }
}

// MARK: - Platform-Aware View Extensions
extension View {
    /// Apply platform-appropriate card styling
    func dsAdaptiveCard() -> some View {
        self
            .background(DS.Colors.card)
            .cornerRadius(DS.AdaptiveSize.cardRadius)
            .dsShadow(DS.AdaptiveShadow.small)
    }
    
    /// Apply platform-appropriate shadow
    func dsAdaptiveShadow(_ level: ShadowLevel = .small) -> some View {
        switch level {
        case .small:
            return self.dsShadow(DS.AdaptiveShadow.small)
        case .medium:
            return self.dsShadow(DS.AdaptiveShadow.medium)
        case .large:
            return self.dsShadow(DS.AdaptiveShadow.large)
        }
    }
}

enum ShadowLevel {
    case small, medium, large
}

// MARK: - Platform-Specific Button Styles
struct PlatformAdaptiveButtonStyle: ButtonStyle {
    let variant: ButtonVariant
    
    enum ButtonVariant {
        case primary, secondary, destructive
        
        var backgroundColor: Color {
            switch self {
            case .primary: return DS.Colors.primary
            case .secondary: return DS.Colors.backgroundSecondary
            case .destructive: return DS.Colors.danger
            }
        }
        
        var textColor: Color {
            switch self {
            case .primary, .destructive: return DS.Colors.textInverse
            case .secondary: return DS.Colors.textPrimary
            }
        }
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(height: DS.AdaptiveSize.buttonHeight)
            .frame(maxWidth: .infinity)
            .background(variant.backgroundColor)
            .foregroundColor(variant.textColor)
            .cornerRadius(DS.AdaptiveSize.buttonRadius)
            .dsAdaptiveShadow(.small)
            .scaleEffect(shouldAnimate ? (configuration.isPressed ? 0.98 : 1.0) : 1.0)
            .animation(DS.Animation.fast, value: configuration.isPressed)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
    
    private var shouldAnimate: Bool {
        switch DS.Platform.current {
        case .watchOS:
            return false // Minimal animations on watchOS for battery life
        default:
            return !UIAccessibility.isReduceMotionEnabled
        }
    }
}

// MARK: - watchOS-Specific Components
#if os(watchOS)
extension DS {
    struct WatchOS {
        // Digital Crown rotation support
        static func crownRotationModifier<T: Hashable>(
            _ binding: Binding<T>,
            from values: [T]
        ) -> some ViewModifier {
            return CrownRotationModifier(binding: binding, values: values)
        }
        
        // Watch-specific spacing
        static let edgeSpacing: CGFloat = 8
        static let contentSpacing: CGFloat = 6
        
        // Watch-safe colors (better contrast for small screen)
        static let primaryWatch = Color.white
        static let secondaryWatch = Color.gray
        static let backgroundWatch = Color.black
    }
}

struct CrownRotationModifier<T: Hashable>: ViewModifier {
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
#endif

// MARK: - Platform Consistency Validation
struct PlatformConsistencyValidator {
    static func validateDesignSystem() {
        print("🔍 Design System Platform Consistency Check")
        print("Platform: \(DS.Platform.current)")
        print("Card Radius: \(DS.AdaptiveSize.cardRadius)")
        print("FAB Size: \(DS.AdaptiveSize.fabSize)")
        print("Shadow Small: \(DS.AdaptiveShadow.small)")
        
        #if os(watchOS)
        print("⌚ watchOS optimizations active")
        #elseif os(macOS)
        print("💻 macOS optimizations active")
        #else
        print("📱 iOS standard configuration")
        #endif
    }
}