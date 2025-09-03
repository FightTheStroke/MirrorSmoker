//
//  ProgressView.swift
//  MirrorSmokerStopper
//
//  Created by Assistant on 03/09/25.
//

import SwiftUI

// MARK: - Progress View
struct ProgressView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab: ProgressTab = .achievements
    @State private var milestones: [Milestone] = []
    @State private var savingsGoals: [SavingsGoal] = []
    @State private var healthBenefits: [HealthBenefit] = []
    
    enum ProgressTab: String, CaseIterable {
        case achievements = "achievements"
        case savings = "savings"
        case health = "health"
        
        var displayName: String {
            switch self {
            case .achievements: return "progress.tab.achievements".local()
            case .savings: return "progress.tab.savings".local()
            case .health: return "progress.tab.health".local()
            }
        }
        
        var icon: String {
            switch self {
            case .achievements: return "trophy.fill"
            case .savings: return "dollarsign.circle.fill"
            case .health: return "heart.fill"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab selector
                ProgressTabSelector(selectedTab: $selectedTab)
                
                // Content
                ScrollView {
                    LazyVStack(spacing: DS.AdaptiveSpace.xl) {
                        switch selectedTab {
                        case .achievements:
                            MilestoneCarousel(milestones: milestones)
                        case .savings:
                            SavingsOverview(goals: savingsGoals)
                        case .health:
                            HealthBenefitsChart(healthBenefits: healthBenefits)
                        }
                    }
                    .padding(.top, DS.AdaptiveSpace.lg)
                    .padding(.bottom, DS.AdaptiveSpace.xxxl)
                }
                .background(DS.Colors.backgroundSecondary)
            }
            .navigationTitle("progress.title".local())
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            loadProgressData()
        }
        .refreshable {
            await refreshProgressData()
        }
    }
    
    // MARK: - Data Loading
    private func loadProgressData() {
        // Load milestones (mock data for now)
        milestones = generateMockMilestones()
        
        // Load savings goals (mock data for now)
        savingsGoals = generateMockSavingsGoals()
        
        // Load health benefits (mock data for now)
        healthBenefits = generateMockHealthBenefits()
    }
    
    @MainActor
    private func refreshProgressData() async {
        // Simulate network refresh
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        loadProgressData()
    }
    
    // MARK: - Mock Data Generation
    private func generateMockMilestones() -> [Milestone] {
        let calendar = Calendar.current
        let now = Date()
        
        return [
            Milestone(
                title: "milestone.smoke.free.day",
                description: "milestone.smoke.free.day.desc",
                achievedDate: calendar.date(byAdding: .day, value: -1, to: now)!,
                icon: "heart.fill",
                category: .smokeFree,
                value: "1 day"
            ),
            Milestone(
                title: "milestone.money.saved",
                description: "milestone.money.saved.desc",
                achievedDate: calendar.date(byAdding: .day, value: -3, to: now)!,
                icon: "dollarsign.circle.fill",
                category: .savings,
                value: "€25"
            ),
            Milestone(
                title: "milestone.health.improvement",
                description: "milestone.health.improvement.desc",
                achievedDate: calendar.date(byAdding: .day, value: -7, to: now)!,
                icon: "lungs.fill",
                category: .health,
                value: "15%"
            )
        ]
    }
    
    private func generateMockSavingsGoals() -> [SavingsGoal] {
        let calendar = Calendar.current
        let now = Date()
        
        return [
            SavingsGoal(
                title: "savings.vacation.italy",
                targetAmount: 1200,
                currentAmount: 850,
                targetDate: calendar.date(byAdding: .month, value: 4, to: now),
                category: .vacation
            ),
            SavingsGoal(
                title: "savings.emergency.fund",
                targetAmount: 500,
                currentAmount: 500,
                targetDate: nil,
                category: .emergency
            ),
            SavingsGoal(
                title: "savings.new.laptop",
                targetAmount: 2500,
                currentAmount: 320,
                targetDate: calendar.date(byAdding: .month, value: 8, to: now),
                category: .gadget
            )
        ]
    }
    
    private func generateMockHealthBenefits() -> [HealthBenefit] {
        let calendar = Calendar.current
        let now = Date()
        
        return [
            HealthBenefit(
                title: "health.benefit.heart.rate",
                description: "health.benefit.heart.rate.desc",
                category: .cardiovascular,
                timeFrame: .minutes20,
                improvementPercentage: 0.8,
                icon: "heart.fill",
                achievedDate: calendar.date(byAdding: .hour, value: -1, to: now)
            ),
            HealthBenefit(
                title: "health.benefit.oxygen.level",
                description: "health.benefit.oxygen.level.desc",
                category: .respiratory,
                timeFrame: .hours8,
                improvementPercentage: 0.6,
                icon: "lungs.fill",
                achievedDate: calendar.date(byAdding: .hour, value: -2, to: now)
            ),
            HealthBenefit(
                title: "health.benefit.circulation",
                description: "health.benefit.circulation.desc",
                category: .circulation,
                timeFrame: .weeks2,
                improvementPercentage: 0.4,
                icon: "drop.circle.fill",
                achievedDate: nil
            ),
            HealthBenefit(
                title: "health.benefit.energy.level",
                description: "health.benefit.energy.level.desc",
                category: .energy,
                timeFrame: .days3,
                improvementPercentage: 0.9,
                icon: "bolt.fill",
                achievedDate: calendar.date(byAdding: .day, value: -3, to: now)
            )
        ]
    }
}

// MARK: - Progress Tab Selector
struct ProgressTabSelector: View {
    @Binding var selectedTab: ProgressView.ProgressTab
    @Namespace private var tabAnimation
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(ProgressView.ProgressTab.allCases, id: \.self) { tab in
                ProgressTabButton(
                    tab: tab,
                    isSelected: selectedTab == tab,
                    namespace: tabAnimation
                ) {
                    withAnimation(DS.Animation.spring) {
                        selectedTab = tab
                    }
                }
            }
        }
        .padding(DS.AdaptiveSpace.xs)
        .background(DS.Colors.glassTertiary)
        .clipShape(RoundedRectangle(cornerRadius: DS.AdaptiveSize.buttonRadius))
        .padding(.horizontal, DS.AdaptiveSpace.lg)
        .padding(.top, DS.AdaptiveSpace.sm)
    }
}

// MARK: - Progress Tab Button
struct ProgressTabButton: View {
    let tab: ProgressView.ProgressTab
    let isSelected: Bool
    let namespace: Namespace.ID
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DS.AdaptiveSpace.xs) {
                Image(systemName: tab.icon)
                    .font(.system(size: 16, weight: .medium))
                
                Text(tab.displayName)
                    .font(DS.Text.body)
                    .lineLimit(1)
            }
            .foregroundColor(isSelected ? DS.Colors.textInverse : DS.Colors.textSecondary)
            .padding(.horizontal, DS.AdaptiveSpace.md)
            .padding(.vertical, DS.AdaptiveSpace.sm)
            .frame(maxWidth: .infinity)
            .background(
                Group {
                    if isSelected {
                        RoundedRectangle(cornerRadius: DS.AdaptiveSize.buttonRadiusSmall)
                            .fill(DS.Colors.primary)
                            .matchedGeometryEffect(id: "selectedTab", in: namespace)
                    }
                }
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
#Preview {
    ProgressView()
}