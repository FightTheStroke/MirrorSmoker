import SwiftUI

struct SettingsView: View {
    // Supponi di avere @State per i tuoi valori
    @State var profileName: String = ""
    @State var profileBirthDate = Date()
    
    // ...
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DS.Space.lg) {
                    DSCard {
                        DSSectionHeader(NSLocalizedString("settings.title", comment: ""))
                        Form {
                            Section(header: Text(NSLocalizedString("settings.profile", comment: ""))) {
                                TextField(NSLocalizedString("settings.name", comment: ""), text: $profileName)
                                    .textInputAutocapitalization(.words)
                                DatePicker(NSLocalizedString("settings.birth.date", comment: ""), selection: $profileBirthDate, displayedComponents: .date)
                            }
                            // Altri settings...
                            Section(header: Text(NSLocalizedString("settings.health.insights", comment: ""))) {
                                HStack {
                                    Image(systemName: "heart")
                                        .foregroundColor(.red)
                                    Text(NSLocalizedString("health.insights.general.info", comment: ""))
                                }
                            }
                        }
                        DSButton(NSLocalizedString("settings.save.changes", comment: ""), style: .primary) {
                            // saveProfile()
                        }
                    }
                }
                .padding(DS.Space.lg)
            }
            .background(DS.Colors.background)
            .navigationTitle(NSLocalizedString("settings.title", comment: ""))
        }
    }
}