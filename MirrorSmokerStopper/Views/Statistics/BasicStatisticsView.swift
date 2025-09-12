import SwiftUI
import SwiftData

/// Basic statistics view for SIMPLE version - essential stats only
struct BasicStatisticsView: View {
    @Query(sort: \Cigarette.timestamp, order: .reverse) private var cigarettes: [Cigarette]
    @State private var showingUpgradeSheet = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Basic Progress Summary
                basicProgressCard
                
                // Essential Stats Grid
                essentialStatsGrid
                
                // Health Benefits Timeline
                healthBenefitsCard
                
                // Upgrade Prompt
                upgradePromptCard
            }
            .padding()
        }
        .navigationTitle("Statistics")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingUpgradeSheet) {
            upgradeSheet
        }
    }
    
    // MARK: - Basic Progress Card
    
    private var basicProgressCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.green)
                    .font(.title2)
                
                Text("Your Journey")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("\(daysSmokeFreeSoFar)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.green)
                
                Text("days smoke-free")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Text("Keep going! Every day counts toward your healthier future.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Essential Stats Grid
    
    private var essentialStatsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            // Money Saved
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "dollarsign.circle.fill")
                        .foregroundColor(.green)
                    Text("Saved")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text("$\(totalMoneySaved, specifier: "%.0f")")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            .padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Cigarettes Not Smoked
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.red)
                    Text("Avoided")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text("\(cigarettesAvoided)")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            .padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Life Regained
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.pink)
                    Text("Life Gained")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text("\(lifeTimeRegained) hrs")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            .padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Streak
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                    Text("Best Streak")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text("\(longestStreak) days")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            .padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    // MARK: - Health Benefits Card
    
    private var healthBenefitsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "heart.circle.fill")
                    .foregroundColor(.red)
                    .font(.title2)
                
                Text("Health Recovery")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                ForEach(getBasicHealthBenefits(), id: \.title) { benefit in
                    HStack {
                        Image(systemName: benefit.achieved ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(benefit.achieved ? .green : .gray)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(benefit.title)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text(benefit.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if !benefit.achieved {
                            Text(benefit.timeToAchieve)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Upgrade Prompt Card
    
    private var upgradePromptCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.purple)
                    .font(.title2)
                
                Text("Want More Insights?")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            Text("Upgrade to Mirror Smoker Pro for:")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 8) {
                featureRow("🧠", "AI-powered coaching")
                featureRow("📊", "Advanced analytics")
                featureRow("💓", "Heart rate monitoring")
                featureRow("🎯", "Trigger pattern analysis")
                featureRow("📈", "Detailed progress charts")
            }
            
            Button(action: {
                showingUpgradeSheet = true
            }) {
                Text("Learn More")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.purple)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Helper Views
    
    private func featureRow(_ icon: String, _ text: String) -> some View {
        HStack(spacing: 8) {
            Text(icon)
            Text(text)
                .font(.subheadline)
            Spacer()
        }
    }
    
    private var upgradeSheet: some View {
        VStack(spacing: 24) {
            Text("Mirror Smoker Pro")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Unlock the full potential of your quit smoking journey")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            // Feature list would go here
            
            Button("Maybe Later") {
                showingUpgradeSheet = false
            }
            .padding()
        }
        .padding()
    }
    
    // MARK: - Data Helpers
    
    // MARK: - Computed Properties
    
    private var daysSmokeFreeSoFar: Int {
        // Calculate days since quit - basic implementation
        if let lastCigarette = cigarettes.first {
            return Calendar.current.dateComponents([.day], from: lastCigarette.timestamp, to: Date()).day ?? 0
        } else {
            // No cigarettes recorded, assume they haven't started tracking yet
            return 0
        }
    }
    
    private var totalMoneySaved: Double {
        // Basic calculation - could be improved with actual user data
        return Double(daysSmokeFreeSoFar) * 15.0 // Assume $15/day average
    }
    
    private var cigarettesAvoided: Int {
        // Basic calculation
        return daysSmokeFreeSoFar * 20 // Assume 1 pack per day average
    }
    
    private var lifeTimeRegained: Int {
        // Basic calculation - 11 minutes per cigarette
        return (cigarettesAvoided * 11) / 60 // Convert to hours
    }
    
    private var longestStreak: Int {
        // For simplicity, return current streak
        return daysSmokeFreeSoFar
    }
    
    private func getBasicHealthBenefits() -> [BasicHealthBenefit] {
        let daysQuit = daysSmokeFreeSoFar
        
        return [
            BasicHealthBenefit(
                title: "Better circulation",
                description: "Blood flow improves",
                timeToAchieve: "2-12 weeks",
                achieved: daysQuit >= 14
            ),
            BasicHealthBenefit(
                title: "Improved lung function",
                description: "Breathing becomes easier",
                timeToAchieve: "1-3 months",
                achieved: daysQuit >= 30
            ),
            BasicHealthBenefit(
                title: "Reduced infection risk",
                description: "Immune system strengthens",
                timeToAchieve: "1-9 months",
                achieved: daysQuit >= 90
            ),
            BasicHealthBenefit(
                title: "Heart attack risk drops",
                description: "Significantly lower risk",
                timeToAchieve: "1 year",
                achieved: daysQuit >= 365
            )
        ]
    }
}

// MARK: - Supporting Types

private struct BasicHealthBenefit {
    let title: String
    let description: String
    let timeToAchieve: String
    let achieved: Bool
}

#Preview {
    NavigationView {
        BasicStatisticsView()
    }
    .modelContainer(for: Cigarette.self)
}