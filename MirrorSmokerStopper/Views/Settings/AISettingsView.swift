//
//  AISettingsView.swift
//  MirrorSmokerStopper
//
//  Created by Claude on 02/09/25.
//

import SwiftUI
import SwiftData

struct AISettingsView: View {
    @StateObject private var aiConfig = AIConfiguration.shared
    @State private var showingConfigurationReport = false
    @State private var showingResetAlert = false
    @State private var configurationReport = ""
    
    var body: some View {
        NavigationView {
            List {
                // AI Availability Section
                aiAvailabilitySection
                
                // Main AI Features
                if aiConfig.isAIAvailable {
                    mainFeaturesSection
                    
                    // Coaching Configuration
                    if aiConfig.isAICoachingEnabled {
                        coachingConfigurationSection
                    }
                    
                    // Features automatically enabled with AI Coach
                    aiFeatureStatusSection
                    
                    // Notification Settings
                    notificationSettingsSection
                    
                    // Advanced Settings
                    advancedSettingsSection
                }
                
                // Configuration Management
                configurationManagementSection
            }
            .navigationTitle(NSLocalizedString("ai.coaching.settings", comment: ""))
            .sheet(isPresented: $showingConfigurationReport) {
                NavigationView {
                    ScrollView {
                        Text(configurationReport)
                            .font(.system(.caption, design: .monospaced))
                            .padding()
                    }
                    .navigationTitle(NSLocalizedString("configuration.report", comment: ""))
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(NSLocalizedString("done", comment: "")) {
                                showingConfigurationReport = false
                            }
                        }
                    }
                }
            }
            .alert(NSLocalizedString("reset.configuration", comment: ""), isPresented: $showingResetAlert) {
                Button(NSLocalizedString("reset", comment: ""), role: .destructive) {
                    aiConfig.resetToDefaults()
                }
                Button(NSLocalizedString("cancel", comment: ""), role: .cancel) { }
            } message: {
                Text(NSLocalizedString("reset.ai.warning", comment: ""))
            }
        }
        .onChange(of: aiConfig.isAICoachingEnabled) { _, newValue in
            if newValue {
                // Automatically enable basic features when AI coaching is turned on
                aiConfig.enableBehavioralAnalysis = true
                aiConfig.enableQuitPlanOptimization = true
            }
        }
    }
    
    // MARK: - View Sections
    
    private var aiAvailabilitySection: some View {
        Section {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(NSLocalizedString("ai.coaching.system", comment: ""))
                        .font(.headline)
                    
                    Text(aiConfig.isAIAvailable ? NSLocalizedString("available.ios26", comment: "") : NSLocalizedString("requires.ios26", comment: ""))
                        .font(.caption)
                        .foregroundColor(aiConfig.isAIAvailable ? .green : .orange)
                }
                
                Spacer()
                
                Image(systemName: aiConfig.isAIAvailable ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    .foregroundColor(aiConfig.isAIAvailable ? .green : .orange)
                    .font(.title2)
            }
            .padding(.vertical, 4)
            
            if !aiConfig.isAIAvailable {
                Text(NSLocalizedString("ios26.compatibility.message", comment: ""))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
        } header: {
            Text(NSLocalizedString("system.status", comment: ""))
        }
    }
    
    private var mainFeaturesSection: some View {
        Section {
            Toggle(NSLocalizedString("ai.coaching", comment: ""), isOn: $aiConfig.isAICoachingEnabled)
                .disabled(!aiConfig.isAIAvailable)
            
            Toggle(NSLocalizedString("behavioral.analysis", comment: ""), isOn: $aiConfig.enableBehavioralAnalysis)
                .disabled(!aiConfig.isAIAvailable)
            
            Toggle(NSLocalizedString("quit.plan.optimization", comment: ""), isOn: $aiConfig.enableQuitPlanOptimization)
            
            // HealthKit is automatically enabled with AI Coach
            HStack {
                Label(NSLocalizedString("healthkit.integration", comment: ""), systemImage: "heart.text.square.fill")
                    .foregroundColor(.pink)
                Spacer()
                Text(aiConfig.isAICoachingEnabled ? NSLocalizedString("auto.enabled", comment: "") : NSLocalizedString("off", comment: ""))
                    .foregroundColor(aiConfig.isAICoachingEnabled ? .green : .gray)
            }
        } header: {
            Text(NSLocalizedString("ai.features", comment: ""))
        } footer: {
            Text(NSLocalizedString("ai.coaching.description", comment: ""))
        }
    }
    
    private var coachingConfigurationSection: some View {
        Section {
            Picker(NSLocalizedString("coaching.frequency", comment: ""), selection: $aiConfig.aiCoachingFrequency) {
                ForEach(AIConfiguration.CoachingFrequency.allCases, id: \.self) { frequency in
                    VStack(alignment: .leading) {
                        HStack {
                            Image(systemName: frequency.icon)
                            Text(frequency.displayName)
                            Spacer()
                        }
                        Text(frequency.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .tag(frequency)
                }
            }
            .pickerStyle(.navigationLink)
            
            HStack {
                Text(NSLocalizedString("daily.coaching.limit", comment: ""))
                Spacer()
                Stepper("\(aiConfig.maxDailyNotifications)", value: $aiConfig.maxDailyNotifications, in: 1...10)
            }
            
            HStack {
                Text(NSLocalizedString("risk.sensitivity", comment: ""))
                Spacer()
                Text(String(format: "%.0f%%", aiConfig.riskThreshold * 100))
                    .foregroundColor(.secondary)
            }
        } header: {
            Text(NSLocalizedString("coaching.behavior", comment: ""))
        } footer: {
            Text(NSLocalizedString("coaching.behavior.description", comment: ""))
        }
    }
    
    private var aiFeatureStatusSection: some View {
        Section {
            // AI Coach status indicator
            HStack {
                Image(systemName: aiConfig.isAICoachingEnabled ? "checkmark.circle.fill" : "xmark.circle")
                    .foregroundColor(aiConfig.isAICoachingEnabled ? .green : .gray)
                Text("AI Coach")
                Spacer()
                Text(aiConfig.isAICoachingEnabled ? "ON" : "OFF")
                    .foregroundColor(aiConfig.isAICoachingEnabled ? .green : .gray)
            }
            
            if aiConfig.isAICoachingEnabled {
                // Show what's enabled with AI Coach
                PrivacyIndicatorRow(
                    title: NSLocalizedString("healthkit.data", comment: ""),
                    enabled: true,
                    description: NSLocalizedString("Heart rate monitoring for craving prediction", comment: "")
                )
                
                PrivacyIndicatorRow(
                    title: NSLocalizedString("behavioral.analysis", comment: ""),
                    enabled: true,
                    description: NSLocalizedString("Pattern recognition for personalized coaching", comment: "")
                )
                
                PrivacyIndicatorRow(
                    title: NSLocalizedString("smart.notifications", comment: ""),
                    enabled: true,
                    description: NSLocalizedString("Just-in-time interventions based on your patterns", comment: "")
                )
            }
        } header: {
            Text(NSLocalizedString("AI Coach Features", comment: ""))
        } footer: {
            Text(NSLocalizedString("When AI Coach is ON, all wellness features are enabled for best results. All processing happens on your device.", comment: ""))
        }
    }
    
    private var notificationSettingsSection: some View {
        Section {
            Toggle(NSLocalizedString("quiet.hours", comment: ""), isOn: $aiConfig.quietHoursEnabled)
            
            if aiConfig.quietHoursEnabled {
                HStack {
                    Text(NSLocalizedString("start.time", comment: ""))
                    Spacer()
                    Picker(NSLocalizedString("start", comment: ""), selection: $aiConfig.quietHoursStart) {
                        ForEach(0..<24) { hour in
                            Text(String(format: "hour.format".local(), hour)).tag(hour)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                HStack {
                    Text(NSLocalizedString("end.time", comment: ""))
                    Spacer()
                    Picker(NSLocalizedString("end", comment: ""), selection: $aiConfig.quietHoursEnd) {
                        ForEach(0..<24) { hour in
                            Text(String(format: "hour.format".local(), hour)).tag(hour)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            
            HStack {
                Text(NSLocalizedString("current.status", comment: ""))
                Spacer()
                let currentHour = Calendar.current.component(.hour, from: Date())
                let inQuietHours = aiConfig.quietHoursEnabled && aiConfig.quietHoursRange.contains(currentHour)
                Text(inQuietHours ? NSLocalizedString("quiet", comment: "") : NSLocalizedString("active", comment: ""))
                    .foregroundColor(inQuietHours ? .orange : .green)
            }
        } header: {
            Text(NSLocalizedString("notification.schedule", comment: ""))
        } footer: {
            Text(NSLocalizedString("notification.schedule.description", comment: ""))
        }
    }
    
    private var advancedSettingsSection: some View {
        Section {
            NavigationLink(destination: QuitPlanOptimizationView()) {
                Label(NSLocalizedString("quit.plan.optimization", comment: ""), systemImage: "wand.and.rays")
            }
            .disabled(!aiConfig.enableQuitPlanOptimization)
            
            NavigationLink(destination: BehavioralInsightsView()) {
                Label(NSLocalizedString("behavioral.insights", comment: ""), systemImage: "brain.head.profile")
            }
            .disabled(!aiConfig.enableBehavioralAnalysis)
            
            Button(NSLocalizedString("view.configuration.report", comment: "")) {
                configurationReport = aiConfig.generateConfigurationReport()
                showingConfigurationReport = true
            }
        } header: {
            Text(NSLocalizedString("advanced.features", comment: ""))
        }
    }
    
    private var configurationManagementSection: some View {
        Section {
            Button(NSLocalizedString("reset.to.defaults", comment: "")) {
                showingResetAlert = true
            }
            .foregroundColor(.red)
            
            Button(NSLocalizedString("export.configuration", comment: "")) {
                // Convert to JSON string for sharing
                if let jsonData = try? JSONSerialization.data(withJSONObject: aiConfig.exportConfiguration(), options: .prettyPrinted),
                   let jsonString = String(data: jsonData, encoding: .utf8) {
                    UIPasteboard.general.string = jsonString
                }
            }
        } header: {
            Text(NSLocalizedString("configuration.management", comment: ""))
        } footer: {
            Text(NSLocalizedString("configuration.management.description", comment: ""))
        }
    }
}

// MARK: - Supporting Views

struct PrivacyIndicatorRow: View {
    let title: String
    let enabled: Bool
    let description: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                Text(description)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: enabled ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(enabled ? .green : .gray)
        }
        .padding(.vertical, 2)
    }
}

struct BehavioralInsightsView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var behavioralAnalyzer = BehavioralAnalyzer.shared
    @Query private var userProfile: [UserProfile]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    if behavioralAnalyzer.isAnalyzing {
                        VStack(spacing: 12) {
                            ProgressView()
                            Text(NSLocalizedString("analyzing.behavioral.patterns", comment: ""))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    } else if behavioralAnalyzer.currentInsights.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "brain.head.profile")
                                .font(.system(size: 48))
                                .foregroundColor(.blue)
                            
                            Text(NSLocalizedString("no.behavioral.insights.yet", comment: ""))
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text(NSLocalizedString("start.logging.message", comment: ""))
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                            
                            Button(NSLocalizedString("analyze.patterns", comment: "")) {
                                Task {
                                    await behavioralAnalyzer.performFullAnalysis(
                                        modelContext: modelContext,
                                        userProfile: userProfile.first
                                    )
                                }
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding()
                    } else {
                        ForEach(behavioralAnalyzer.currentInsights) { insight in
                            BehavioralInsightCard(insight: insight)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle(NSLocalizedString("behavioral.insights", comment: ""))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("refresh", comment: "")) {
                        Task {
                            _ = await behavioralAnalyzer.performFullAnalysis(
                                modelContext: modelContext,
                                userProfile: userProfile.first
                            )
                        }
                    }
                    .disabled(behavioralAnalyzer.isAnalyzing)
                }
            }
        }
        .task {
            if behavioralAnalyzer.currentInsights.isEmpty {
                _ = await behavioralAnalyzer.performFullAnalysis(
                    modelContext: modelContext,
                    userProfile: userProfile.first
                )
            }
        }
    }
}

struct BehavioralInsightCard: View {
    let insight: BehavioralAnalyzer.BehavioralInsight
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: insight.type.icon)
                    .foregroundColor(Color(insight.type.color))
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(insight.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    HStack {
                        RiskIndicator(score: insight.riskScore)
                        ConfidenceIndicator(score: insight.confidence)
                    }
                }
                
                Spacer()
                
                Button(action: { withAnimation { isExpanded.toggle() } }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.blue)
                }
            }
            
            Text(insight.description)
                .font(.body)
                .foregroundColor(.primary)
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    Text(NSLocalizedString("recommended.actions", comment: ""))
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    ForEach(insight.actionableRecommendations, id: \.self) { recommendation in
                        HStack(alignment: .top, spacing: 8) {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 4, height: 4)
                                .padding(.top, 6)
                            
                            Text(recommendation)
                                .font(.caption)
                        }
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding(16)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct RiskIndicator: View {
    let score: Double
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(riskColor)
                .font(.caption2)
            
            Text(riskLevel)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(riskColor)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(riskColor.opacity(0.1))
        .cornerRadius(4)
    }
    
    private var riskColor: Color {
        switch score {
        case 0.0..<0.3: return .green
        case 0.3..<0.6: return .yellow
        case 0.6..<0.8: return .orange
        default: return .red
        }
    }
    
    private var riskLevel: String {
        switch score {
        case 0.0..<0.3: return NSLocalizedString("low.risk", comment: "")
        case 0.3..<0.6: return NSLocalizedString("medium.risk", comment: "")
        case 0.6..<0.8: return NSLocalizedString("high.risk", comment: "")
        default: return NSLocalizedString("critical.risk", comment: "")
        }
    }
}


#Preview {
    AISettingsView()
        .modelContainer(PreviewDataProvider.previewContainer)
}