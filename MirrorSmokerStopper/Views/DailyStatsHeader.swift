import SwiftUI

struct DailyStatsHeader: View {
    let todayCount: Int
    let onQuickAdd: () -> Void
    let onAddWithTags: () -> Void
    
    var body: some View {
        LegacyDSCard {
            VStack(spacing: DS.Space.lg) {
                VStack(spacing: DS.Space.sm) {
                    Text(NSLocalizedString("today.title", comment: ""))
                        .font(DS.Text.headline)
                        .foregroundStyle(DS.Colors.textSecondary)
                    Text("\(todayCount)")
                        .font(DS.Text.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(DS.Colors.cigarette)
                    Text(todayCount == 1 ? NSLocalizedString("cigarette.singular", comment: "") : NSLocalizedString("cigarette.plural", comment: ""))
                        .font(DS.Text.caption)
                        .foregroundStyle(DS.Colors.textSecondary)
                }
                HStack(spacing: DS.Space.md) {
                    DSButton(
                        NSLocalizedString("daily.stats.quick.add", comment: ""),
                        icon: "plus.circle.fill",
                        style: .primary
                    ) { onQuickAdd() }
                    DSButton(
                        NSLocalizedString("button.add.with.tags", comment: ""),
                        icon: "tag.fill",
                        style: .secondary
                    ) { onAddWithTags() }
                }
            }
        }
    }
}