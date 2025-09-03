//  DesignSystem.swift
//  MirrorSmokerStopper
//
//  Created by Assistant on 09/01/25.
//

import SwiftUI

// MARK: - Modern Design System
struct DS {
    // MARK: - Colors (Smoking Cessation Oriented Color Palette)
    struct Colors {
        // === PRIMARY BRAND COLORS ===

        // Primary action color (motivational blue)
        static let primary = Color(hex: "#3B82F6")!
        static let primaryLight = Color(hex: "#60A5FA")!
        static let primaryDark = Color(hex: "#2563EB")!

        // === SMOKING CESSATION SEMANTIC COLORS ===

        // CIGARETTE CONSUMPTION LEVELS (ORIENTAZIONE POSITIVA)
        // Rosso scuro = Critico (alto consumo) → Verde = Eccellente (basso/prossimo quota)
        static let smokingProgressCritical = Color(hex: "#DC2626")!    // <1% target, critic
        static let smokingProgressHigh = Color(hex: "#EF4444")!        // 80-99% target, alto rischio
        static let smokingProgressWarning = Color(hex: "#F97316")!      // 60-79% target, attenzione
        static let smokingProgressCaution = Color(hex: "#EAB308")!      // 40-59% target, cautela
        static let smokingProgressModerate = Color(hex: "#84CC16")!     // 20-39% target, moderato
        static let smokingProgressGood = Color(hex: "#22C55E")!         // 10-19% target, buono
        static let smokingProgressExcellent = Color(hex: "#16A34A")!    // 0-9% target, eccellente

        // PERFECT DAY ACHIEVEMENTS (verdi scuri per successo)
        static let achievementPerfectDay = Color(hex: "#166534")!      // 0 sigarette = perfetto!
        static let achievementQuotaMet = Color(hex: "#15803D")!         // Controllo <= quota

        // HEALTH IMPROVEMENT COLORS (verdi per benefici salute)
        static let healthImprovementExcellent = Color(hex: "#16A34A")! // Miglioramento eccellente
        static let healthImprovement = Color(hex: "#22C55E")!           // Miglioramento buono
        static let healthDecline = Color(hex: "#DC2626")!               // Peggioramento

        // === BEHAVIORAL CUES ===
        static let motivationInspiring = Color(hex: "#7C3AED")!        // Viola per motivazione
        static let habitTrigger = Color(hex: "#EA580C")!               // Arancione per trigger
        static let urgeManagement = Color(hex: "#059669")!             // Verde acqua per gest.urges

        // === LEGACY SEMANTIC COLORS (mapped to smoking semantic) ===
        static let success = smokingProgressExcellent     // Riutilizzo per compatibilità
        static let warning = smokingProgressWarning       // <30% = successo vs target
        static let danger = smokingProgressCritical       // Alto rischio vs quota giornaliera
        static let info = primary                         // Info usa brand primary

        // === BACKGROUND HIERARCHY ===
        static let background = Color.white
        static let backgroundSecondary = Color(hex: "#F8FAFC")!
        static let backgroundTertiary = Color(hex: "#F1F5F9")!
        static let card = Color.white
        static let cardSecondary = Color(hex: "#F8FAFC")!
        static let separator = Color(hex: "#E2E8F0")!

        // === TEXT HIERARCHY ===
        static let textPrimary = Color(hex: "#0F172A")!
        static let textSecondary = Color(hex: "#475569")!
        static let textTertiary = Color(hex: "#64748B")!
        static let textInverse = Color.white

        // === GLASS MORPHISM COLORS (enhanced for smoking cessation app) ===
        static let glassPrimary = Color.white.opacity(0.4)     // Semi-transparent glass
        static let glassSecondary = Color.white.opacity(0.2)   // Lighter glass
        static let glassTertiary = Color.white.opacity(0.1)    // Very light glass
        static let glassQuaternary = Color.black.opacity(0.05) // Subtle border

        // === INTERACTIVE COLORS ===
        static let buttonPrimary = primary
        static let buttonSecondary = Color(hex: "#E2E8F0")!
        static let buttonDisabled = Color(hex: "#CBD5E1")!
        static let link = primaryDark
        static let linkVisited = primaryDark.opacity(0.8)

        // === CHART COLORS ( smoking cessation oriented ) ===
        // Linea principale: fumo attuale vs target (semantica di progresso)
        static let chartCigaretteCount = smokingProgressHigh       // Rosso per sigarette contate
        static let chartTargetLine = smokingProgressGood            // Verde per linea obiettivo
        static let chartAverageLine = Color(hex: "#64748B")!          // Grigio neutro per media
        static let chartTrendPositive = smokingProgressExcellent   // Verde per trend positivo (diminuzione)
        static let chartTrendNegative = smokingProgressCritical    // Rosso per trend negativo (aumento)

        // Altri grafici
        static let chartSecondary = smokingProgressCaution         // Giallo per salvataggio
        static let chartTertiary = healthImprovement               // Verde per benefici salute

        // === TAG COLORS (context-aware smoking situations) ===
        static let tagWork = Color(hex: "#8B5CF6")!                  // Viola per lavoro
        static let tagStress = Color(hex: "#F59E0B")!                // Giallo arancione per stress
        static let tagSocial = Color(hex: "#06B6D4")!                // Ciano per sociale
        static let tagHealth = smokingProgressExcellent            // Verde per salute

        // === STATUS COLORS (mapped to smoking context) ===
        static let statusGood = smokingProgressGood                // Buona performance vs quota
        static let statusWarning = smokingProgressCaution           // Attenzione vs obiettivo
        static let statusCritical = smokingProgressCritical         // Problema vs target giornaliero
        static let statusNeutral = textSecondary                    // Neutro/paused

        // === BACKWARD COMPATIBILITY COLORS ===
        static let cigarette = smokingProgressHigh                 // Legacy from old AppColors
        static let smoke = Color(hex: "#9CA3AF")!                    // Grigio neutro per fumo
        static let health = healthImprovement                       // Salute mapped
        static let progress = smokingProgressGood                  // Progress mapped

        // === CHART COLORS LEGACY (fallback) ===
        static let chart1 = smokingProgressHigh                    // Cigarette count - Legacy naming
        static let chart2 = smokingProgressGood                    // Target - Legacy naming
        static let chart3 = smokingProgressCaution                 // Savings trend - Legacy naming
        static let chart4 = healthImprovement                      // Health benefits - Legacy naming
        static let chart5 = primaryDark                            // Motivational trend - Legacy naming

        // === SPECIAL COLORS ===
        static let attention = Color(hex: "#F59E0B")!               // Arancione per attenzione
        static let motivation = motivationInspiring                // Aliasă per motivazione
    }
    
    // MARK: - Typography (JetBrains Mono NL + System Fonts)
    struct Text {
        // Custom font helpers with explicit weights and system fallbacks
        private static func jetBrainsMonoRegular(size: CGFloat) -> Font {
            if UIFont(name: "JetBrains Mono NL", size: size) != nil {
                return Font.custom("JetBrains Mono NL", size: size)
            } else {
                return Font.system(size: size, weight: .regular, design: .monospaced)
            }
        }
        
        private static func jetBrainsMonoMedium(size: CGFloat) -> Font {
            if UIFont(name: "JetBrains Mono NL Medium", size: size) != nil {
                return Font.custom("JetBrains Mono NL Medium", size: size)
            } else {
                return Font.system(size: size, weight: .medium, design: .monospaced)
            }
        }
        
        private static func jetBrainsMonoSemiBold(size: CGFloat) -> Font {
            if UIFont(name: "JetBrains Mono NL SemiBold", size: size) != nil {
                return Font.custom("JetBrains Mono NL SemiBold", size: size)
            } else {
                return Font.system(size: size, weight: .semibold, design: .monospaced)
            }
        }
        
        private static func jetBrainsMonoBold(size: CGFloat) -> Font {
            if UIFont(name: "JetBrains Mono NL Bold", size: size) != nil {
                return Font.custom("JetBrains Mono NL Bold", size: size)
            } else {
                return Font.system(size: size, weight: .bold, design: .monospaced)
            }
        }
        
        // Large text - All JetBrains Mono
        static let largeTitle = jetBrainsMonoBold(size: 28)
        static let display = jetBrainsMonoBold(size: 34)
        
        // Titles - All JetBrains Mono
        static let title = jetBrainsMonoSemiBold(size: 22)
        static let title2 = jetBrainsMonoSemiBold(size: 20)
        static let title3 = jetBrainsMonoSemiBold(size: 18)
        
        // Headlines - All JetBrains Mono
        static let headline = jetBrainsMonoMedium(size: 17)
        static let subheadline = jetBrainsMonoMedium(size: 15)
        
        // Body text - All JetBrains Mono
        static let body = jetBrainsMonoRegular(size: 17)
        static let bodyBold = jetBrainsMonoSemiBold(size: 17)
        static let bodyMono = jetBrainsMonoRegular(size: 17)
        static let callout = jetBrainsMonoRegular(size: 16)
        
        // Captions - All JetBrains Mono
        static let caption = jetBrainsMonoRegular(size: 12)
        static let caption2 = jetBrainsMonoRegular(size: 11)
        static let captionMono = jetBrainsMonoRegular(size: 12)
        static let footnote = jetBrainsMonoRegular(size: 13)
        
        // Special - All JetBrains Mono
        static let small = jetBrainsMonoRegular(size: 12)
        static let micro = jetBrainsMonoRegular(size: 11)
        static let code = jetBrainsMonoRegular(size: 14)
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

    // MARK: - Adaptive Sizes (responsive to device/screen size)
    struct AdaptiveSize {
        private static let deviceSize: CGRect = UIScreen.main.bounds

        // Dynamic corner radius based on device - larger devices get larger radii
        static var cardRadius: CGFloat {
            #if os(macOS)
                return max(16, min(deviceSize.width * 0.02, 24))
            #else
                return max(12, min(deviceSize.width * 0.02, 16))
            #endif
        }

        static var cardRadiusSmall: CGFloat {
            return cardRadius * 0.75
        }

        static var buttonRadius: CGFloat {
            return cardRadius * 0.75
        }

        static var buttonRadiusSmall: CGFloat {
            return buttonRadius * 0.75
        }

        static var tagRadius: CGFloat {
            #if os(macOS)
                return 8
            #else
                return 6
            #endif
        }

        // Dynamic button heights - iPad gets taller buttons
        static var buttonHeight: CGFloat {
            #if os(macOS)
                return 52
            #elseif targetEnvironment(macCatalyst)
                return 50
            #else
                return deviceSize.height > 896 ? 52 : 48 // Larger iPhones get taller buttons
            #endif
        }

        static var buttonHeightSmall: CGFloat {
            return buttonHeight * 0.75
        }

        static var buttonHeightLarge: CGFloat {
            return buttonHeight * 1.25
        }

        // Dynamic FAB size
        static var fabSize: CGFloat {
            return deviceSize.width > 768 ? 64 : 56 // iPad gets larger FAB
        }

        // Chart heights - iPad gets taller charts
        static var chartHeight: CGFloat {
            return deviceSize.width > 768 ? 320 : 250
        }

        static var chartHeightSmall: CGFloat {
            return chartHeight * 0.6
        }
    }

    // MARK: - Adaptive Spacing (responsive to device/screen size)
    struct AdaptiveSpace {
        private static let deviceSize: CGRect = UIScreen.main.bounds
        private static let baseSpacing: CGFloat = 8

        private static var scaleFactor: CGFloat {
            #if os(macOS)
                return 1.2
            #elseif targetEnvironment(macCatalyst)
                return 1.1
            #else
                return deviceSize.width > 768 ? 1.2 : 1.0 // iPad gets more spacious
            #endif
        }

        static var xxs: CGFloat { baseSpacing * 0.25 * scaleFactor }
        static var xs: CGFloat { baseSpacing * 0.5 * scaleFactor }
        static var sm: CGFloat { baseSpacing * scaleFactor }
        static var md: CGFloat { baseSpacing * 2 * scaleFactor }
        static var lg: CGFloat { baseSpacing * 3 * scaleFactor }
        static var xl: CGFloat { baseSpacing * 4 * scaleFactor }
        static var xxl: CGFloat { baseSpacing * 6 * scaleFactor }
        static var xxxl: CGFloat { baseSpacing * 8 * scaleFactor }
        static var xxxxl: CGFloat { baseSpacing * 10 * scaleFactor }
    }

    // MARK: - Adaptive Shadows (responsive to device/screen appearance)
    struct AdaptiveShadow {
        private static var isDarkMode: Bool {
            UITraitCollection.current.userInterfaceStyle == .dark
        }

        static var small: DSShadow {
            DSShadow(
                color: Color.black.opacity(isDarkMode ? 0.25 : 0.05),
                radius: 2,
                x: 0,
                y: 1
            )
        }

        static var medium: DSShadow {
            DSShadow(
                color: Color.black.opacity(isDarkMode ? 0.3 : 0.1),
                radius: 8,
                x: 0,
                y: 4
            )
        }

        static var large: DSShadow {
            DSShadow(
                color: Color.black.opacity(isDarkMode ? 0.35 : 0.15),
                radius: 16,
                x: 0,
                y: 8
            )
        }

        static var glass: DSShadow {
            DSShadow(
                color: Color.black.opacity(isDarkMode ? 0.4 : 0.1),
                radius: 20,
                x: 0,
                y: 8
            )
        }
    }

    // MARK: - Device/Plaform Detection
    struct Platform {
        static var current: String {
            #if os(iOS)
                return "iOS"
            #elseif os(macOS)
                return "macOS"
            #elseif os(watchOS)
                return "watchOS"
            #elseif os(tvOS)
                return "tvOS"
            #else
                return "unknown"
            #endif
        }

        static var isLargeScreen: Bool {
            return UIScreen.main.bounds.width > 768
        }

        static var hasNotch: Bool {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first else {
                return false
            }
            return window.safeAreaInsets.top > 20
        }
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
        
        // Liquid Glass Shadows
        static let glass = DSShadow(
            color: Color.black.opacity(0.1),
            radius: 20,
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
        
        // Liquid Glass Animations
        static var glass: SwiftUI.Animation {
            UIAccessibility.isReduceMotionEnabled ? 
                .linear(duration: 0.1) : .interactiveSpring(response: 0.4, dampingFraction: 0.7, blendDuration: 0.2)
        }
    }
}

// MARK: - Shadow Helper
struct DSShadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
    
    
    // Use View.dsShadow(_:) extension instead
}

// MARK: - View Extensions
extension View {
    func dsShadow(_ shadow: DSShadow) -> some View {
        self.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
    
    func dsAdaptiveShadow(_ shadow: DSShadow) -> some View {
        self.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
    
    func dsCard() -> some View {
        self
            .background(DS.Colors.card)
            .cornerRadius(DS.AdaptiveSize.cardRadius)
            .dsAdaptiveShadow(DS.AdaptiveShadow.small)
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
    
    // Liquid Glass Extensions
    func liquidGlassBackground(backgroundColor: Color = DS.Colors.glassPrimary, borderColor: Color = DS.Colors.glassQuaternary) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: DS.Size.cardRadius)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: DS.Size.cardRadius)
                            .stroke(borderColor, lineWidth: 0.5)
                    )
                    .blur(radius: 0.5)
            )
            .background(
                VisualEffectView { _ in }
                .mask(
                    RoundedRectangle(cornerRadius: DS.Size.cardRadius)
                )
                .blur(radius: 10)
            )
    }
    
    func liquidGlassButtonBackground(backgroundColor: Color = DS.Colors.glassPrimary, borderColor: Color = DS.Colors.glassQuaternary) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: DS.Size.buttonRadius)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: DS.Size.buttonRadius)
                            .stroke(borderColor, lineWidth: 0.5)
                    )
                    .blur(radius: 0.5)
            )
    }
    
    func liquidGlassCard(elevation: DSShadow = DS.Shadow.glass) -> some View {
        self
            .liquidGlassBackground()
            .dsShadow(elevation)
    }
}

// MARK: - Dynamic Color Functions (Smoking Cessation Oriented Color Logic)
extension DS.Colors {

    // MARK: - Smart Cigarette Progress Color Logic
    // Returns appropriate color based on cigarette count vs target
    // ORIENTAZIONE POSITIVA: Basso consumo = verde (buono), alto consumo = rosso (critico)

    /**
     Calculates color based on smoking consumption level relative to target

     Better performance = greener colors (excellent, good)
     Worse performance = redder colors (critical, high)

     - Parameters:
       - cigaretteCount: Number of cigarettes consumed today
       - dailyTarget: Target cigarettes for the day
     - Returns: Appropriate semantic color for the consumption level
     */
    static func smokingProgressColor(cigaretteCount: Int, dailyTarget: Int) -> Color {
        guard dailyTarget > 0 else { return smokingProgressCritical }

        let percentage = Double(cigaretteCount) / Double(dailyTarget)

        switch percentage {
        case 0.0..<0.1: return smokingProgressExcellent    // 0-9% target = eccellente
        case 0.1..<0.2: return smokingProgressGood         // 10-19% target = buono
        case 0.2..<0.4: return smokingProgressModerate     // 20-39% target = moderato
        case 0.4..<0.6: return smokingProgressCaution      // 40-59% target = cautela
        case 0.6..<0.8: return smokingProgressWarning      // 60-79% target = attenzione
        case 0.8..<1.0: return smokingProgressHigh         // 80-99% target = alto rischio
        case 1.0...: return smokingProgressCritical        // 100%+ = critico
        default: return smokingProgressGood
        }
    }

    /**
     Determines performance level based on cigarette consumption vs target

     - Parameters:
       - cigaretteCount: Cigarettes consumed today
       - dailyTarget: Daily cigarette target
     - Returns: Performance level enum for UI state logic
     */
    static func smokingPerformanceLevel(cigaretteCount: Int, dailyTarget: Int) -> SmokingPerformanceLevel {
        guard dailyTarget > 0 else { return .critical }

        let percentage = Double(cigaretteCount) / Double(dailyTarget)

        switch percentage {
        case 0.0..<0.1: return .excellent
        case 0.1..<0.2: return .good
        case 0.2..<0.4: return .moderate
        case 0.4..<0.6: return .caution
        case 0.6..<0.8: return .warning
        case 0.8..<1.0: return .high
        case 1.0...: return .critical
        default: return .good
        }
    }

    // MARK: - Comparison Colors (Today's vs Previous Day)
    /**
     Color for comparing today's cigarettes vs yesterday's

     - Parameters:
       - todayCount: Today's cigarette count
       - yesterdayCount: Yesterday's cigarette count
     - Returns: Success color if improved, warning if worse, neutral if same
     */
    static func comparisonColor(current: Int, previous: Int) -> Color {
        if current < previous {
            return smokingProgressExcellent   // Improvement = green
        } else if current > previous {
            return smokingProgressHigh        // Worse = red
        } else {
            return textSecondary              // Same = neutral gray
        }
    }

    // MARK: - Trend Analysis Colors
    /**
     Color for trend confidence level (for ML predictions)

     - Parameter confidence: ML confidence score (0.0 to 1.0)
     - Returns: Color representing confidence level
     */
    static func trendConfidenceColor(confidence: Double) -> Color {
        switch confidence {
        case 0.8...: return smokingProgressExcellent
        case 0.6..<0.8: return smokingProgressGood
        case 0.4..<0.6: return smokingProgressCaution
        case 0.2..<0.4: return smokingProgressWarning
        default: return smokingProgressCritical
        }
    }

    // MARK: - Achievement Colors
    /**
     Color for achievement unlocking

     - Parameter achievementType: Type of achievement
     - Returns: Appropriate color for achievement type
     */
    static func achievementColor(for type: AchievementType) -> Color {
        switch type {
        case .perfectDay: return achievementPerfectDay
        case .quotaMet: return achievementQuotaMet
        case .streak: return motivationInspiring
        case .healthImprovement: return healthImprovementExcellent
        case .savings: return smokingProgressCaution // Yellow for money
        }
    }

    // MARK: - Contextual Colors for Smoking Situations
    /**
     Color for smoking contextual situations

     - Parameter situation: Context of smoking occurrence
     - Returns: Contextual color for the situation
     */
    static func contextualColor(for situation: SmokingContext) -> Color {
        switch situation {
        case .work: return tagWork           // Purple for work stress
        case .stress: return habitTrigger     // Orange for habit triggers
        case .social: return tagSocial        // Cyan for social situations
        case .alone: return motivationInspiring // Violet for personal reflection
        case .morning: return smokingProgressCaution // Yellow for morning routine
        case .evening: return smokingProgressModerate // Lime for evening wind-down
        }
    }
}

// MARK: - Performance Level Enum
enum SmokingPerformanceLevel: String {
    case excellent = "excellent"     // 0-9% of target
    case good = "good"               // 10-19% of target
    case moderate = "moderate"       // 20-39% of target
    case caution = "caution"         // 40-59% of target
    case warning = "warning"         // 60-79% of target
    case high = "high"               // 80-99% of target
    case critical = "critical"       // 100%+ of target

    var color: Color {
        switch self {
        case .excellent: return DS.Colors.smokingProgressExcellent
        case .good: return DS.Colors.smokingProgressGood
        case .moderate: return DS.Colors.smokingProgressModerate
        case .caution: return DS.Colors.smokingProgressCaution
        case .warning: return DS.Colors.smokingProgressWarning
        case .high: return DS.Colors.smokingProgressHigh
        case .critical: return DS.Colors.smokingProgressCritical
        }
    }

    var motivationalMessage: String {
        switch self {
        case .excellent: return "You're crushing it today! 🎉"
        case .good: return "Great progress so far! Keep it up!"
        case .moderate: return "You're doing well, stay focused"
        case .caution: return "Be mindful of your progress"
        case .warning: return "Consider your coping strategies"
        case .high: return "You might want to reset for tomorrow"
        case .critical: return "Let's work on better choices tomorrow"
        }
    }
}

// MARK: - Enum Definitions
enum AchievementType {
    case perfectDay       // 0 cigarettes in a day
    case quotaMet         // Met daily target
    case streak          // Maintained abstinence streak
    case healthImprovement // Health metrics improvement
    case savings         // Saved money milestone
}

enum SmokingContext {
    case work, stress, social, alone, morning, evening
}

// MARK: - Convenience View Extensions for Smoking Cessation UI
extension View {

    // MARK: - Cigarette Progress Styling
    func cigaretteCountStyle(cigaretteCount: Int, dailyTarget: Int) -> some View {
        self
            .foregroundColor(DS.Colors.smokingProgressColor(cigaretteCount: cigaretteCount, dailyTarget: dailyTarget))
            .font(DS.Text.display)
            .fontWeight(.bold)
    }

    func cigaretteCardStyle(cigaretteCount: Int, dailyTarget: Int) -> some View {
        self
            .padding(DS.Space.lg)
            .liquidGlassCard(elevation: DS.Shadow.medium)
            .overlay(
                RoundedRectangle(cornerRadius: DS.Size.cardRadius)
                    .strokeBorder(
                        DS.Colors.smokingProgressColor(cigaretteCount: cigaretteCount, dailyTarget: dailyTarget).opacity(0.3),
                        lineWidth: cigaretteCount > dailyTarget ? 2 : 0
                    )
            )
    }

    // MARK: - Motivational Styling
    func motivationalStyle(level: SmokingPerformanceLevel) -> some View {
        self
            .foregroundColor(level.color)
            .font(DS.Text.bodyBold)
    }

    func motivationalBadge(level: SmokingPerformanceLevel) -> some View {
        self
            .padding(.horizontal, DS.Space.sm)
            .padding(.vertical, DS.Space.xs)
            .background(level.color.opacity(0.15))
            .foregroundColor(level.color)
            .cornerRadius(DS.Size.tagRadius)
            .font(DS.Text.caption)
    }

    // MARK: - Comparison Styling
    func comparisonArrow(current: Int, previous: Int) -> some View {
        HStack(spacing: DS.Space.xs) {
            Image(systemName: current < previous ? "arrow.down" :
                           current > previous ? "arrow.up" : "minus")
                .font(.caption.bold())
            self
        }
        .foregroundColor(DS.Colors.comparisonColor(current: current, previous: previous))
    }

    // MARK: - Achievement Styling
    func achievementStyle(type: AchievementType) -> some View {
        self
            .foregroundColor(DS.Colors.achievementColor(for: type))
            .font(DS.Text.title3)
            .padding(DS.Space.md)
            .liquidGlassCard(elevation: DS.Shadow.medium)
    }

    // MARK: - Contextual Tag Styling
    func smokingContextStyle(context: SmokingContext) -> some View {
        self
            .padding(.horizontal, DS.Space.sm)
            .padding(.vertical, DS.Space.xs)
            .background(DS.Colors.contextualColor(for: context).opacity(0.15))
            .foregroundColor(DS.Colors.contextualColor(for: context))
            .cornerRadius(DS.Size.tagRadius)
            .font(DS.Text.caption)
    }
}


// MARK: - Visual Effect View for Liquid Glass
struct VisualEffectView<Content: View>: UIViewRepresentable {
    var content: (UIVisualEffectView) -> Content

    init(@ViewBuilder content: @escaping (UIVisualEffectView) -> Content) {
        self.content = content
    }

    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView()
        view.effect = UIBlurEffect(style: .systemUltraThinMaterial)
        return view
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        // Update if needed
    }
}
