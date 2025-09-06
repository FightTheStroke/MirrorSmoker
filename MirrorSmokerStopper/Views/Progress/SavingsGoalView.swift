//
//  SavingsGoalView.swift
//  MirrorSmokerStopper
//
//  Created by Assistant on 03/09/25.
//

import SwiftUI

// MARK: - Savings Goal Model
struct SavingsGoal: Identifiable {
    let id = UUID()
    let title: String
    let targetAmount: Double
    let currentAmount: Double
    let targetDate: Date?
    let category: SavingsCategory
    
    var progress: Double {
        guard targetAmount > 0 else { return 0 }
        return min(1.0, currentAmount / targetAmount)
    }
    
    var isCompleted: Bool {
        currentAmount >= targetAmount
    }
    
    var remainingAmount: Double {
        max(0, targetAmount - currentAmount)
    }
    
    var daysRemaining: Int? {
        guard let targetDate = targetDate else { return nil }
        let days = Calendar.current.dateComponents([.day], from: Date(), to: targetDate).day ?? 0
        return max(0, days)
    }
}

enum SavingsCategory: String, CaseIterable {
    case vacation = "vacation"
    case emergency = "emergency" 
    case gadget = "gadget"
    case health = "health"
    case education = "education"
    case custom = "custom"
    
    var icon: String {
        switch self {
        case .vacation: return "airplane.circle.fill"
        case .emergency: return "shield.fill"
        case .gadget: return "laptopcomputer"
        case .health: return "heart.circle.fill"
        case .education: return "book.circle.fill"
        case .custom: return "star.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .vacation: return DS.Colors.tagSocial
        case .emergency: return DS.Colors.smokingProgressHigh
        case .gadget: return DS.Colors.primary
        case .health: return DS.Colors.healthImprovement
        case .education: return DS.Colors.motivationInspiring
        case .custom: return DS.Colors.smokingProgressCaution
        }
    }
}

// MARK: - Savings Goal View
struct SavingsGoalView: View {
    let goal: SavingsGoal
    @State private var showGoalEditor = false
    @State private var animateProgress = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.AdaptiveSpace.lg) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: DS.AdaptiveSpace.xs) {
                    Text("savings.goal".local())
                        .font(DS.Text.title3)
                        .foregroundColor(DS.Colors.textPrimary)
                    
                    if let daysRemaining = goal.daysRemaining {
                        Text(String(format: "savings.days.remaining".local(), daysRemaining))
                            .font(DS.Text.caption)
                            .foregroundColor(DS.Colors.textSecondary)
                    }
                }
                
                Spacer()
                
                Menu {
                    Button("savings.edit.goal".local()) {
                        showGoalEditor = true
                    }
                    Button("savings.set.new.goal".local()) {
                        showGoalEditor = true
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.title2)
                        .foregroundColor(DS.Colors.primary)
                }
            }
            
            // Goal info
            HStack(spacing: DS.AdaptiveSpace.sm) {
                Image(systemName: goal.category.icon)
                    .font(.title2)
                    .foregroundColor(goal.category.color)
                
                VStack(alignment: .leading, spacing: DS.AdaptiveSpace.xs) {
                    Text(goal.title.local())
                        .font(DS.Text.headline)
                        .foregroundColor(DS.Colors.textPrimary)
                    
                    if goal.isCompleted {
                        HStack(spacing: DS.AdaptiveSpace.xs) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(DS.Colors.smokingProgressExcellent)
                            Text("savings.goal.completed".local())
                                .font(DS.Text.caption)
                                .foregroundColor(DS.Colors.smokingProgressExcellent)
                        }
                    }
                }
                
                Spacer()
            }
            
            // Amount display
            HStack(alignment: .firstTextBaseline, spacing: DS.AdaptiveSpace.sm) {
                Text(formatCurrency(goal.currentAmount))
                    .font(DS.Text.display)
                    .foregroundColor(goal.isCompleted ? DS.Colors.smokingProgressExcellent : DS.Colors.primary)
                    .fontWeight(.bold)
                
                Text("/")
                    .font(DS.Text.title2)
                    .foregroundColor(DS.Colors.textTertiary)
                
                Text(formatCurrency(goal.targetAmount))
                    .font(DS.Text.title2)
                    .foregroundColor(DS.Colors.textSecondary)
                
                Spacer()
                
                // Percentage
                Text("\(Int(goal.progress * 100))%")
                    .font(DS.Text.title3)
                    .foregroundColor(DS.Colors.primary)
                    .padding(.horizontal, DS.AdaptiveSpace.sm)
                    .padding(.vertical, DS.AdaptiveSpace.xs)
                    .background(DS.Colors.primary.opacity(0.1))
                    .clipShape(Capsule())
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: 6)
                        .fill(DS.Colors.glassTertiary)
                        .frame(height: 12)
                    
                    // Progress fill with gradient
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: goal.isCompleted ? 
                                    [DS.Colors.smokingProgressExcellent, DS.Colors.smokingProgressGood] :
                                    [goal.category.color.opacity(0.8), goal.category.color],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: geometry.size.width * (animateProgress ? goal.progress : 0),
                            height: 12
                        )
                        .animation(DS.Animation.spring.delay(0.3), value: animateProgress)
                    
                    // Glow effect for completed goals
                    if goal.isCompleted {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(DS.Colors.smokingProgressExcellent.opacity(0.3))
                            .frame(width: geometry.size.width * goal.progress, height: 12)
                            .blur(radius: 2)
                    }
                }
            }
            .frame(height: 12)
            .onAppear {
                withAnimation(DS.Animation.spring.delay(0.5)) {
                    animateProgress = true
                }
            }
            
            // Remaining amount info
            if !goal.isCompleted {
                HStack {
                    Text(String(format: "savings.remaining".local(), formatCurrency(goal.remainingAmount)))
                        .font(DS.Text.body)
                        .foregroundColor(DS.Colors.textSecondary)
                    
                    Spacer()
                    
                    if let targetDate = goal.targetDate {
                        Text(targetDate, style: .date)
                            .font(DS.Text.caption)
                            .foregroundColor(DS.Colors.textTertiary)
                    }
                }
            }
        }
        .padding(DS.AdaptiveSpace.lg)
        .liquidGlassCard(elevation: DS.Shadow.medium)
        .overlay(
            // Completion celebration border
            RoundedRectangle(cornerRadius: DS.AdaptiveSize.cardRadius)
                .strokeBorder(
                    goal.isCompleted ? DS.Colors.smokingProgressExcellent : Color.clear,
                    lineWidth: goal.isCompleted ? 2 : 0
                )
                .animation(DS.Animation.spring, value: goal.isCompleted)
        )
        .sheet(isPresented: $showGoalEditor) {
            SavingsGoalEditorView(goal: goal)
        }
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = Locale.current.currency?.identifier ?? "EUR"
        formatter.maximumFractionDigits = amount >= 100 ? 0 : 2
        return formatter.string(from: NSNumber(value: amount)) ?? "€\(Int(amount))"
    }
}

// MARK: - Savings Overview
struct SavingsOverview: View {
    let goals: [SavingsGoal]
    @State private var selectedGoal: SavingsGoal?
    @State private var showAddGoal = false
    
    var totalSaved: Double {
        goals.reduce(0) { $0 + $1.currentAmount }
    }
    
    var completedGoals: Int {
        goals.filter { $0.isCompleted }.count
    }
    
    var body: some View {
        VStack(spacing: DS.AdaptiveSpace.lg) {
            // Summary header
            HStack {
                VStack(alignment: .leading, spacing: DS.AdaptiveSpace.xs) {
                    Text("savings.overview".local())
                        .font(DS.Text.title2)
                        .foregroundColor(DS.Colors.textPrimary)
                    
                    HStack(spacing: DS.AdaptiveSpace.lg) {
                        VStack(alignment: .leading) {
                            Text(formatCurrency(totalSaved))
                                .font(DS.Text.title3)
                                .foregroundColor(DS.Colors.smokingProgressGood)
                            Text("savings.total.saved".local())
                                .font(DS.Text.caption)
                                .foregroundColor(DS.Colors.textSecondary)
                        }
                        
                        VStack(alignment: .leading) {
                            Text("\(completedGoals)")
                                .font(DS.Text.title3)
                                .foregroundColor(DS.Colors.primary)
                            Text("savings.goals.completed".local())
                                .font(DS.Text.caption)
                                .foregroundColor(DS.Colors.textSecondary)
                        }
                    }
                }
                
                Spacer()
                
                Button("savings.add.goal".local()) {
                    showAddGoal = true
                }
                .font(DS.Text.body)
                .foregroundColor(DS.Colors.primary)
            }
            
            // Goals list
            if goals.isEmpty {
                EmptySavingsView()
            } else {
                LazyVStack(spacing: DS.AdaptiveSpace.md) {
                    ForEach(goals) { goal in
                        SavingsGoalView(goal: goal)
                    }
                }
            }
        }
        .sheet(isPresented: $showAddGoal) {
            AddSavingsGoalView()
        }
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = Locale.current.currency?.identifier ?? "EUR"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "€\(Int(amount))"
    }
}

// MARK: - Empty Savings View
struct EmptySavingsView: View {
    var body: some View {
        VStack(spacing: DS.AdaptiveSpace.lg) {
            Image(systemName: "piggybank")
                .font(.system(size: 48))
                .foregroundColor(DS.Colors.textTertiary)
            
            VStack(spacing: DS.AdaptiveSpace.sm) {
                Text("savings.empty.title".local())
                    .font(DS.Text.headline)
                    .foregroundColor(DS.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text("savings.empty.subtitle".local())
                    .font(DS.Text.body)
                    .foregroundColor(DS.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
        .liquidGlassCard(elevation: DS.Shadow.small)
    }
}

// MARK: - Savings Goal Editor View
struct SavingsGoalEditorView: View {
    let goal: SavingsGoal
    @Environment(\.dismiss) private var dismiss
    @State private var title: String = ""
    @State private var targetAmount: String = ""
    @State private var targetDate: Date = Date()
    @State private var hasTargetDate: Bool = false
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("progress.goal.title".local(), text: $title)
                    
                    HStack {
                        Text("progress.goal.target".local())
                        Spacer()
                        TextField("0", text: $targetAmount)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    Toggle("progress.goal.has.deadline".local(), isOn: $hasTargetDate)
                    
                    if hasTargetDate {
                        DatePicker("progress.goal.deadline".local(),
                                 selection: $targetDate,
                                 displayedComponents: [.date])
                    }
                }
                
                Section {
                    HStack {
                        Text("progress.goal.current".local())
                        Spacer()
                        Text(formatCurrency(goal.currentAmount))
                            .foregroundColor(DS.Colors.textSecondary)
                    }
                    
                    HStack {
                        Text("progress.goal.remaining".local())
                        Spacer()
                        Text(formatCurrency(goal.targetAmount - goal.currentAmount))
                            .foregroundColor(DS.Colors.primary)
                    }
                    
                    if goal.progress > 0 {
                        HStack {
                            Text("progress.goal.completion".local())
                            Spacer()
                            Text("\(Int(goal.progress * 100))%")
                                .foregroundColor(DS.Colors.smokingProgressGood)
                        }
                    }
                }
            }
            .navigationTitle("progress.goal.edit".local())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("button.cancel".local()) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("button.save".local()) {
                        saveGoal()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            title = goal.title
            targetAmount = String(format: "%.2f", goal.targetAmount)
            if let date = goal.targetDate {
                targetDate = date
                hasTargetDate = true
            }
        }
    }
    
    private func saveGoal() {
        // Implementation would save to SwiftData
        // For now, this is a placeholder
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = Locale.current.currency?.identifier ?? "EUR"
        return formatter.string(from: NSNumber(value: amount)) ?? "€\(Int(amount))"
    }
}

// MARK: - Add Savings Goal View
struct AddSavingsGoalView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var title: String = ""
    @State private var targetAmount: String = ""
    @State private var targetDate: Date = Date()
    @State private var hasTargetDate: Bool = false
    @State private var selectedCategory: SavingsCategory = .custom
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("progress.goal.title.placeholder".local(), text: $title)
                    
                    HStack {
                        Text("progress.goal.target.amount".local())
                        Spacer()
                        TextField("0", text: $targetAmount)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    Picker("progress.goal.category".local(), selection: $selectedCategory) {
                        ForEach(SavingsCategory.allCases, id: \.self) { category in
                            Label(category.rawValue.capitalized, systemImage: category.icon)
                                .tag(category)
                        }
                    }
                    
                    Toggle("progress.goal.set.deadline".local(), isOn: $hasTargetDate)
                    
                    if hasTargetDate {
                        DatePicker("progress.goal.target.date".local(),
                                 selection: $targetDate,
                                 in: Date()...,
                                 displayedComponents: [.date])
                    }
                }
                
                Section {
                    Text("progress.goal.tip".local())
                        .font(DS.Text.caption)
                        .foregroundColor(DS.Colors.textSecondary)
                }
            }
            .navigationTitle("progress.goal.add.new".local())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("button.cancel".local()) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("button.add".local()) {
                        addGoal()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(title.isEmpty || targetAmount.isEmpty)
                }
            }
        }
    }
    
    private func addGoal() {
        guard !title.isEmpty,
              let amount = Double(targetAmount) else { return }
        
        // Create and save the goal
        // This would integrate with your SwiftData model
        // For now, it's a placeholder
    }
}

// MARK: - Preview
#Preview {
    ScrollView {
        VStack(spacing: DS.AdaptiveSpace.xl) {
            SavingsOverview(goals: [
                SavingsGoal(
                    title: "savings.vacation.italy",
                    targetAmount: 1200,
                    currentAmount: 850,
                    targetDate: Calendar.current.date(byAdding: .month, value: 4, to: Date()),
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
                    targetDate: Calendar.current.date(byAdding: .month, value: 8, to: Date()),
                    category: .gadget
                )
            ])
        }
        .padding()
    }
    .background(DS.Colors.backgroundSecondary)
}