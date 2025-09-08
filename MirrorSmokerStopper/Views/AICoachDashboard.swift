//
//  AICoachDashboard.swift
//  MirrorSmokerStopper
//
//  AI Coach Dashboard with Heart Rate Intelligence
//

import SwiftUI
import SwiftData
import os

struct AICoachDashboard: View {
    @StateObject private var aiConfig = AIConfiguration.shared
    @StateObject private var heartRateEngine = HeartRateCoachingEngine.shared
    @StateObject private var focusManager = FocusModeManager.shared
    @State private var showingCoachTest = false
    @State private var showingHealthKitPermission = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Show AI features only in FULL version
                    if AppConfiguration.hasAIFeatures {
                        // AI Coach Status Card
                        aiCoachStatusCard
                        
                        if aiConfig.isAICoachingEnabled {
                        // Cardiovascular Wellness Card
                        if heartRateEngine.isMonitoring {
                            cardiovascularWellnessCard
                        } else {
                            setupHeartRateCard
                        }
                        
                        // Pattern Analysis Card
                        patternAnalysisCard
                        
                        // Personalized Actions
                        personalizedActionsCard
                        
                        // Chat with AI Coach (iOS 26 only)
                        chatSection
                        
                        // Quick Settings
                        quickSettingsCard
                        
                        // Legal Disclaimer
                        legalDisclaimerCard
                        } else {
                            // Enable AI Coach prompt
                            enableAICoachCard
                        }
                    } else {
                        // SIMPLE version - Basic tracking without AI
                        simpleVersionContent
                    }
                }
                .padding()
            }
            .navigationTitle(AppConfiguration.hasAIFeatures ? "AI Coach" : "Progress")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Test") {
                        showingCoachTest = true
                    }
                    .opacity(aiConfig.isAICoachingEnabled ? 1 : 0)
                }
            }
            .sheet(isPresented: $showingCoachTest) {
                if #available(iOS 26, *) {
                    AICoachTestView()
                } else {
                    Text("AI Coach requires iOS 26")
                        .padding()
                }
            }
            .sheet(isPresented: $showingHealthKitPermission) {
                HealthKitPermissionView()
            }
        }
    }
    
    // MARK: - AI Coach Status
    
    private var aiCoachStatusCard: some View {
        Card {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "brain.head.profile")
                        .font(.title2)
                        .foregroundColor(aiConfig.isAICoachingEnabled ? .green : .gray)
                    
                    Text("AI COACH")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Toggle("", isOn: $aiConfig.isAICoachingEnabled)
                        .labelsHidden()
                }
                
                if aiConfig.isAICoachingEnabled {
                    HStack {
                        StatusIndicator(
                            title: "Status",
                            value: "Active",
                            color: .green
                        )
                        
                        Spacer()
                        
                        StatusIndicator(
                            title: "Focus Mode",
                            value: focusManager.currentFocusState.description,
                            color: focusManager.currentFocusState == .available ? .green : .orange
                        )
                    }
                    
                    if let insights = getLatestInsights() {
                        Text("Today's Insights: \(insights.count) new")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding()
        }
        .onChange(of: aiConfig.isAICoachingEnabled) { _, enabled in
            if enabled {
                Task {
                    await setupAICoach()
                }
            }
        }
    }
    
    // MARK: - Cardiovascular Wellness
    
    private var cardiovascularWellnessCard: some View {
        Card {
            VStack(alignment: .leading, spacing: 16) {
                Label("CARDIOVASCULAR WELLNESS", systemImage: "heart.fill")
                    .font(.headline)
                    .foregroundColor(.red)
                
                // Current Heart Rate
                HStack {
                    VStack(alignment: .leading) {
                        Text("Current HR")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        HStack(alignment: .lastTextBaseline) {
                            Text("\(Int(heartRateEngine.currentHeartRate))")
                                .font(.title)
                                .fontWeight(.bold)
                            Text("BPM")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    // Stress Level
                    VStack(alignment: .trailing) {
                        Text("Stress Level")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(heartRateEngine.stressLevel.description)
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(heartRateEngine.stressLevel.color)
                    }
                }
                
                // Risk Prediction
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(heartRateEngine.cravingRisk.color)
                    
                    VStack(alignment: .leading) {
                        Text("Risk Prediction")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(heartRateEngine.cravingRisk.timeEstimate)
                            .font(.body)
                            .foregroundColor(heartRateEngine.cravingRisk.color)
                    }
                    
                    Spacer()
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(heartRateEngine.cravingRisk.color.opacity(0.1))
                .cornerRadius(8)
                
                // Recovery Progress
                if heartRateEngine.hasBaseline {
                    let progress = heartRateEngine.getCardiovascularProgress()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("RECOVERY PROGRESS")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        
                        ProgressRow(
                            icon: "arrow.down",
                            title: "Resting HR",
                            value: "\(progress.restingHRImprovement) BPM",
                            color: .green
                        )
                        
                        ProgressRow(
                            icon: "arrow.up",
                            title: "HRV Improvement",
                            value: "+\(progress.hrvImprovement)%",
                            color: .blue
                        )
                        
                        ProgressRow(
                            icon: "moon.fill",
                            title: "Sleep HR Quality",
                            value: String(repeating: "⭐", count: progress.sleepHRQuality),
                            color: .purple
                        )
                    }
                }
            }
            .padding()
        }
    }
    
    private var setupHeartRateCard: some View {
        Card {
            VStack(spacing: 12) {
                Image(systemName: "heart.text.square")
                    .font(.largeTitle)
                    .foregroundColor(.red)
                
                Text("Enable Heart Rate Monitoring")
                    .font(.headline)
                
                Text("Track your heart rate for predictive coaching and wellness insights")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Button(action: {
                    Task {
                        await setupHeartRateMonitoring()
                    }
                }) {
                    Label("Enable Heart Rate", systemImage: "heart.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.regular)
                
                Text("NOT A MEDICAL DEVICE")
                    .font(.caption2)
                    .foregroundColor(.orange)
            }
            .padding()
        }
    }
    
    // MARK: - Pattern Analysis
    
    private var patternAnalysisCard: some View {
        Card {
            VStack(alignment: .leading, spacing: 12) {
                Label("PATTERN ANALYSIS", systemImage: "chart.xyaxis.line")
                    .font(.headline)
                    .foregroundColor(.blue)
                
                if let patterns = getSmokingPatterns() {
                    ForEach(patterns, id: \.id) { pattern in
                        HStack {
                            Image(systemName: pattern.icon)
                                .foregroundColor(pattern.color)
                            
                            VStack(alignment: .leading) {
                                Text(pattern.title)
                                    .font(.subheadline)
                                Text(pattern.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - Personalized Actions
    
    private var personalizedActionsCard: some View {
        Card {
            VStack(alignment: .leading, spacing: 12) {
                Label("PERSONALIZED ACTIONS", systemImage: "sparkles")
                    .font(.headline)
                    .foregroundColor(.orange)
                
                if heartRateEngine.stressLevel == .elevated || heartRateEngine.stressLevel == .high {
                    ActionButton(
                        title: "Take 5-min mindful break",
                        subtitle: "HR: 78→65 BPM expected",
                        icon: "brain.head.profile",
                        color: .blue
                    ) {
                        startBreathingExercise()
                    }
                }
                
                ActionButton(
                    title: "Review quit plan progress",
                    subtitle: "3 milestones achieved",
                    icon: "checkmark.circle",
                    color: .green
                ) {
                    // Navigate to quit plan
                }
                
                if focusManager.detectActivityContext() == .evening {
                    ActionButton(
                        title: "Daily reflection",
                        subtitle: "Log today's wins",
                        icon: "book.closed",
                        color: .purple
                    ) {
                        // Open reflection journal
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - Quick Settings
    
    private var quickSettingsCard: some View {
        Card {
            VStack(alignment: .leading, spacing: 12) {
                Text("QUICK SETTINGS")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                HStack {
                    Label("Notification Priority", systemImage: "bell")
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Text(getNotificationPriorityText())
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                HStack {
                    Label("Coach Personality", systemImage: "person.bubble")
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Text("Supportive")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            .padding()
        }
    }
    
    // MARK: - Enable AI Coach
    
    private var enableAICoachCard: some View {
        Card {
            VStack(spacing: 16) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("Enable AI Coach")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Get personalized quit support with heart rate monitoring and smart interventions")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Text("• Predicts cravings 15-30 min early\n• Tracks cardiovascular improvements\n• Respects Focus Mode and Sleep\n• All data stays on your device")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                
                Toggle("Enable AI Coach", isOn: $aiConfig.isAICoachingEnabled)
                    .toggleStyle(.button)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                
                Text("NOT A MEDICAL DEVICE - Wellness coaching only")
                    .font(.caption2)
                    .foregroundColor(.orange)
            }
            .padding()
        }
    }
    
    // MARK: - Legal Disclaimer
    
    private var legalDisclaimerCard: some View {
        Card {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "exclamationmark.shield.fill")
                        .font(.title2)
                        .foregroundColor(.orange)
                    
                    Text(NSLocalizedString("disclaimer.title", comment: ""))
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                
                Text(NSLocalizedString("disclaimer.not_medical_device", comment: ""))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(NSLocalizedString("disclaimer.consult_professionals", comment: ""))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(NSLocalizedString("disclaimer.predictions_estimate", comment: ""))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
        }
    }
    
    // MARK: - Helper Methods
    
    private func setupAICoach() async {
        // Request HealthKit permissions
        do {
            try await heartRateEngine.requestAuthorization()
            
            // Start monitoring if authorized
            heartRateEngine.startMonitoring()
            
            // Establish baseline if needed
            if !heartRateEngine.hasBaseline {
                heartRateEngine.establishBaseline()
            }
        } catch {
            logger.error("Failed to setup AI Coach: \(error)")
        }
    }
    
    private func setupHeartRateMonitoring() async {
        showingHealthKitPermission = true
    }
    
    private func startBreathingExercise() {
        // Navigate to breathing exercise view
    }
    
    private func getLatestInsights() -> [String]? {
        // Mock data - would fetch from behavioral analyzer
        return ["Peak risk time detected", "Stress pattern identified", "Success rate improving"]
    }
    
    private func getSmokingPatterns() -> [DashboardPatternInsight]? {
        // Mock data - would fetch from pattern analysis
        return [
            DashboardPatternInsight(
                id: "1",
                title: "Peak risk time: 15:30-16:00",
                description: "Work stress trigger detected",
                icon: "clock",
                color: .orange
            ),
            DashboardPatternInsight(
                id: "2",
                title: "Trigger detected: Stress",
                description: "87% correlation with elevated HR",
                icon: "exclamationmark.triangle",
                color: .red
            ),
            DashboardPatternInsight(
                id: "3",
                title: "Success rate: 78% this week",
                description: "Up from 65% last week",
                icon: "chart.line.uptrend.xyaxis",
                color: .green
            )
        ]
    }
    
    private func getNotificationPriorityText() -> String {
        if focusManager.currentFocusState == .doNotDisturb {
            return "Critical Only"
        } else if focusManager.currentFocusState == .available {
            return "Standard"
        } else {
            return "Adaptive"
        }
    }
    
    private let logger = Logger(subsystem: "com.fightthestroke.MirrorSmokerStopper", category: "Dashboard")
}

// MARK: - Supporting Views

struct Card<Content: View>: View {
    let content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        content()
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct StatusIndicator: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(color)
        }
    }
}

struct ProgressRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(color)
        }
    }
}

struct ActionButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .frame(width: 30)
                
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(color.opacity(0.1))
            .cornerRadius(8)
        }
    }
}

struct DashboardPatternInsight: Identifiable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let color: Color
}

struct HealthKitPermissionView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.red)
                
                Text("Heart Rate Access")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("MirrorSmoker needs access to your heart rate data to provide predictive coaching and track cardiovascular improvements.")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 12) {
                    PermissionRow(
                        icon: "heart.fill",
                        title: "Heart Rate",
                        description: "Monitor stress and predict cravings"
                    )
                    
                    PermissionRow(
                        icon: "waveform.path.ecg",
                        title: "Heart Rate Variability",
                        description: "Assess stress resilience"
                    )
                    
                    PermissionRow(
                        icon: "bed.double.fill",
                        title: "Resting Heart Rate",
                        description: "Track recovery progress"
                    )
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                Text("⚠️ NOT A MEDICAL DEVICE")
                    .font(.caption)
                    .foregroundColor(.orange)
                
                Text("This app provides wellness coaching only. Heart rate analysis is not for medical diagnosis.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                Button("Grant Access") {
                    Task {
                        await grantAccess()
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func grantAccess() async {
        do {
            try await HeartRateCoachingEngine.shared.requestAuthorization()
            HeartRateCoachingEngine.shared.startMonitoring()
            dismiss()
        } catch {
            // Handle error
        }
    }
}

struct PermissionRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.red)
                .frame(width: 30)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

    // MARK: - Chat Section (iOS 26 only)
    
    @ViewBuilder
    private var chatSection: some View {
        if #available(iOS 26.0, *) {
            NavigationLink(destination: ChatbotView()) {
                Card {
                    HStack {
                        Image(systemName: "message.fill")
                            .foregroundColor(.blue)
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Chat with AI Coach")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text("Ask questions, get personalized advice")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                            .font(.caption)
                        
                        Text("iOS 26")
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .clipShape(Capsule())
                    }
                    .padding()
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    // MARK: - Simple Version Content
    
    private var simpleVersionContent: some View {
        VStack(spacing: 20) {
            // Basic Progress Card
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .foregroundColor(.blue)
                        .font(.title2)
                    
                    Text("Your Progress")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                }
                
                Text("Track your smoking cessation journey with essential statistics and motivation.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Basic Statistics Card
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "number")
                        .foregroundColor(.green)
                        .font(.title2)
                    
                    Text("Essential Stats")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                }
                
                Text("View your days smoke-free, money saved, and health improvements.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Upgrade Prompt
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundColor(.purple)
                        .font(.title2)
                    
                    Text("Want AI Coaching?")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                }
                
                Text("Upgrade to Mirror Smoker Pro for personalized AI coaching, advanced analytics, and more features.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Button(action: {
                    // TODO: Handle upgrade action
                }) {
                    Text("Learn More")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.purple)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

#Preview {
    AICoachDashboard()
}
