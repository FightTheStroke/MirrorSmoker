import SwiftUI
import SwiftData

struct TodayCigarettesList: View {
    var todayCigarettes: [Cigarette] = []
    var onDelete: (Cigarette) -> Void = { _ in }
    var onAddTags: (Cigarette) -> Void = { _ in }
    
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
                .background(DS.Colors.card)
                
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
                    .padding(DS.AdaptiveSpace.xl)
                    .background(DS.Colors.card)
                } else {
                    // Cigarettes list with proper spacing
                    LazyVStack(spacing: 0) {
                        ForEach(todayCigarettes, id: \.id) { cigarette in
                            CigaretteRowView(
                                cigarette: cigarette,
                                onDelete: { onDelete(cigarette) },
                                onAddTags: { onAddTags(cigarette) }
                            )
                            .padding(.horizontal, DS.AdaptiveSpace.md)
                            .padding(.vertical, DS.Space.xs)
                            .background(DS.Colors.card)
                            
                            // Divider between rows (except last)
                            if cigarette.id != todayCigarettes.last?.id {
                                Divider()
                                    .padding(.horizontal, DS.AdaptiveSpace.md)
                                    .background(DS.Colors.card)
                            }
                        }
                    }
                    .padding(.bottom, DS.Space.sm)
                    .background(DS.Colors.card)
                }
            }
            .cornerRadius(DS.AdaptiveSize.cardRadius)
            .dsAdaptiveShadow(.small)
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
                .accessibilityHidden(true)
            
            // Time
            Text(cigarette.timestamp, format: .dateTime.hour().minute())
                .font(DS.Text.body)
                .fontWeight(.medium)
                .foregroundColor(DS.Colors.textPrimary)
            
            Spacer()
            
            // Tags (if any)
            if let tags = cigarette.tags, !tags.isEmpty {
                HStack(spacing: DS.Space.xs) {
                    ForEach(tags.prefix(3), id: \.id) { tag in
                        Text(tag.name)
                            .font(DS.Text.caption2)
                            .padding(.horizontal, DS.Space.xs)
                            .padding(.vertical, 2)
                            .background(tag.color)
                            .foregroundColor(.white)
                            .cornerRadius(DS.AdaptiveSize.tagRadius)
                    }
                    
                    if tags.count > 3 {
                        Text(String.localizedStringWithFormat(NSLocalizedString("plus.more.tags", comment: ""), tags.count - 3))
                            .font(DS.Text.caption2)
                            .padding(.horizontal, DS.Space.xs)
                            .padding(.vertical, 2)
                            .background(DS.Colors.backgroundSecondary)
                            .foregroundColor(DS.Colors.textSecondary)
                            .cornerRadius(DS.AdaptiveSize.tagRadius)
                    }
                }
            }
            
            // Action buttons (compact)
            HStack(spacing: DS.Space.xs) {
                // Add tags button
                Button(action: onAddTags) {
                    Image(systemName: "tag")
                        .font(.system(size: 14))
                        .foregroundColor(DS.Colors.primary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(NSLocalizedString("a11y.add.tags.to.cigarette", comment: ""))
                
                // Delete button
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 14))
                        .foregroundColor(DS.Colors.danger)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(NSLocalizedString("a11y.delete.cigarette", comment: ""))
            }
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .contain)
        .accessibilityLabel(NSLocalizedString("a11y.cigarette.row", comment: ""))
        .accessibilityValue(cigarette.timestamp.formatted(date: .omitted, time: .shortened))
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