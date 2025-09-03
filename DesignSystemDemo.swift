//
//  DesignSystemDemo.swift
//  Mostra l'utilito del nuovo Design System orientato alla cessazione fumo
//

import SwiftUI

struct DesignSystemSmartColorsDemoView: View {
    // Simula diversi livelli di consumo sigarette vs target
    @State private var cigaretteCounts = [0, 1, 2, 5, 8, 10, 12, 15, 20, 25]
    @State private var selectedIndex = 4  // Default selezionato il livello "attenzione"
    let dailyTarget = 10

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header con spiegazione
                VStack(spacing: 16) {
                    Text("🎨 Nuovo Design System\nOrientato Cessazione Fumo")
                        .font(DS.Text.largeTitle)
                        .multilineTextAlignment(.center)
                        .foregroundColor(DS.Colors.textPrimary)

                    Text("I colori cambiano intelligentemente basato sul consumo sigarette vs obiettivo giornaliero")
                        .font(DS.Text.callout)
                        .foregroundColor(DS.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                // Demo interattiva: Selezione numero sigarette
                VStack(spacing: 20) {
                    Text("Seleziona il tuo consumo oggi")
                        .font(DS.Text.title2)
                        .foregroundColor(DS.Colors.primary)

                    HStack(spacing: 12) {
                        ForEach(cigaretteCounts.prefix(6), id: \.self) { count in
                            Button(action: {
                                selectedIndex = cigaretteCounts.firstIndex(of: count) ?? 0
                            }) {
                                Text("\(count)")
                                    .font(DS.Text.title2)
                                    .foregroundColor(selectedIndex == cigaretteCounts.firstIndex(of: count) ? .white : DS.Colors.textSecondary)
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 16)
                                    .background(
                                        selectedIndex == cigaretteCounts.firstIndex(of: count) ?
                                        DS.Colors.smokingProgressColor(cigaretteCount: count, dailyTarget: dailyTarget) :
                                        DS.Colors.card
                                    )
                                    .cornerRadius(DS.AdaptiveSize.buttonRadius)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: DS.AdaptiveSize.buttonRadius)
                                            .stroke(selectedIndex == cigaretteCounts.firstIndex(of: count) ? Color.clear : DS.Colors.separator, lineWidth: 1)
                                    )
                            }
                        }
                    }

                    Text("Obiettivo giornaliero: \(dailyTarget) sigarette")
                        .font(DS.Text.caption)
                        .foregroundColor(DS.Colors.textSecondary)
                }
                .padding(.horizontal)
                .padding(.vertical, 24)
                .liquidGlassCard()

                // Visualizzazione colore intelligente
                let currentCount = cigaretteCounts[selectedIndex]
                let performanceLevel = DS.Colors.smokingPerformanceLevel(cigaretteCount: currentCount, dailyTarget: dailyTarget)

                VStack(spacing: DS.Space.lg) {
                    Text("Colore dinamico calcolato:")
                        .font(DS.Text.headline)
                        .foregroundColor(DS.Colors.textPrimary)

                    // Main color display
                    HStack(spacing: DS.Space.lg) {
                        ZStack {
                            Circle()
                                .fill(performanceLevel.color)
                                .frame(width: 80, height: 80)
                                .shadow(color: performanceLevel.color.opacity(0.3), radius: 8)

                            Text("\(currentCount)")
                                .font(DS.Text.display)
                                .foregroundColor(.white)
                        }

                        VStack(alignment: .leading, spacing: DS.Space.sm) {
                            Text(performanceLevel.rawValue.uppercased())
                                .font(DS.Text.title)
                                .foregroundColor(performanceLevel.color)

                            Text("Questo colore si aggiorna automaticamente basato sul tuo progresso vs obiettivo!")
                                .font(DS.Text.caption)
                                .foregroundColor(DS.Colors.textSecondary)
                                .lineLimit(3)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    // Motivational message
                    Text(performanceLevel.motivationalMessage)
                        .font(DS.Text.body)
                        .foregroundColor(performanceLevel.color)
                        .padding()
                        .liquidGlassBackground()
                        .multilineTextAlignment(.center)
                }
                .padding()
                .liquidGlassCard()

                // Comparison demo
                VStack(spacing: DS.Space.md) {
                    Text("Confronto con ieri")
                        .font(DS.Text.title2)
                        .foregroundColor(DS.Colors.primary)

                    HStack(spacing: DS.Space.lg) {
                        comparisonCard(day: "Ieri", count: 12)
                        Image(systemName: "arrow.right")
                            .foregroundColor(DS.Colors.primary)
                        comparisonCard(day: "Oggi", count: currentCount)
                    }

                    let diff = currentCount - 12
                    HStack(spacing: DS.Space.xs) {
                        Image(systemName: diff <= 0 ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                        Text("Cambiamento: \(abs(diff)) sigarette")
                    }
                    .foregroundColor(DS.Colors.comparisonColor(current: currentCount, previous: 12))
                    .font(DS.Text.calloutBold)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(
                        DS.Colors.comparisonColor(current: currentCount, previous: 12).opacity(0.1)
                    )
                    .cornerRadius(DS.AdaptiveSize.buttonRadius)
                }
                .padding()
                .liquidGlassCard()

                // Achievement demo
                VStack(spacing: DS.Space.md) {
                    Text("Sistema Achievement")
                        .font(DS.Text.title2)
                        .foregroundColor(DS.Colors.primary)

                    HStack(spacing: DS.Space.md) {
                        achievementCard(type: .perfectDay, isUnlocked: currentCount == 0)
                        achievementCard(type: .quotaMet, isUnlocked: currentCount <= dailyTarget)
                        achievementCard(type: .streak, isUnlocked: performanceLevel == .excellent)
                    }
                }
                .padding()
                .liquidGlassCard()

                // Contextual tags demo
                VStack(spacing: DS.Space.md) {
                    Text("Tags Situazionali")
                        .font(DS.Text.title2)
                        .foregroundColor(DS.Colors.primary)

                    HStack(spacing: DS.Space.sm) {
                        Text("Lavoro")
                            .smokingContextStyle(context: .work)
                        Text("Stress")
                            .smokingContextStyle(context: .stress)
                        Text("Sociale")
                            .smokingContextStyle(context: .social)
                        Text("Mattina")
                            .smokingContextStyle(context: .morning)
                    }
                }
                .padding()
                .liquidGlassCard()

                Spacer(minLength: DS.AdaptiveSpace.xxl)
            }
            .padding()
        }
        .background(DS.Colors.background.edgesIgnoringSafeArea(.all))
    }

    private func comparisonCard(day: String, count: Int) -> some View {
        VStack(spacing: DS.Space.sm) {
            Text(day)
                .font(DS.Text.caption)
                .foregroundColor(DS.Colors.textSecondary)
            Text("\(count)")
                .font(DS.Text.title)
                .foregroundColor(DS.Colors.smokingProgressColor(cigaretteCount: count, dailyTarget: dailyTarget))
            Text("sigarette")
                .font(DS.Text.micro)
                .foregroundColor(DS.Colors.textSecondary)
        }
        .padding()
        .liquidGlassBackground()
    }

    private func achievementCard(type: AchievementType, isUnlocked: Bool) -> some View {
        VStack(spacing: DS.Space.xs) {
            Circle()
                .fill(isUnlocked ? DS.Colors.achievementColor(for: type) : DS.Colors.separator)
                .frame(width: 48, height: 48)
                .overlay(
                    Image(systemName: achievementIcon(for: type))
                        .foregroundColor(.white)
                        .font(.system(size: 24))
                )

            Text(achievementTitle(for: type))
                .font(DS.Text.caption)
                .foregroundColor(isUnlocked ? DS.Colors.achievementColor(for: type) : DS.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
    }

    private func achievementIcon(for type: AchievementType) -> String {
        switch type {
        case .perfectDay: return "❤️"
        case .quotaMet: return "🎯"
        case .streak: return "🔥"
        case .healthImprovement: return "💊"
        case .savings: return "💰"
        }
    }

    private func achievementTitle(for type: AchievementType) -> String {
        switch type {
        case .perfectDay: return "Giornata\nPerfetta"
        case .quotaMet: return "Obiettivo\nRaggiunto"
        case .streak: return "Serie\nPositiva"
        case .healthImprovement: return "Salute\nMigliorata"
        case .savings: return "Risparmi\nAccumulati"
        }
    }
}

// Import richiesto per Demonstrate nel Preview
import SwiftUI

#Preview {
    DesignSystemSmartColorsDemoView()
}
