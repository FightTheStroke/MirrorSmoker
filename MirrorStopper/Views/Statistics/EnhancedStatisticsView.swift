// MARK: - Quick Stats Grid
    
    private var quickStatsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            StatCard(
                title: NSLocalizedString("statistics.total", comment: ""),
                value: "\(filteredCigarettes.count)",
                subtitle: NSLocalizedString("cigarettes", comment: ""),
                color: .blue
            )
            
            StatCard(
                title: NSLocalizedString("statistics.average", comment: ""),
                value: String(format: "%.1f", averagePerPeriod),
                subtitle: averageUnit,
                color: .orange
            )
            
            StatCard(
                title: NSLocalizedString("statistics.peak.hour", comment: ""),
                value: peakHour,
                subtitle: NSLocalizedString("statistics.most.active", comment: ""),
                color: .red
            )
            
            StatCard(
                title: NSLocalizedString("statistics.most.used.tag", comment: ""),
                value: mostUsedTag.isEmpty ? NSLocalizedString("statistics.none", comment: "") : mostUsedTag,
                subtitle: NSLocalizedString("statistics.category", comment: ""),
                color: .green
            )
        }
    }