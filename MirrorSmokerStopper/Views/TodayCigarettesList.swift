import SwiftUI
import SwiftData

struct TodayCigarettesList: View {
    var todayCigarettes: [Cigarette] = []
    var onDelete: (Cigarette) -> Void = { _ in }
    var onAddTags: (Cigarette) -> Void = { _ in }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Space.md) {
            // Header
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
            
            if todayCigarettes.isEmpty {
                // Empty state
                VStack(spacing: DS.Space.md) {
                    Image(systemName: "lungs")
                        .font(.system(size: 48))
                        .foregroundColor(DS.Colors.textSecondary)
                    
                    Text(NSLocalizedString("empty.state.title", comment: ""))
                        .font(DS.Text.headline)
                        .foregroundColor(DS.Colors.textPrimary)
                    
                    Text(NSLocalizedString("empty.state.subtitle", comment: ""))
                        .font(DS.Text.body)
                        .foregroundColor(DS.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, DS.Space.xl)
            } else {
                // Simple List - no custom shit
                List {
                    ForEach(todayCigarettes, id: \.id) { cigarette in
                        SimpleCigaretteRowView(cigarette: cigarette)
                            .swipeActions(edge: .trailing) {
                                Button("delete".local(), role: .destructive) {
                                    onDelete(cigarette)
                                }
                            }
                            .swipeActions(edge: .leading) {
                                Button("add.tags".local()) {
                                    onAddTags(cigarette)
                                }
                                .tint(.blue)
                            }
                    }
                    .listRowInsets(EdgeInsets())
                }
                .listStyle(.plain)
                .frame(height: CGFloat(todayCigarettes.count * 50))
            }
        }
        .padding(DS.Space.md)
        .background(DS.Colors.card)
        .cornerRadius(DS.AdaptiveSize.cardRadius)
    }
}

// Simple row without custom shit
struct SimpleCigaretteRowView: View {
    let cigarette: Cigarette
    
    var body: some View {
        HStack {
            Image(systemName: "lungs.fill")
                .foregroundColor(DS.Colors.cigarette)
                Text(cigarette.timestamp, style: .time)
                    .font(DS.Text.headline)
                    .foregroundColor(DS.Colors.textPrimary)
                Spacer()
                if let tags = cigarette.tags, !tags.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(Array(tags.prefix(3)), id: \.id) { tag in
                            Text(tag.name)
                                .font(DS.Text.micro)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color(hex: tag.colorHex) ?? DS.Colors.primary)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        if tags.count > 3 {
                            Text("+\(tags.count - 3)")
                                .font(DS.Text.micro)
                                .foregroundColor(DS.Colors.textSecondary)
                        }
                    }
            }
        }
        .contentShape(Rectangle())
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
