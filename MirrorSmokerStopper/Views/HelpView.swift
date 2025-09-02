//
//  HelpView.swift
//  MirrorSmokerStopper
//
//  Created by Claude on 02/09/25.
//

import SwiftUI

struct HelpView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DS.Space.lg) {
                    // Header
                    VStack(spacing: DS.Space.sm) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 48))
                            .foregroundColor(DS.Colors.primary)
                        
                        Text(NSLocalizedString("help.title", comment: ""))
                            .font(DS.Text.title)
                            .fontWeight(.bold)
                        
                        Text(NSLocalizedString("help.subtitle", comment: ""))
                            .font(DS.Text.body)
                            .foregroundColor(DS.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, DS.Space.md)
                    
                    // Quick Start Section
                    helpSection(
                        title: NSLocalizedString("help.quick.start.title", comment: ""),
                        icon: "play.circle.fill",
                        color: DS.Colors.success,
                        content: [
                            NSLocalizedString("help.quick.start.1", comment: ""),
                            NSLocalizedString("help.quick.start.2", comment: ""),
                            NSLocalizedString("help.quick.start.3", comment: "")
                        ]
                    )
                    
                    // Main Features Section
                    helpSection(
                        title: NSLocalizedString("help.main.features.title", comment: ""),
                        icon: "star.circle.fill",
                        color: DS.Colors.primary,
                        content: [
                            NSLocalizedString("help.main.features.1", comment: ""),
                            NSLocalizedString("help.main.features.2", comment: ""),
                            NSLocalizedString("help.main.features.3", comment: ""),
                            NSLocalizedString("help.main.features.4", comment: "")
                        ]
                    )
                    
                    // Cigarette Management Section
                    helpSection(
                        title: NSLocalizedString("help.cigarette.management.title", comment: ""),
                        icon: "list.bullet.circle.fill",
                        color: DS.Colors.info,
                        content: [
                            NSLocalizedString("help.cigarette.management.1", comment: ""),
                            NSLocalizedString("help.cigarette.management.2", comment: ""),
                            NSLocalizedString("help.cigarette.management.3", comment: ""),
                            NSLocalizedString("help.cigarette.management.4", comment: "")
                        ]
                    )
                    
                    // Tags Section
                    helpSection(
                        title: NSLocalizedString("help.tags.title", comment: ""),
                        icon: "tag.circle.fill",
                        color: DS.Colors.warning,
                        content: [
                            NSLocalizedString("help.tags.1", comment: ""),
                            NSLocalizedString("help.tags.2", comment: ""),
                            NSLocalizedString("help.tags.3", comment: "")
                        ]
                    )
                    
                    // Widget & Siri Section
                    helpSection(
                        title: NSLocalizedString("help.integrations.title", comment: ""),
                        icon: "shortcuts",
                        color: DS.Colors.chart2,
                        content: [
                            NSLocalizedString("help.integrations.1", comment: ""),
                            NSLocalizedString("help.integrations.2", comment: ""),
                            NSLocalizedString("help.integrations.3", comment: ""),
                            NSLocalizedString("help.integrations.4", comment: "")
                        ]
                    )
                    
                    // Statistics Section
                    helpSection(
                        title: NSLocalizedString("help.statistics.title", comment: ""),
                        icon: "chart.bar.fill",
                        color: DS.Colors.chart3,
                        content: [
                            NSLocalizedString("help.statistics.1", comment: ""),
                            NSLocalizedString("help.statistics.2", comment: ""),
                            NSLocalizedString("help.statistics.3", comment: "")
                        ]
                    )
                    
                    // Tips Section
                    helpSection(
                        title: NSLocalizedString("help.tips.title", comment: ""),
                        icon: "lightbulb.circle.fill",
                        color: DS.Colors.chart4,
                        content: [
                            NSLocalizedString("help.tips.1", comment: ""),
                            NSLocalizedString("help.tips.2", comment: ""),
                            NSLocalizedString("help.tips.3", comment: ""),
                            NSLocalizedString("help.tips.4", comment: "")
                        ]
                    )
                }
                .padding(DS.Space.lg)
            }
            .background(DS.Colors.background)
            .navigationTitle(NSLocalizedString("help.navigation.title", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("done", comment: "")) {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Views
    private func helpSection(title: String, icon: String, color: Color, content: [String]) -> some View {
        DSCard {
            VStack(alignment: .leading, spacing: DS.Space.md) {
                HStack(spacing: DS.Space.sm) {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(color)
                    
                    Text(title)
                        .font(DS.Text.headline)
                        .fontWeight(.semibold)
                }
                
                VStack(alignment: .leading, spacing: DS.Space.sm) {
                    ForEach(Array(content.enumerated()), id: \.offset) { index, text in
                        HStack(alignment: .top, spacing: DS.Space.sm) {
                            Text("\(index + 1).")
                                .font(DS.Text.bodyMono)
                                .fontWeight(.semibold)
                                .foregroundColor(color)
                                .frame(width: 20, alignment: .leading)
                            
                            Text(text)
                                .font(DS.Text.body)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Spacer()
                        }
                    }
                }
            }
        }
    }
}

struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        HelpView()
    }
}