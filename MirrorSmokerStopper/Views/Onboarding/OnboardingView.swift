//
//  OnboardingView.swift
//  MirrorSmokerStopper
//
//  Created by Claude on 05/09/25.
//

import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @StateObject private var healthKitManager = HealthKitManager()
    
    @State private var currentPage = 0
    @State private var userName = ""
    @State private var dailyCigarettes = ""
    @State private var pricePerPack = ""
    @State private var cigarettesPerPack = "20"
    @State private var quitDate: Date?
    @State private var enableAICoach = true
    @State private var showingHealthKitPermission = false
    
    private let totalPages = 5
    
    var body: some View {
        VStack(spacing: 0) {
            // Progress Indicator
            ProgressView()
                .progressViewStyle(LinearProgressViewStyle(tint: DS.Colors.primary))
                .padding(.horizontal)
                .padding(.top)
            
            // Content
            TabView(selection: $currentPage) {
                welcomePage.tag(0)
                profileSetupPage.tag(1)
                smokingHabitsPage.tag(2)
                aiCoachPage.tag(3)
                completionPage.tag(4)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentPage)
            
            // Navigation Buttons
            navigationButtons
                .padding()
                .background(DS.Colors.backgroundSecondary)
        }
        .sheet(isPresented: $showingHealthKitPermission) {
            OnboardingHealthKitPermissionView(healthKitManager: healthKitManager)
        }
    }
    
    // MARK: - Pages
    
    private var welcomePage: some View {
        VStack(spacing: DS.Space.xl) {
            Spacer()
            
            Image(systemName: "heart.text.square.fill")
                .font(.system(size: 80))
                .foregroundColor(DS.Colors.primary)
            
            Text("onboarding.welcome.title".local())
                .font(DS.Text.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("onboarding.welcome.subtitle".local())
                .font(DS.Text.body)
                .foregroundColor(DS.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DS.Space.xl)
            
            Spacer()
            
            VStack(alignment: .leading, spacing: DS.Space.md) {
                featureRow(icon: "brain.head.profile", text: "onboarding.feature.ai".local())
                featureRow(icon: "heart.fill", text: "onboarding.feature.health".local())
                featureRow(icon: "chart.line.uptrend.xyaxis", text: "onboarding.feature.stats".local())
                featureRow(icon: "bell.badge", text: "onboarding.feature.notifications".local())
            }
            .padding(.horizontal, DS.Space.xl)
            
            Spacer()
        }
    }
    
    private var profileSetupPage: some View {
        VStack(spacing: DS.Space.xl) {
            Spacer()
            
            Text("onboarding.profile.title".local())
                .font(DS.Text.title)
                .multilineTextAlignment(.center)
            
            Text("onboarding.profile.subtitle".local())
                .font(DS.Text.body)
                .foregroundColor(DS.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DS.Space.xl)
            
            VStack(spacing: DS.Space.lg) {
                TextField("onboarding.profile.name".local(), text: $userName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(DS.Text.body)
                
                if let quitDate = quitDate {
                    HStack {
                        Text("onboarding.profile.quit.date".local())
                            .font(DS.Text.body)
                        Spacer()
                        Text(quitDate, style: .date)
                            .font(DS.Text.body)
                            .fontWeight(.medium)
                            .foregroundColor(DS.Colors.primary)
                    }
                    .padding()
                    .background(DS.Colors.cardSecondary)
                    .cornerRadius(8)
                } else {
                    Button(action: { quitDate = Date() }) {
                        HStack {
                            Image(systemName: "calendar")
                            Text("onboarding.profile.set.quit.date".local())
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(DS.Colors.primary.opacity(0.1))
                        .foregroundColor(DS.Colors.primary)
                        .cornerRadius(8)
                    }
                }
            }
            .padding(.horizontal, DS.Space.xl)
            
            Spacer()
        }
    }
    
    private var smokingHabitsPage: some View {
        VStack(spacing: DS.Space.xl) {
            Spacer()
            
            Text("onboarding.habits.title".local())
                .font(DS.Text.title)
                .multilineTextAlignment(.center)
            
            Text("onboarding.habits.subtitle".local())
                .font(DS.Text.body)
                .foregroundColor(DS.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DS.Space.xl)
            
            VStack(spacing: DS.Space.lg) {
                VStack(alignment: .leading, spacing: DS.Space.xs) {
                    Text("onboarding.habits.daily".local())
                        .font(DS.Text.caption)
                        .foregroundColor(DS.Colors.textSecondary)
                    TextField("15", text: $dailyCigarettes)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                        .font(DS.Text.body)
                }
                
                VStack(alignment: .leading, spacing: DS.Space.xs) {
                    Text("onboarding.habits.pack.price".local())
                        .font(DS.Text.caption)
                        .foregroundColor(DS.Colors.textSecondary)
                    TextField("7.50", text: $pricePerPack)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                        .font(DS.Text.body)
                }
                
                VStack(alignment: .leading, spacing: DS.Space.xs) {
                    Text("onboarding.habits.pack.size".local())
                        .font(DS.Text.caption)
                        .foregroundColor(DS.Colors.textSecondary)
                    TextField("20", text: $cigarettesPerPack)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                        .font(DS.Text.body)
                }
            }
            .padding(.horizontal, DS.Space.xl)
            
            Spacer()
        }
    }
    
    private var aiCoachPage: some View {
        VStack(spacing: DS.Space.xl) {
            Spacer()
            
            Image(systemName: "brain")
                .font(.system(size: 60))
                .foregroundColor(DS.Colors.primary)
            
            Text("onboarding.ai.title".local())
                .font(DS.Text.title)
                .multilineTextAlignment(.center)
            
            Text("onboarding.ai.subtitle".local())
                .font(DS.Text.body)
                .foregroundColor(DS.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DS.Space.xl)
            
            Toggle(isOn: $enableAICoach) {
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundColor(DS.Colors.primary)
                    VStack(alignment: .leading, spacing: DS.Space.xs) {
                        Text("onboarding.ai.enable".local())
                            .font(DS.Text.body)
                            .fontWeight(.medium)
                        Text("onboarding.ai.description".local())
                            .font(DS.Text.caption)
                            .foregroundColor(DS.Colors.textSecondary)
                    }
                }
            }
            .padding()
            .background(DS.Colors.cardSecondary)
            .cornerRadius(12)
            .padding(.horizontal, DS.Space.xl)
            
            if enableAICoach {
                Button(action: { showingHealthKitPermission = true }) {
                    HStack {
                        Image(systemName: "heart.fill")
                        Text("onboarding.ai.setup.healthkit".local())
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(DS.Colors.primary)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding(.horizontal, DS.Space.xl)
            }
            
            Spacer()
        }
    }
    
    private var completionPage: some View {
        VStack(spacing: DS.Space.xl) {
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(DS.Colors.success)
            
            Text("onboarding.complete.title".local())
                .font(DS.Text.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("onboarding.complete.subtitle".local())
                .font(DS.Text.body)
                .foregroundColor(DS.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DS.Space.xl)
            
            Spacer()
            
            VStack(spacing: DS.Space.md) {
                if !userName.isEmpty {
                    HStack {
                        Image(systemName: "person.fill")
                        Text(userName)
                        Spacer()
                    }
                    .padding()
                    .background(DS.Colors.cardSecondary)
                    .cornerRadius(8)
                }
                
                if !dailyCigarettes.isEmpty {
                    HStack {
                        Image(systemName: "flame.fill")
                        Text("\(dailyCigarettes) " + "onboarding.complete.daily".local())
                        Spacer()
                    }
                    .padding()
                    .background(DS.Colors.cardSecondary)
                    .cornerRadius(8)
                }
                
                if enableAICoach {
                    HStack {
                        Image(systemName: "brain")
                        Text("onboarding.complete.ai.enabled".local())
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(DS.Colors.success)
                    }
                    .padding()
                    .background(DS.Colors.cardSecondary)
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal, DS.Space.xl)
            
            Spacer()
        }
    }
    
    // MARK: - Components
    
    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: DS.Space.md) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(DS.Colors.primary)
                .frame(width: 30)
            
            Text(text)
                .font(DS.Text.body)
                .foregroundColor(DS.Colors.textPrimary)
            
            Spacer()
        }
    }
    
    private var navigationButtons: some View {
        HStack {
            if currentPage > 0 {
                Button(action: { currentPage -= 1 }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("onboarding.button.back".local())
                    }
                    .font(DS.Text.body)
                    .fontWeight(.medium)
                }
            }
            
            Spacer()
            
            if currentPage < totalPages - 1 {
                Button(action: { 
                    withAnimation {
                        currentPage += 1
                    }
                }) {
                    HStack {
                        Text("onboarding.button.next".local())
                        Image(systemName: "chevron.right")
                    }
                    .font(DS.Text.body)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, DS.Space.lg)
                    .padding(.vertical, DS.Space.sm)
                    .background(DS.Colors.primary)
                    .cornerRadius(20)
                }
            } else {
                Button(action: completeOnboarding) {
                    Text("onboarding.button.start".local())
                        .font(DS.Text.body)
                    .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DS.Space.md)
                        .background(DS.Colors.primary)
                        .cornerRadius(12)
                }
            }
        }
    }
    
    // MARK: - Actions
    
    private func completeOnboarding() {
        // Save user profile
        if !userName.isEmpty || !dailyCigarettes.isEmpty {
            let profile = UserProfile(name: userName)
            
            if let daily = Double(dailyCigarettes) {
                profile.dailyAverage = daily
            }
            
            if let price = Double(pricePerPack) {
                // Store pack price in UserDefaults or appropriate storage
                UserDefaults.standard.set(price, forKey: "packPrice")
            }
            
            if let packSize = Int(cigarettesPerPack) {
                // Store cigarettes per pack in UserDefaults
                UserDefaults.standard.set(packSize, forKey: "cigarettesPerPack")
            }
            
            if let quitDate = quitDate {
                profile.quitDate = quitDate
            }
            
            modelContext.insert(profile)
            
            // Enable AI Coach if selected
            if enableAICoach {
                AIConfiguration.shared.isAICoachingEnabled = true
            }
            
            do {
                try modelContext.save()
            } catch {
                // Handle error
            }
        }
        
        // Mark onboarding as complete
        hasCompletedOnboarding = true
        dismiss()
    }
}

// MARK: - HealthKit Permission View

struct OnboardingHealthKitPermissionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var healthKitManager: HealthKitManager
    @State private var permissionGranted = false
    
    var body: some View {
        VStack(spacing: DS.Space.xl) {
            Spacer()
            
            Image(systemName: "heart.text.square.fill")
                .font(.system(size: 60))
                .foregroundColor(DS.Colors.primary)
            
            Text("onboarding.healthkit.title".local())
                .font(DS.Text.title)
                .multilineTextAlignment(.center)
            
            Text("onboarding.healthkit.description".local())
                .font(DS.Text.body)
                .foregroundColor(DS.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DS.Space.xl)
            
            VStack(alignment: .leading, spacing: DS.Space.md) {
                permissionRow(icon: "heart.fill", text: "onboarding.healthkit.heart.rate".local())
                permissionRow(icon: "figure.walk", text: "onboarding.healthkit.activity".local())
                permissionRow(icon: "bed.double.fill", text: "onboarding.healthkit.sleep".local())
            }
            .padding(DS.Space.lg)
            .background(DS.Colors.cardSecondary)
            .cornerRadius(12)
            .padding(.horizontal, DS.Space.xl)
            
            Spacer()
            
            Button(action: requestHealthKitPermission) {
                Text(permissionGranted ? "onboarding.healthkit.granted".local() : "onboarding.healthkit.request".local())
                    .font(DS.Text.body)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DS.Space.md)
                    .background(permissionGranted ? DS.Colors.success : DS.Colors.primary)
                    .cornerRadius(12)
            }
            .padding(.horizontal, DS.Space.xl)
            .disabled(permissionGranted)
            
            Button(action: { dismiss() }) {
                Text("onboarding.healthkit.skip".local())
                    .font(DS.Text.body)
                    .foregroundColor(DS.Colors.textSecondary)
            }
            .padding(.bottom, DS.Space.xl)
        }
    }
    
    private func permissionRow(icon: String, text: String) -> some View {
        HStack(spacing: DS.Space.md) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(DS.Colors.primary)
                .frame(width: 25)
            
            Text(text)
                .font(DS.Text.body)
                .foregroundColor(DS.Colors.textPrimary)
            
            Spacer()
        }
    }
    
    private func requestHealthKitPermission() {
        Task {
            do {
                try await healthKitManager.requestAuthorization()
                permissionGranted = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    dismiss()
                }
            } catch {
                // Handle error
            }
        }
    }
}

#Preview {
    OnboardingView()
}