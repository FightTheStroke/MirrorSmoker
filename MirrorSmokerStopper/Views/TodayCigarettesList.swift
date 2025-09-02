import SwiftUI
import SwiftData

struct TodayCigarettesList: View {
    var todayCigarettes: [Cigarette] = []
    var onDelete: (Cigarette) -> Void = { _ in }
    var onAddTags: (Cigarette) -> Void = { _ in }
    
    var body: some View {
        DSCard(variant: .plain, elevation: .small) {
            VStack(spacing: 0) {
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
                .padding(DS.Space.md)
                .padding(.bottom, DS.Space.xs)
                
                if todayCigarettes.isEmpty {
                    // Empty state
                    VStack(spacing: DS.Space.sm) {
                        Image(systemName: "lungs")
                            .font(.largeTitle)
                            .foregroundColor(DS.Colors.textSecondary)
                        Text(NSLocalizedString("empty.state.title", comment: ""))
                            .font(DS.Text.body)
                            .foregroundColor(DS.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(DS.Space.xl)
                } else {
                    // List with cigarettes
                    List {
                        ForEach(todayCigarettes, id: \.id) { cigarette in
                            CigaretteRowView(
                                cigarette: cigarette,
                                onDelete: { onDelete(cigarette) },
                                onAddTags: { onAddTags(cigarette) }
                            )
                        }
                    }
                    .listStyle(.plain)
                    .frame(minHeight: CGFloat(todayCigarettes.count) * 60)
                    .frame(maxHeight: 300) // Limit height for long lists
                }
            }
        }
    }
}

// Separate row component for cleaner code
struct CigaretteRowView: View {
    let cigarette: Cigarette
    let onDelete: () -> Void
    let onAddTags: () -> Void
    
    var body: some View {
        HStack(spacing: DS.Space.md) {
            // Cigarette icon
            Image(systemName: "lungs.fill")
                .foregroundColor(DS.Colors.cigarette)
                .font(.system(size: DS.Size.iconSize))
            
            // Time
            Text(cigarette.timestamp, format: .dateTime.hour().minute())
                .font(DS.Text.body)
                .fontWeight(.medium)
                .foregroundColor(DS.Colors.textPrimary)
            
            Spacer()
            
            // Tags
            if let tags = cigarette.tags, !tags.isEmpty {
                HStack(spacing: DS.Space.xs) {
                    ForEach(tags.prefix(3), id: \.id) { tag in
                        Text(tag.name)
                            .font(DS.Text.caption2)
                            .padding(.horizontal, DS.Space.xs)
                            .padding(.vertical, 2)
                            .background(tag.color)
                            .foregroundColor(.white)
                            .cornerRadius(6)
                    }
                    
                    if tags.count > 3 {
                        Text(NSLocalizedString("plus.more.tags", comment: ""), tags.count - 3)
                            .font(DS.Text.caption2)
                            .padding(.horizontal, DS.Space.xs)
                            .padding(.vertical, 2)
                            .background(DS.Colors.backgroundSecondary)
                            .foregroundColor(DS.Colors.textSecondary)
                            .cornerRadius(6)
                    }
                }
            }
        }
        .padding(.vertical, DS.Space.xs)
        .swipeActions(edge: .leading) {
            Button {
                onAddTags()
            } label: {
                Label(NSLocalizedString("add.tags", comment: ""), systemImage: "tag")
            }
            .tint(DS.Colors.primary)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label(NSLocalizedString("delete", comment: ""), systemImage: "trash")
            }
        }
    }
}

#Preview {
    VStack {
        TodayCigarettesList(
            todayCigarettes: [],
            onDelete: { _ in },
            onAddTags: { _ in }
        )
        
        TodayCigarettesList(
            todayCigarettes: [
                Cigarette(timestamp: Date(), note: "Test"),
                Cigarette(timestamp: Date().addingTimeInterval(-3600), note: "Test 2")
            ],
            onDelete: { _ in },
            onAddTags: { _ in }
        )
    }
    .padding()
}