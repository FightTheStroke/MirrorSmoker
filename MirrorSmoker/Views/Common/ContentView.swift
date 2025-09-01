#if os(iOS)
import SwiftUI
import CoreData

struct ContentView: View {
    @StateObject private var cigaretteViewModel: CigaretteViewModel
    @StateObject private var settingsViewModel: SettingsViewModel
    @State private var showingSettings = false
    @State private var showingHistory = false
    @State private var showingTagPicker = false
    @State private var selectedTag: Tag?
    
    init() {
        let persistenceController = PersistenceController.shared
        _cigaretteViewModel = StateObject(wrappedValue: CigaretteViewModel(context: persistenceController.container.viewContext))
        _settingsViewModel = StateObject(wrappedValue: SettingsViewModel())
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(spacing: 20) {
                        DailyStatsHeader(viewModel: cigaretteViewModel)
                        
                        TodayCigarettesList(viewModel: cigaretteViewModel)
                        
                        QuickStatsFooter(viewModel: cigaretteViewModel)
                    }
                    .padding()
                }
                .background(Color(.systemGroupedBackground))
                .navigationTitle(NSLocalizedString("app.title", comment: ""))
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: { showingSettings = true }) {
                            Image(systemName: "gear")
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showingHistory = true }) {
                            Image(systemName: "calendar")
                        }
                    }
                }
                .sheet(isPresented: $showingSettings) {
                    SettingsView(viewModel: settingsViewModel)
                }
                .sheet(isPresented: $showingHistory) {
                    HistoryView(viewModel: cigaretteViewModel)
                }
                .sheet(isPresented: $showingTagPicker) {
                    if let lastCigarette = cigaretteViewModel.cigarettes.first {
                        TagPickerView(cigarette: lastCigarette, viewModel: cigaretteViewModel)
                    }
                }
                
                FloatingActionButton {
                    cigaretteViewModel.addCigarette(tag: selectedTag)
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                    if settingsViewModel.askForTagAfterAdding {
                        showingTagPicker = true
                    }
                }
                .padding(.bottom, 30)
            }
        }
        .environmentObject(settingsViewModel)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif