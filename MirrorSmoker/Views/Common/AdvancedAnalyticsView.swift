#if os(iOS)
import SwiftUI
import Charts

struct AdvancedAnalyticsView: View {
    @ObservedObject var cigaretteViewModel: CigaretteViewModel
    @EnvironmentObject var settingsViewModel: SettingsViewModel
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
                            WeeklyStatsView(cigaretteViewModel: cigaretteViewModel)
                        } else {
                            MonthlyStatsView(cigaretteViewModel: cigaretteViewModel)
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
                        // Ação de fechar
                    }) {
                        Image(systemName: "xmark.circle.fill")
                    }
                }
            }
        }
    }
}

struct AdvancedAnalyticsView_Previews: PreviewProvider {
    static var previews: some View {
        AdvancedAnalyticsView(cigaretteViewModel: CigaretteViewModel())
            .environmentObject(SettingsViewModel())
    }
}
#endif