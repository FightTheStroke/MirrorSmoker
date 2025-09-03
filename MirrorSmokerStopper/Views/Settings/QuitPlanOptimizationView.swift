//
//  QuitPlanOptimizationView.swift
//  MirrorSmokerStopper
//
//  Created by Claude on 02/09/25.
//

import SwiftUI
import SwiftData

struct QuitPlanOptimizationView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var quitPlanOptimizer = QuitPlanOptimizer.shared
    
    @Query private var userProfile: [UserProfile]
    @Query private var cigarettes: [Cigarette]
    
    @State private var isGeneratingPlan = false
    @State private var currentRecommendation: QuitPlanOptimizer.OptimizationRecommendation?
    @State private var showingRecommendationSheet = false
    @State private var showingPerformanceSheet = false
    @State private var planAdaptations: [QuitPlanOptimizer.PlanAdaptation] = []
    
    private var currentProfile: UserProfile? {
        userProfile.first
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Section
                    headerSection
                    
                    // Current Plan Overview
                    if let profile = currentProfile {
                        currentPlanSection(profile: profile)
                    }
                    
                    // AI Optimization Controls
                    optimizationControlsSection
                    
                    // Plan Performance
                    if let profile = currentProfile {
                        performanceSection(profile: profile)
                    }
                    
                    // Milestones Preview
                    if let recommendation = currentRecommendation {
                        milestonesSection(recommendation: recommendation)
                    }
                }
                .padding()
            }
        }
        .navigationTitle(NSLocalizedString("ai.quit.plan.optimizer.title", comment: ""))
        .sheet(isPresented: $showingRecommendationSheet) {
            if let recommendation = currentRecommendation {
                RecommendationDetailView(recommendation: recommendation) { accepted in
                    if accepted, let profile = currentProfile {
                        applyRecommendation(recommendation, to: profile)
                    }
                    showingRecommendationSheet = false
                }
            }
        }
        .sheet(isPresented: $showingPerformanceSheet) {
            PlanPerformanceView(adaptations: planAdaptations) { adaptation in
                // Handle adaptation selection
                showingPerformanceSheet = false
            }
        }
        .task {
            await loadCurrentRecommendation()
        }
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 40))
                .foregroundColor(.blue)
            
            Text(NSLocalizedString("ai.powered.quit.plan.optimization", comment: ""))
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text(NSLocalizedString("get.personalized.recommendations", comment: ""))
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
    
    private func currentPlanSection(profile: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(NSLocalizedString("current.plan", comment: ""))
                    .font(.headline)
                Spacer()
                
                if profile.enableGradualReduction {
                    Label(NSLocalizedString("active", comment: ""), systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                } else {
                    Label(NSLocalizedString("inactive", comment: ""), systemImage: "pause.circle.fill")
                        .foregroundColor(.orange)
                        .font(.caption)
                }
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                PlanMetricCard(
                    title: NSLocalizedString("quit.date", comment: ""),
                    value: profile.quitDate?.formatted(date: .abbreviated, time: .omitted) ?? NSLocalizedString("not.set", comment: ""),
                    icon: "calendar"
                )
                
                PlanMetricCard(
                    title: NSLocalizedString("reduction.curve", comment: ""),
                    value: profile.reductionCurve.rawValue.localizedCapitalized,
                    icon: "chart.line.downtrend.xyaxis"
                )
                
                PlanMetricCard(
                    title: NSLocalizedString("todays.target", comment: ""),
                    value: "\(profile.todayTarget(dailyAverage: profile.dailyAverage))",
                    icon: "target"
                )
                
                PlanMetricCard(
                    title: NSLocalizedString("daily.average", comment: ""),
                    value: String(format: "%.1f", profile.dailyAverage),
                    icon: "chart.bar"
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var optimizationControlsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text(NSLocalizedString("ai.optimization", comment: ""))
                    .font(.headline)
                Spacer()
            }
            
            VStack(spacing: 12) {
                Button(action: {
                    Task {
                        await generateOptimizedPlan()
                    }
                }) {
                    HStack {
                        Image(systemName: "wand.and.rays")
                        Text(NSLocalizedString("generate.optimized.plan", comment: ""))
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(isGeneratingPlan || currentProfile == nil)
                
                Button(action: {
                    Task {
                        await evaluateCurrentPlan()
                    }
                }) {
                    HStack {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                        Text(NSLocalizedString("evaluate.current.performance", comment: ""))
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(isGeneratingPlan || currentProfile == nil)
            }
            
            if isGeneratingPlan {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text(NSLocalizedString("analyzing.your.data", comment: ""))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func performanceSection(profile: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(NSLocalizedString("plan.performance", comment: ""))
                    .font(.headline)
                Spacer()
                
                Button(NSLocalizedString("view.details", comment: "")) {
                    showingPerformanceSheet = true
                }
                .font(.caption)
            }
            
            if !planAdaptations.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(planAdaptations.prefix(3), id: \.recommendation) { adaptation in
                        AdaptationRow(adaptation: adaptation)
                    }
                    
                    if planAdaptations.count > 3 {
                        Text(String(format: NSLocalizedString("plus.more.recommendations", comment: "More recommendations count"), planAdaptations.count - 3))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            } else {
                Text(NSLocalizedString("no.performance.data", comment: ""))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func milestonesSection(recommendation: QuitPlanOptimizer.OptimizationRecommendation) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(NSLocalizedString("recommended.milestones", comment: ""))
                .font(.headline)
            
            LazyVStack(spacing: 8) {
                ForEach(recommendation.personalizedMilestones.prefix(5), id: \.date) { milestone in
                    MilestoneRow(milestone: milestone)
                }
            }
            
            if recommendation.personalizedMilestones.count > 5 {
                Button(String(format: NSLocalizedString("view.all.milestones.format", comment: ""), recommendation.personalizedMilestones.count)) {
                    showingRecommendationSheet = true
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Actions
    
    private func loadCurrentRecommendation() async {
        guard let profile = currentProfile else { return }
        
        // Load any existing recommendation or generate a basic one
        let recommendation = await quitPlanOptimizer.generateOptimizedPlan(
            for: profile,
            modelContext: modelContext,
            currentCigarettes: cigarettes
        )
        
        await MainActor.run {
            currentRecommendation = recommendation
        }
    }
    
    private func generateOptimizedPlan() async {
        guard let profile = currentProfile else { return }
        
        await MainActor.run {
            isGeneratingPlan = true
        }
        
        let recommendation = await quitPlanOptimizer.generateOptimizedPlan(
            for: profile,
            modelContext: modelContext,
            currentCigarettes: cigarettes
        )
        
        await MainActor.run {
            currentRecommendation = recommendation
            isGeneratingPlan = false
            showingRecommendationSheet = true
        }
    }
    
    private func evaluateCurrentPlan() async {
        guard let profile = currentProfile else { return }
        
        await MainActor.run {
            isGeneratingPlan = true
        }
        
        let adaptations = await quitPlanOptimizer.evaluatePlanPerformance(
            profile: profile,
            modelContext: modelContext,
            currentCigarettes: cigarettes
        )
        
        await MainActor.run {
            planAdaptations = adaptations
            isGeneratingPlan = false
            showingPerformanceSheet = true
        }
    }
    
    private func applyRecommendation(_ recommendation: QuitPlanOptimizer.OptimizationRecommendation, to profile: UserProfile) {
        profile.quitDate = recommendation.recommendedQuitDate
        profile.reductionCurve = recommendation.recommendedCurve
        
        try? modelContext.save()
    }
}

// MARK: - Supporting Views

struct PlanMetricCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
}

struct AdaptationRow: View {
    let adaptation: QuitPlanOptimizer.PlanAdaptation
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: adaptation.urgency == .high || adaptation.urgency == .critical ? "exclamationmark.triangle.fill" : "info.circle.fill")
                .foregroundColor(adaptation.urgency == .high || adaptation.urgency == .critical ? .orange : .blue)
                .font(.caption)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(adaptation.recommendation)
                    .font(.caption)
                    .fontWeight(.medium)
                
                Text(adaptation.reason)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(8)
        .background(Color(.systemBackground))
        .cornerRadius(6)
    }
}

struct MilestoneRow: View {
    let milestone: QuitPlanOptimizer.QuitMilestone
    
    var body: some View {
        HStack(spacing: 12) {
            VStack {
                Circle()
                    .fill(milestone.checkpointType == .final ? Color.green : Color.blue)
                    .frame(width: 8, height: 8)
                
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 2, height: 20)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(milestone.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text(String(format: NSLocalizedString("milestone.target.format", comment: ""), milestone.target))
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(.systemGray5))
                        .cornerRadius(4)
                }
                
                Text(milestone.description)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

// MARK: - Sheet Views

struct RecommendationDetailView: View {
    let recommendation: QuitPlanOptimizer.OptimizationRecommendation
    let onAction: (Bool) -> Void
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Confidence and Overview
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(NSLocalizedString("recommendation", comment: ""))
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            ConfidenceIndicator(score: recommendation.confidenceScore)
                        }
                        
                        Text(recommendation.reasoning)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    // Key Details
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        DetailCard(title: NSLocalizedString("quit.date", comment: ""), value: recommendation.recommendedQuitDate.formatted(date: .abbreviated, time: .omitted), icon: "calendar")
                        DetailCard(title: NSLocalizedString("approach", comment: ""), value: recommendation.recommendedCurve.rawValue.capitalized, icon: "chart.line.downtrend.xyaxis")
                    }
                    
                    // Risk Factors
                    if !recommendation.riskFactors.isEmpty {
                        SectionView(title: NSLocalizedString("risk.factors", comment: ""), items: recommendation.riskFactors, color: .orange)
                    }
                    
                    // Support Strategies
                    if !recommendation.supportStrategies.isEmpty {
                        SectionView(title: NSLocalizedString("support.strategies", comment: ""), items: recommendation.supportStrategies, color: .green)
                    }
                    
                    // Milestones
                    VStack(alignment: .leading, spacing: 12) {
                        Text(NSLocalizedString("personalized.milestones", comment: ""))
                            .font(.headline)
                        
                        ForEach(recommendation.personalizedMilestones, id: \.date) { milestone in
                            MilestoneDetailRow(milestone: milestone)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle(NSLocalizedString("ai.recommendation", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(NSLocalizedString("cancel", comment: "")) {
                        onAction(false)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("apply", comment: "")) {
                        onAction(true)
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

struct PlanPerformanceView: View {
    let adaptations: [QuitPlanOptimizer.PlanAdaptation]
    let onAdaptationSelected: (QuitPlanOptimizer.PlanAdaptation) -> Void
    
    var body: some View {
        NavigationView {
            List {
                if adaptations.isEmpty {
                    Text(NSLocalizedString("no.performance.issues", comment: ""))
                        .foregroundColor(.secondary)
                } else {
                    ForEach(adaptations, id: \.recommendation) { adaptation in
                        AdaptationDetailRow(adaptation: adaptation) {
                            onAdaptationSelected(adaptation)
                        }
                    }
                }
            }
            .navigationTitle(NSLocalizedString("plan.performance", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Helper Views

struct ConfidenceIndicator: View {
    let score: Double
    
    var body: some View {
        HStack(spacing: 4) {
            Text(NSLocalizedString("confidence", comment: ""))
                .font(.caption2)
                .foregroundColor(.secondary)
            
            Text("\(Int(score * 100))%")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(score > 0.7 ? .green : score > 0.5 ? .orange : .red)
        }
    }
}

struct DetailCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct SectionView: View {
    let title: String
    let items: [String]
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            
            ForEach(items, id: \.self) { item in
                HStack {
                    Circle()
                        .fill(color)
                        .frame(width: 4, height: 4)
                    
                    Text(item)
                        .font(.caption)
                }
            }
        }
    }
}

struct MilestoneDetailRow: View {
    let milestone: QuitPlanOptimizer.QuitMilestone
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(milestone.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text(String(format: NSLocalizedString("milestone.target.label", comment: "Milestone target label"), milestone.target))
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color(.systemGray5))
                    .cornerRadius(4)
            }
            
            Text(milestone.description)
                .font(.caption)
            
            Text(milestone.motivationalMessage)
                .font(.caption2)
                .foregroundColor(.secondary)
                .italic()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct AdaptationDetailRow: View {
    let adaptation: QuitPlanOptimizer.PlanAdaptation
    let action: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: adaptationIcon)
                    .foregroundColor(adaptationColor)
                
                Text(adaptation.type.rawValue.localizedCapitalized)
                    .font(.headline)
                
                Spacer()
                
                UrgencyBadge(urgency: adaptation.urgency)
            }
            
            Text(adaptation.reason)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(adaptation.recommendation)
                .font(.body)
            
            Button(NSLocalizedString("apply.this.suggestion", comment: "")) {
                action()
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .padding()
    }
    
    private var adaptationIcon: String {
        switch adaptation.type {
        case .scheduleAdjustment: return "calendar"
        case .curveChange: return "chart.line.uptrend.xyaxis"
        case .supportIncrease: return "person.3.fill"
        case .medicalConsultation: return "stethoscope"
        case .behavioralIntervention: return "brain.head.profile"
        }
    }
    
    private var adaptationColor: Color {
        switch adaptation.urgency {
        case .low: return .blue
        case .medium: return .orange
        case .high: return .red
        case .critical: return .purple
        }
    }
}

struct UrgencyBadge: View {
    let urgency: QuitPlanOptimizer.AdaptationUrgency
    
    var body: some View {
        Text(urgency.rawValue.localizedCapitalized)
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(urgencyColor)
            .foregroundColor(.white)
            .cornerRadius(4)
    }
    
    private var urgencyColor: Color {
        switch urgency {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        case .critical: return .purple
        }
    }
}

#Preview {
    QuitPlanOptimizationView()
        .modelContainer(PreviewDataProvider.previewContainer)
}