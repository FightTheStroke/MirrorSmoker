//
//  HealthBenefitsChart.swift
//  MirrorSmokerStopper
//
//  Created by Assistant on 03/09/25.
//

import SwiftUI
import Charts

// MARK: - Health Benefit Models
struct HealthBenefit: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let category: HealthCategory
    let timeFrame: TimeFrame
    let improvementPercentage: Double
    let icon: String
    let achievedDate: Date?
    
    var isAchieved: Bool {
        achievedDate != nil
    }
    
    var progressColor: Color {
        switch improvementPercentage {
        case 0..<0.2: return DS.Colors.smokingProgressHigh
        case 0.2..<0.4: return DS.Colors.smokingProgressCaution
        case 0.4..<0.6: return DS.Colors.smokingProgressModerate
        case 0.6..<0.8: return DS.Colors.smokingProgressGood
        default: return DS.Colors.smokingProgressExcellent
        }
    }
}

enum HealthCategory: String, CaseIterable {
    case cardiovascular = "cardiovascular"
    case respiratory = "respiratory"
    case circulation = "circulation"
    case energy = "energy"
    case immune = "immune"
    case appearance = "appearance"
    
    var displayName: String {
        "health.category.\(rawValue)".local()
    }
    
    var icon: String {
        switch self {
        case .cardiovascular: return "heart.fill"
        case .respiratory: return "lungs.fill"
        case .circulation: return "drop.circle.fill"
        case .energy: return "bolt.fill"
        case .immune: return "shield.fill"
        case .appearance: return "sparkles"
        }
    }
    
    var color: Color {
        switch self {
        case .cardiovascular: return DS.Colors.smokingProgressHigh
        case .respiratory: return DS.Colors.tagSocial
        case .circulation: return DS.Colors.primary
        case .energy: return DS.Colors.smokingProgressCaution
        case .immune: return DS.Colors.smokingProgressGood
        case .appearance: return DS.Colors.motivationInspiring
        }
    }
}

enum TimeFrame: String, CaseIterable {
    case minutes20 = "20_minutes"
    case hours8 = "8_hours"
    case hours24 = "24_hours"
    case days3 = "3_days"
    case weeks2 = "2_weeks"
    case months1 = "1_month"
    case months3 = "3_months"
    case year1 = "1_year"
    
    var displayName: String {
        "health.timeframe.\(rawValue)".local()
    }
    
    var sortOrder: Int {
        switch self {
        case .minutes20: return 1
        case .hours8: return 2
        case .hours24: return 3
        case .days3: return 4
        case .weeks2: return 5
        case .months1: return 6
        case .months3: return 7
        case .year1: return 8
        }
    }
    
    var durationInMinutes: Int {
        switch self {
        case .minutes20: return 20
        case .hours8: return 8 * 60
        case .hours24: return 24 * 60
        case .days3: return 3 * 24 * 60
        case .weeks2: return 14 * 24 * 60
        case .months1: return 30 * 24 * 60
        case .months3: return 90 * 24 * 60
        case .year1: return 365 * 24 * 60
        }
    }
}

// MARK: - Health Benefit View
struct HealthBenefitView: View {
    let benefit: HealthBenefit
    @State private var animateProgress = false
    
    var body: some View {
        HStack(spacing: DS.AdaptiveSpace.md) {
            // Icon and progress ring
            ZStack {
                // Background ring
                Circle()
                    .stroke(DS.Colors.glassTertiary, lineWidth: 3)
                    .frame(width: 50, height: 50)
                
                // Progress ring
                Circle()
                    .trim(from: 0, to: animateProgress ? benefit.improvementPercentage : 0)
                    .stroke(
                        benefit.progressColor,
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(-90))
                    .animation(DS.Animation.spring.delay(0.3), value: animateProgress)
                
                // Icon
                Image(systemName: benefit.icon)
                    .font(.system(size: 20))
                    .foregroundColor(benefit.category.color)
            }
            
            // Content
            VStack(alignment: .leading, spacing: DS.AdaptiveSpace.xs) {
                HStack {
                    Text(benefit.title.local())
                        .font(DS.Text.headline)
                        .foregroundColor(DS.Colors.textPrimary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    // Achievement badge
                    if benefit.isAchieved {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(DS.Colors.smokingProgressExcellent)
                    } else {
                        Text(benefit.timeFrame.displayName)
                            .font(DS.Text.caption2)
                            .foregroundColor(DS.Colors.textTertiary)
                            .padding(.horizontal, DS.AdaptiveSpace.xs)
                            .padding(.vertical, 2)
                            .background(DS.Colors.glassTertiary)
                            .clipShape(Capsule())
                    }
                }
                
                Text(benefit.description.local())
                    .font(DS.Text.body)
                    .foregroundColor(DS.Colors.textSecondary)
                    .lineLimit(2)
                
                // Progress percentage
                Text(String(format: "health.improvement.percent".local(), Int(benefit.improvementPercentage * 100)))
                    .font(DS.Text.captionMono)
                    .foregroundColor(benefit.progressColor)
            }
            
            Spacer()
        }
        .padding(DS.AdaptiveSpace.md)
        .background(DS.Colors.glassPrimary)
        .clipShape(RoundedRectangle(cornerRadius: DS.AdaptiveSize.cardRadiusSmall))
        .onAppear {
            withAnimation(DS.Animation.spring.delay(0.2)) {
                animateProgress = true
            }
        }
    }
}

// MARK: - Health Benefits Chart
struct HealthBenefitsChart: View {
    let healthBenefits: [HealthBenefit]
    @State private var selectedCategory: HealthCategory? = nil
    @State private var selectedTimeframe: HealthTimeRange = .month
    
    enum HealthTimeRange: String, CaseIterable {
        case week = "week"
        case month = "month"
        case threeMonths = "three_months"
        case year = "year"
        
        var displayName: String {
            "health.range.\(rawValue)".local()
        }
    }
    
    var filteredBenefits: [HealthBenefit] {
        let filtered = selectedCategory == nil ? 
            healthBenefits : 
            healthBenefits.filter { $0.category == selectedCategory }
        
        // Filter by timeframe if needed
        return filtered.sorted { $0.timeFrame.sortOrder < $1.timeFrame.sortOrder }
    }
    
    var body: some View {
        VStack(spacing: DS.AdaptiveSpace.lg) {
            // Header with category filter
            VStack(spacing: DS.AdaptiveSpace.md) {
                HStack {
                    Text("health.benefits".local())
                        .font(DS.Text.title2)
                        .foregroundColor(DS.Colors.textPrimary)
                    
                    Spacer()
                    
                    // Time range picker
                    Picker("", selection: $selectedTimeframe) {
                        ForEach(HealthTimeRange.allCases, id: \.self) { range in
                            Text(range.displayName).tag(range)
                        }
                    }
                    .pickerStyle(.segmented)
                    .scaleEffect(0.8)
                    .frame(width: 200)
                }
                
                // Category filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DS.AdaptiveSpace.sm) {
                        CategoryFilterButton(
                            title: "health.all.categories".local(),
                            isSelected: selectedCategory == nil
                        ) {
                            selectedCategory = nil
                        }
                        
                        ForEach(HealthCategory.allCases, id: \.self) { category in
                            CategoryFilterButton(
                                title: category.displayName,
                                icon: category.icon,
                                color: category.color,
                                isSelected: selectedCategory == category
                            ) {
                                selectedCategory = selectedCategory == category ? nil : category
                            }
                        }
                    }
                    .padding(.horizontal, DS.AdaptiveSpace.md)
                }
            }
            
            // Benefits list
            if filteredBenefits.isEmpty {
                EmptyHealthBenefitsView()
            } else {
                ScrollView {
                    LazyVStack(spacing: DS.AdaptiveSpace.sm) {
                        ForEach(filteredBenefits) { benefit in
                            HealthBenefitView(benefit: benefit)
                        }
                    }
                }
            }
            
            // Progress summary chart
            if !filteredBenefits.isEmpty {
                HealthProgressSummaryChart(benefits: filteredBenefits)
            }
        }
        .padding(DS.AdaptiveSpace.lg)
        .liquidGlassCard(elevation: DS.Shadow.medium)
    }
}

// MARK: - Category Filter Button
struct CategoryFilterButton: View {
    let title: String
    let icon: String?
    let color: Color?
    let isSelected: Bool
    let action: () -> Void
    
    init(title: String, icon: String? = nil, color: Color? = nil, isSelected: Bool, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.color = color
        self.isSelected = isSelected
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DS.AdaptiveSpace.xs) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.caption)
                }
                Text(title)
                    .font(DS.Text.caption)
            }
            .padding(.horizontal, DS.AdaptiveSpace.sm)
            .padding(.vertical, DS.AdaptiveSpace.xs)
            .background(
                isSelected ? (color ?? DS.Colors.primary) : DS.Colors.glassTertiary
            )
            .foregroundColor(
                isSelected ? DS.Colors.textInverse : DS.Colors.textSecondary
            )
            .clipShape(Capsule())
        }
        .animation(DS.Animation.fast, value: isSelected)
    }
}

// MARK: - Health Progress Summary Chart
struct HealthProgressSummaryChart: View {
    let benefits: [HealthBenefit]
    
    private var chartData: [ChartDataPoint] {
        HealthCategory.allCases.compactMap { category in
            let categoryBenefits = benefits.filter { $0.category == category }
            guard !categoryBenefits.isEmpty else { return nil }
            
            let averageProgress = categoryBenefits.reduce(0) { $0 + $1.improvementPercentage } / Double(categoryBenefits.count)
            
            return ChartDataPoint(
                category: category.displayName,
                value: averageProgress * 100,
                color: category.color
            )
        }
    }
    
    struct ChartDataPoint: Identifiable {
        let id = UUID()
        let category: String
        let value: Double
        let color: Color
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.AdaptiveSpace.md) {
            Text("health.progress.summary".local())
                .font(DS.Text.headline)
                .foregroundColor(DS.Colors.textPrimary)
            
            Chart(chartData) { dataPoint in
                BarMark(
                    x: .value("Category", dataPoint.category),
                    y: .value("Progress", dataPoint.value)
                )
                .foregroundStyle(dataPoint.color.gradient)
                .cornerRadius(4)
            }
            .frame(height: 120)
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisValueLabel {
                        if let intValue = value.as(Double.self) {
                            Text("\(Int(intValue))%")
                                .font(DS.Text.caption2)
                                .foregroundColor(DS.Colors.textTertiary)
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks { value in
                    AxisValueLabel {
                        if let stringValue = value.as(String.self) {
                            Text(stringValue)
                                .font(DS.Text.caption2)
                                .foregroundColor(DS.Colors.textTertiary)
                                .lineLimit(1)
                        }
                    }
                }
            }
        }
        .padding(DS.AdaptiveSpace.md)
        .background(DS.Colors.glassPrimary)
        .clipShape(RoundedRectangle(cornerRadius: DS.AdaptiveSize.cardRadiusSmall))
    }
}

// MARK: - Empty Health Benefits View
struct EmptyHealthBenefitsView: View {
    var body: some View {
        VStack(spacing: DS.AdaptiveSpace.lg) {
            Image(systemName: "heart.text.square")
                .font(.system(size: 48))
                .foregroundColor(DS.Colors.textTertiary)
            
            VStack(spacing: DS.AdaptiveSpace.sm) {
                Text("health.benefits.empty.title".local())
                    .font(DS.Text.headline)
                    .foregroundColor(DS.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text("health.benefits.empty.subtitle".local())
                    .font(DS.Text.body)
                    .foregroundColor(DS.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview
#Preview {
    ScrollView {
        HealthBenefitsChart(healthBenefits: [
            HealthBenefit(
                title: "health.benefit.heart.rate",
                description: "health.benefit.heart.rate.desc",
                category: .cardiovascular,
                timeFrame: .minutes20,
                improvementPercentage: 0.8,
                icon: "heart.fill",
                achievedDate: Date().addingTimeInterval(-3600)
            ),
            HealthBenefit(
                title: "health.benefit.oxygen.level",
                description: "health.benefit.oxygen.level.desc",
                category: .respiratory,
                timeFrame: .hours8,
                improvementPercentage: 0.6,
                icon: "lungs.fill",
                achievedDate: Date().addingTimeInterval(-7200)
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
                achievedDate: Date().addingTimeInterval(-259200)
            )
        ])
    }
    .background(DS.Colors.backgroundSecondary)
    .padding()
}