//
//  StandardTagsView.swift
//  MirrorSmokerStopper
//
//  Created by Claude on 09/01/25.
//

import SwiftUI
import SwiftData

/// View to display and manage standard predefined tags
struct StandardTagsView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var selectedTags: [Tag]
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Space.md) {
            // Header
            Text("tags.standard.title".local())
                .font(DS.Text.body)
                .fontWeight(.semibold)
                .foregroundColor(DS.Colors.textPrimary)
                .padding(.horizontal, DS.Space.lg)
            
            // Simple horizontal scroll of 5 standard tags
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DS.Space.sm) {
                    ForEach(StandardTriggerTag.allCases, id: \.self) { standardTag in
                        StandardTagChip(
                            standardTag: standardTag,
                            isSelected: isTagSelected(standardTag),
                            action: { toggleTag(standardTag) }
                        )
                    }
                }
                .padding(.horizontal, DS.Space.lg)
            }
        }
    }
    
    private func isTagSelected(_ standardTag: StandardTriggerTag) -> Bool {
        selectedTags.contains { tag in
            tag.name.lowercased() == standardTag.localizedName.lowercased()
        }
    }
    
    private func toggleTag(_ standardTag: StandardTriggerTag) {
        // Get or create the Tag model for this standard tag
        if let tag = standardTag.getOrCreateTag(in: modelContext) {
            if let index = selectedTags.firstIndex(where: { $0.id == tag.id }) {
                selectedTags.remove(at: index)
            } else {
                selectedTags.append(tag)
                // Save the context to persist the new tag if it was just created
                try? modelContext.save()
            }
            
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
        }
    }
}

/// Individual standard tag chip
struct StandardTagChip: View {
    let standardTag: StandardTriggerTag
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DS.Space.xs) {
                Text(standardTag.emoji)
                    .font(.system(size: 14))
                
                Text(standardTag.localizedName)
                    .font(DS.Text.caption)
                    .fontWeight(isSelected ? .semibold : .medium)
            }
            .padding(.horizontal, DS.Space.md)
            .padding(.vertical, DS.Space.sm)
            .background(
                RoundedRectangle(cornerRadius: DS.Size.cardRadiusSmall)
                    .fill(isSelected ? 
                          Color(hex: standardTag.defaultColor)?.opacity(0.15) ?? DS.Colors.primary.opacity(0.15) :
                          DS.Colors.backgroundSecondary
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: DS.Size.cardRadiusSmall)
                            .stroke(
                                isSelected ? 
                                Color(hex: standardTag.defaultColor) ?? DS.Colors.primary :
                                DS.Colors.separator,
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
            .foregroundColor(
                isSelected ? 
                Color(hex: standardTag.defaultColor) ?? DS.Colors.primary :
                DS.Colors.textPrimary
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

// MARK: - Preview
#Preview {
    StandardTagsView(selectedTags: .constant([]))
        .modelContainer(for: [Tag.self, Cigarette.self])
}