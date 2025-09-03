import SwiftUI
import SwiftData

struct TodayCigarettesList: View {
    var todayCigarettes: [Cigarette] = []
    var onDelete: (Cigarette) -> Void = { _ in }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with card styling
            VStack(spacing: 0) {
                HStack {
                    Text(NSLocalizedString("todays.cigarettes", comment: ""))
                        .font(DS.Text.headline)
                        .foregroundColor(DS.Colors.textPrimary)
                    Spacer()
                    Text("\(todayCigarettes.count)")
                        .font(DS.Text.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(DS.Colors.primary)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel(String(format: NSLocalizedString("a11y.todays.cigarettes.count", comment: ""), todayCigarettes.count))
                .padding(DS.AdaptiveSpace.md)
                .liquidGlassBackground(backgroundColor: DS.Colors.glassPrimary)
                .cornerRadius(DS.AdaptiveSize.cardRadiusSmall)
                
                if todayCigarettes.isEmpty {
                    // Empty state
                    DSEmptyStateView(
                        title: NSLocalizedString("empty.state.title", comment: ""),
                        subtitle: NSLocalizedString("empty.state.subtitle", comment: ""),
                        icon: "lungs"
                    )
                    .padding(.vertical, DS.Space.lg)
                } else {
                    // Cigarettes list with proper spacing
                    LazyVStack(spacing: 0) {
                        ForEach(todayCigarettes, id: \.id) { cigarette in
                            EnhancedCigaretteRowView(
                                cigarette: cigarette,
                                onDelete: { onDelete(cigarette) }
                            )
                            .liquidGlassBackground(backgroundColor: DS.Colors.glassPrimary)
                            
                            // Divider between rows (except last)
                            if cigarette.id != todayCigarettes.last?.id {
                                Divider()
                                    .background(DS.Colors.glassQuaternary)
                            }
                        }
                    }
                    .padding(.bottom, DS.Space.sm)
                }
            }
            .cornerRadius(DS.AdaptiveSize.cardRadius)
            .dsAdaptiveShadow(.large)
        }
    }
}


#Preview {
    VStack {
        TodayCigarettesList(
            todayCigarettes: [],
            onDelete: { _ in }
        )
        
        TodayCigarettesList(
            todayCigarettes: [
                Cigarette(timestamp: Date(), note: "Test"),
                Cigarette(timestamp: Date().addingTimeInterval(-3600), note: "Test 2")
            ],
            onDelete: { _ in }
        )
    }
    .modelContainer(for: [Cigarette.self, Tag.self], inMemory: true)
    .padding()
}