#if os(iOS)
import SwiftUI
import Charts
import SwiftData

struct AdvancedAnalyticsView: View {
    @Query(sort: \Cigarette.timestamp, order: .reverse) private var allCigarettes: [Cigarette]
    @State private var selectedChart: ChartType = .weekly
    
    enum ChartType: String, CaseIterable, Identifiable {
        case weekly = "settimanale"
        case monthly = "mensile"
        
        var id: String { self.rawValue }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Picker(NSLocalizedString("stats.chartType", comment: ""), selection: $selectedChart) {
                    ForEach(ChartType.allCases) { chartType in
                        Text(NSLocalizedString("stats.\(chartType.rawValue)", comment: "")).tag(chartType)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        if selectedChart == .weekly {
                            WeeklyStatsView(cigarettes: allCigarettes)
                        } else {
                            MonthlyStatsView(cigarettes: allCigarettes)
                        }
                    }
                    .padding()
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(NSLocalizedString("stats.advanced", comment: ""))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Close action
                    }) {
                        Image(systemName: "xmark.circle.fill")
                    }
                }
            }
        }
    }
}

struct MonthlyStatsView: View {
    let cigarettes: [Cigarette]
    
    private var monthlyData: [(month: Date, count: Int)] {
        let calendar = Calendar.current
        let now = Date()
        var months: [(month: Date, count: Int)] = []
        
        for monthOffset in 0..<6 {
            let monthStart = calendar.date(byAdding: .month, value: -monthOffset, to: now)!
            let monthInterval = calendar.dateInterval(of: .month, for: monthStart)!
            
            let count = cigarettes.filter { cigarette in
                monthInterval.contains(cigarette.timestamp)
            }.count
            
            months.append((month: monthStart, count: count))
        }
        
        return months.reversed()
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text(NSLocalizedString("monthly.stats.last.6.months", comment: ""))
                .font(.title2)
                .fontWeight(.bold)
            
            ForEach(monthlyData, id: \.month) { data in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(data.month, format: .dateTime.month(.wide).year())
                            .font(.headline)
                        
                        Text("\(data.count) \(NSLocalizedString("cigarettes", comment: ""))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text("\(data.count)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(colorForCount(data.count))
                }
                .padding()
                .background(AppColors.systemGray6)
                .cornerRadius(12)
            }
        }
    }
    
    private func colorForCount(_ count: Int) -> Color {
        switch count {
        case 0: return .green
        case 1...30: return .blue
        case 31...60: return .orange
        default: return .red
        }
    }
}

struct AdvancedAnalyticsView_Previews: PreviewProvider {
    static var previews: some View {
        AdvancedAnalyticsView()
            .modelContainer(for: [Cigarette.self, Tag.self, UserProfile.self], inMemory: true)
    }
}
#endif