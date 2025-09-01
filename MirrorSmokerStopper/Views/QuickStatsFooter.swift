import SwiftUI

struct QuickStatsFooter: View {
    let weeklyCount: Int
    let monthlyCount: Int
    let allTimeCount: Int
    
    var body: some View {
        DSCard {
            VStack(spacing: DS.Space.md) {
                DSSectionHeader(NSLocalizedString("quick.stats", comment: ""))
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: DS.Space.sm) {
                    VStack(spacing: DS.Space.xs) {
                        Text("\(weeklyCount)")
                            .font(DS.Text.title)
                            .fontWeight(.bold)
                            .foregroundStyle(DS.Colors.primary)
                        Text(NSLocalizedString("stats.this.week", comment: ""))
                            .font(DS.Text.caption)
                            .foregroundStyle(DS.Colors.textSecondary)
                    }
                    VStack(spacing: DS.Space.xs) {
                        Text("\(monthlyCount)")
                            .font(DS.Text.title)
                            .fontWeight(.bold)
                            .foregroundStyle(DS.Colors.warning)
                        Text(NSLocalizedString("stats.this.month", comment: ""))
                            .font(DS.Text.caption)
                            .foregroundStyle(DS.Colors.textSecondary)
                    }
                    VStack(spacing: DS.Space.xs) {
                        Text("\(allTimeCount)")
                            .font(DS.Text.title)
                            .fontWeight(.bold)
                            .foregroundStyle(DS.Colors.secondary)
                        Text(NSLocalizedString("stats.total", comment: ""))
                            .font(DS.Text.caption)
                            .foregroundStyle(DS.Colors.textSecondary)
                    }
                }
            }
        }
    }
}