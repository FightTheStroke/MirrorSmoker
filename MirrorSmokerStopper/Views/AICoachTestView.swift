//
//  AICoachTestView.swift
//  MirrorSmokerStopper
//
//  Created by Claude on 04/09/25.
//

import SwiftUI
import SwiftData

@available(iOS 26, *)
struct AICoachTestView: View {
    @StateObject private var aiCoach = AICoachManager.shared
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    
    @State private var selectedMood: CoachMood = .encouraging
    @State private var selectedContext: TriggerContext = .morningRoutine
    @State private var motivationalMessage: String?
    @State private var personalizedNudge: String?
    @State private var isGenerating = false
    
    private var userProfile: UserProfile? {
        profiles.first
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // AI Status Section
                    aiStatusSection
                    
                    // Daily Tip Section
                    dailyTipSection
                    
                    // Motivational Message Section
                    motivationalMessageSection
                    
                    // Pattern Analysis Section
                    patternAnalysisSection
                    
                    // Personalized Nudge Section
                    personalizedNudgeSection
                    
                    Spacer(minLength: 20)
                }
                .padding()
            }
            .navigationTitle("🧠 AI Coach Test")
            .navigationBarTitleDisplayMode(.large)
        }
        .task {
            // Generate initial tip
            await aiCoach.generateDailyTip(modelContext: modelContext, userProfile: userProfile)
        }
    }
    
    private var aiStatusSection: some View {
        LegacyDSCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "brain.head.profile")
                        .font(.title2)
                        .foregroundColor(.blue)
                    Text("AI Coach Status")
                        .font(.headline)
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    statusRow("iOS Version", value: "\(ProcessInfo.processInfo.operatingSystemVersion.majorVersion)")
                    statusRow("AI Available", value: AIConfiguration.shared.isAIAvailable ? "✅ Yes" : "❌ No")
                    statusRow("Local Intelligence", value: isLocalIntelligenceAvailable ? "✅ Ready" : "⚠️ Fallback")
                    statusRow("Coaching Enabled", value: AIConfiguration.shared.isAICoachingEnabled ? "✅ On" : "❌ Off")
                }
            }
            .padding()
        }
    }
    
    private var dailyTipSection: some View {
        LegacyDSCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .font(.title2)
                        .foregroundColor(.yellow)
                    Text("Daily AI Tip")
                        .font(.headline)
                    Spacer()
                    
                    if aiCoach.isGeneratingTip {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                }
                
                if let tip = aiCoach.currentTip {
                    Text(tip)
                        .font(.body)
                        .foregroundColor(.primary)
                        .padding(.vertical, 8)
                } else {
                    Text("No tip generated yet")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                
                Button(action: {
                    Task {
                        await aiCoach.generateDailyTip(modelContext: modelContext, userProfile: userProfile)
                    }
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Generate New Tip")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .disabled(aiCoach.isGeneratingTip)
            }
            .padding()
        }
    }
    
    private var motivationalMessageSection: some View {
        LegacyDSCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "heart.fill")
                        .font(.title2)
                        .foregroundColor(.red)
                    Text("Motivational Message")
                        .font(.headline)
                    Spacer()
                }
                
                // Mood Selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(CoachMood.allCases, id: \.rawValue) { mood in
                            Button(mood.displayName) {
                                selectedMood = mood
                                Task {
                                    isGenerating = true
                                    motivationalMessage = await aiCoach.generateMotivationalMessage(
                                        mood: mood,
                                        modelContext: modelContext,
                                        userProfile: userProfile
                                    )
                                    isGenerating = false
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(selectedMood == mood ? Color.blue : Color.gray.opacity(0.2))
                            .foregroundColor(selectedMood == mood ? .white : .primary)
                            .cornerRadius(20)
                        }
                    }
                    .padding(.horizontal)
                }
                
                if let message = motivationalMessage {
                    Text(message)
                        .font(.body)
                        .foregroundColor(.primary)
                        .padding(.vertical, 8)
                } else {
                    Text("Select a mood to generate message")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                
                if isGenerating {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Generating...")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
        }
    }
    
    private var patternAnalysisSection: some View {
        LegacyDSCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.title2)
                        .foregroundColor(.green)
                    Text("Pattern Analysis")
                        .font(.headline)
                    Spacer()
                }
                
                Button(action: {
                    Task {
                        await aiCoach.analyzePatterns(modelContext: modelContext, userProfile: userProfile)
                    }
                }) {
                    HStack {
                        Image(systemName: "brain.head.profile")
                        Text("Analyze Patterns")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                
                if aiCoach.patternInsights.isEmpty {
                    Text("No patterns analyzed yet")
                        .font(.body)
                        .foregroundColor(.secondary)
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(aiCoach.patternInsights) { insight in
                            patternInsightCard(insight)
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    private var personalizedNudgeSection: some View {
        LegacyDSCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "bell.badge")
                        .font(.title2)
                        .foregroundColor(.orange)
                    Text("Personalized Nudge")
                        .font(.headline)
                    Spacer()
                }
                
                // Context Selector
                Picker("Context", selection: $selectedContext) {
                    ForEach(TriggerContext.allCases, id: \.rawValue) { context in
                        Text(context.displayName)
                            .tag(context)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                
                Button(action: {
                    Task {
                        isGenerating = true
                        personalizedNudge = await aiCoach.getPersonalizedNudge(
                            context: selectedContext,
                            modelContext: modelContext,
                            userProfile: userProfile
                        )
                        isGenerating = false
                    }
                }) {
                    HStack {
                        Image(systemName: "wand.and.stars")
                        Text("Get Nudge")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                
                if let nudge = personalizedNudge {
                    Text(nudge)
                        .font(.body)
                        .foregroundColor(.primary)
                        .padding(.vertical, 8)
                }
            }
            .padding()
        }
    }
    
    private func statusRow(_ title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
        }
    }
    
    @available(iOS 26, *)
    private func patternInsightCard(_ insight: PatternInsight) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(insight.patternType.displayName)
                    .font(.caption)
                    .fontWeight(.semibold)
                Spacer()
                Text("\(Int(insight.confidence * 100))%")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Text(insight.recommendation)
                .font(.caption2)
                .foregroundColor(.primary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
    
    private var isLocalIntelligenceAvailable: Bool {
        if #available(iOS 26, *) {
            return true
        }
        return false
    }
}

// MARK: - Extensions

@available(iOS 26, *)
extension CoachMood {
    var displayName: String {
        switch self {
        case .encouraging: return "Encouraging"
        case .motivating: return "Motivating"
        case .supportive: return "Supportive"
        case .celebrating: return "Celebrating"
        case .gentle: return "Gentle"
        case .challenging: return "Challenging"
        }
    }
}

extension TriggerContext {
    var displayName: String {
        switch self {
        case .morningRoutine: return "Morning Routine"
        case .stressfulMoment: return "Stressful Moment"
        case .socialSituation: return "Social Situation"
        case .boredom: return "Boredom"
        case .habitalTiming: return "Habitual Timing"
        case .celebration: return "Celebration"
        }
    }
}

@available(iOS 26, *)
extension PatternInsight.PatternType {
    var displayName: String {
        switch self {
        case .morningCraving: return "Morning Craving"
        case .stressTrigger: return "Stress Trigger"
        case .socialSmoking: return "Social Smoking"
        case .habitualTiming: return "Habitual Timing"
        case .emotionalEating: return "Emotional Smoking"
        case .boredomSmoking: return "Boredom Smoking"
        }
    }
}

@available(iOS 26, *)
#Preview {
    AICoachTestView()
        .modelContainer(for: [UserProfile.self, Cigarette.self], inMemory: true)
}