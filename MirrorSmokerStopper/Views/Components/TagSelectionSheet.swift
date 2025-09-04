//
//  TagSelectionSheet.swift
//  MirrorSmokerStopper
//
//  Created by Claude on 03/09/25.
//

import SwiftUI
import SwiftData
import os.log

struct TagSelectionSheet: View {
    private static let logger = Logger(subsystem: "com.fightthestroke.MirrorSmokerStopper", category: "TagSelectionSheet")
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var allTags: [Tag]
    
    @State private var selectedTags: [Tag] = []
    @State private var showingCreateTag = false
    @State private var newTagName = ""
    @State private var newTagColor = "#007AFF"
    @State private var isCreatingTag = false
    
    let onSave: ([Tag]) -> Void
    
    // Available colors for new tags
    private let availableColors = [
        "#007AFF", "#FF3B30", "#FF9500", "#FFCC00",
        "#34C759", "#5AC8FA", "#AF52DE", "#FF2D92",
        "#8E8E93", "#00C7BE", "#FF6B35", "#5856D6"
    ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header with selected count
                headerView
                
                // Selected tags preview
                if !selectedTags.isEmpty {
                    selectedTagsPreview
                }
                
                // Tags list
                tagsList
            }
            .navigationTitle("tags.select.title".local())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("cancel".local()) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("done".local()) {
                        saveCigaretteWithTags()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(DS.Colors.primary)
                }
            }
            .sheet(isPresented: $showingCreateTag) {
                createTagSheet
            }
        }
        .onAppear {
            Self.logger.info("TagSelectionSheet appeared")
        }
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        VStack(spacing: DS.Space.sm) {
            HStack {
                VStack(alignment: .leading) {
                    Text("tags.add.cigarette.with".local())
                        .font(DS.Text.body)
                        .foregroundColor(DS.Colors.textSecondary)
                    Text(String(format: "tags.selected.count".local(), selectedTags.count))
                        .font(DS.Text.caption)
                        .foregroundColor(DS.Colors.primary)
                }
                
                Spacer()
                
                Button(action: {
                    showingCreateTag = true
                }) {
                    HStack(spacing: DS.Space.xs) {
                        Image(systemName: "plus.circle.fill")
                        Text("tags.create.new".local())
                            .font(DS.Text.caption)
                    }
                    .foregroundColor(DS.Colors.primary)
                    .padding(.horizontal, DS.Space.sm)
                    .padding(.vertical, DS.Space.xs)
                    .background(DS.Colors.primary.opacity(0.1))
                    .cornerRadius(DS.Size.cardRadiusSmall)
                }
            }
            .padding(.horizontal, DS.Space.lg)
            .padding(.vertical, DS.Space.md)
            
            Divider()
        }
    }
    
    // MARK: - Selected Tags Preview
    
    private var selectedTagsPreview: some View {
        VStack(alignment: .leading, spacing: DS.Space.sm) {
            HStack {
                Text("tags.selected".local())
                    .font(DS.Text.caption)
                    .foregroundColor(DS.Colors.textSecondary)
                    .padding(.leading, DS.Space.lg)
                Spacer()
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DS.Space.sm) {
                    ForEach(selectedTags) { tag in
                        tagChip(tag: tag, isSelected: true) {
                            removeTag(tag)
                        }
                    }
                }
                .padding(.horizontal, DS.Space.lg)
            }
            
            Divider()
        }
        .padding(.vertical, DS.Space.sm)
    }
    
    // MARK: - Tags List
    
    private var tagsList: some View {
        ScrollView {
            LazyVStack(spacing: DS.Space.sm) {
                if allTags.isEmpty {
                    emptyStateView
                } else {
                    ForEach(allTags) { tag in
                        tagRow(tag: tag)
                    }
                }
            }
            .padding(.horizontal, DS.Space.lg)
            .padding(.vertical, DS.Space.md)
        }
    }
    
    // MARK: - Tag Row
    
    private func tagRow(tag: Tag) -> some View {
        let isSelected = selectedTags.contains(where: { $0.id == tag.id })
        
        return Button(action: {
            toggleTagSelection(tag)
        }) {
            HStack(spacing: DS.Space.md) {
                // Tag color indicator
                Circle()
                    .fill(tag.color)
                    .frame(width: 20, height: 20)
                    .overlay(
                        Circle()
                            .stroke(DS.Colors.separator, lineWidth: 1)
                    )
                
                // Tag name
                Text(tag.name)
                    .font(DS.Text.body)
                    .foregroundColor(DS.Colors.textPrimary)
                
                Spacer()
                
                // Selection indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(isSelected ? DS.Colors.primary : DS.Colors.textSecondary)
            }
            .padding(.vertical, DS.Space.md)
            .padding(.horizontal, DS.Space.lg)
            .background(
                RoundedRectangle(cornerRadius: DS.Size.cardRadius)
                    .fill(isSelected ? DS.Colors.primary.opacity(0.05) : DS.Colors.card)
                    .overlay(
                        RoundedRectangle(cornerRadius: DS.Size.cardRadius)
                            .stroke(
                                isSelected ? DS.Colors.primary.opacity(0.3) : DS.Colors.separator,
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Tag Chip
    
    private func tagChip(tag: Tag, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: DS.Space.xs) {
                Circle()
                    .fill(tag.color)
                    .frame(width: 12, height: 12)
                Text(tag.name)
                    .font(DS.Text.caption)
                    .fontWeight(.medium)
                if isSelected {
                    Image(systemName: "xmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(DS.Colors.textSecondary)
                }
            }
            .padding(.horizontal, DS.Space.md)
            .padding(.vertical, DS.Space.sm)
            .background(
                RoundedRectangle(cornerRadius: DS.Size.cardRadiusSmall)
                    .fill(isSelected ? tag.color.opacity(0.15) : DS.Colors.backgroundSecondary)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: DS.Space.lg) {
            Image(systemName: "tag")
                .font(.system(size: 48))
                .foregroundColor(DS.Colors.textSecondary)
            
            VStack(spacing: DS.Space.sm) {
                Text("tags.empty.title".local())
                    .font(DS.Text.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(DS.Colors.textPrimary)
                
                Text("tags.empty.subtitle".local())
                    .font(DS.Text.body)
                    .foregroundColor(DS.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: {
                showingCreateTag = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("tags.create.first".local())
                }
                .font(DS.Text.body)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .padding(.horizontal, DS.Space.lg)
                .padding(.vertical, DS.Space.md)
                .background(DS.Colors.primary)
                .cornerRadius(DS.Size.cardRadius)
            }
        }
        .padding(.vertical, DS.Space.xxl)
    }
    
    // MARK: - Create Tag Sheet
    
    private var createTagSheet: some View {
        CreateTagSheetView(
            newTagName: $newTagName,
            newTagColor: $newTagColor,
            isCreatingTag: $isCreatingTag,
            availableColors: availableColors,
            showingCreateTag: $showingCreateTag,
            onSave: createNewTag,
            onCancel: {
                resetCreateTagForm()
                showingCreateTag = false
            }
        )
    }
    
    // MARK: - Actions
    
    private func toggleTagSelection(_ tag: Tag) {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        
        if let index = selectedTags.firstIndex(where: { $0.id == tag.id }) {
            selectedTags.remove(at: index)
            Self.logger.info("Deselected tag: \(tag.name)")
        } else {
            selectedTags.append(tag)
            Self.logger.info("Selected tag: \(tag.name)")
        }
    }
    
    private func removeTag(_ tag: Tag) {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        
        if let index = selectedTags.firstIndex(where: { $0.id == tag.id }) {
            _ = withAnimation(.easeInOut(duration: 0.2)) {
                selectedTags.remove(at: index)
            }
            Self.logger.info("Removed tag from selection: \(tag.name)")
        }
    }
    
    private func createNewTag() {
        let tagName = newTagName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !tagName.isEmpty else { return }
        guard !allTags.contains(where: { $0.name.lowercased() == tagName.lowercased() }) else {
            // Show duplicate name error
            return
        }
        
        isCreatingTag = true
        
        let newTag = Tag(name: tagName, colorHex: newTagColor)
        modelContext.insert(newTag)
        
        do {
            try modelContext.save()
            
            // Automatically select the new tag
            selectedTags.append(newTag)
            
            Self.logger.info("Created and selected new tag: \(tagName)")
            
            resetCreateTagForm()
            showingCreateTag = false
            
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            
        } catch {
            Self.logger.error("Failed to create tag: \(error.localizedDescription)")
        }
        
        isCreatingTag = false
    }
    
    private func resetCreateTagForm() {
        newTagName = ""
        newTagColor = availableColors.first ?? "#007AFF"
        isCreatingTag = false
    }
    
    private func saveCigaretteWithTags() {
        Self.logger.info("Saving cigarette with \(selectedTags.count) tags")
        
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        onSave(selectedTags)
        dismiss()
    }
}

// MARK: - Create Tag Sheet View

struct CreateTagSheetView: View {
    @Binding var newTagName: String
    @Binding var newTagColor: String
    @Binding var isCreatingTag: Bool
    let availableColors: [String]
    @Binding var showingCreateTag: Bool
    let onSave: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        NavigationStack {
            createTagContent
                .navigationTitle("tags.create.title".local())
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("cancel".local()) {
                            onCancel()
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        saveButton
                    }
                }
        }
    }
    
    private var createTagContent: some View {
        VStack(spacing: DS.Space.lg) {
            tagNameInput
            colorSelection
            Spacer()
        }
        .padding(DS.Space.lg)
    }
    
    private var tagNameInput: some View {
        VStack(alignment: .leading, spacing: DS.Space.sm) {
            Text("tags.name".local())
                .font(DS.Text.body)
                .fontWeight(.medium)
            
            TextField("tags.name.placeholder".local(), text: $newTagName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .textInputAutocapitalization(.words)
        }
    }
    
    private var colorSelection: some View {
        VStack(alignment: .leading, spacing: DS.Space.sm) {
            Text("tags.color".local())
                .font(DS.Text.body)
                .fontWeight(.medium)
            
            colorGrid
        }
    }
    
    private var colorGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: DS.Space.md) {
            ForEach(availableColors, id: \.self) { colorHex in
                colorButton(for: colorHex)
            }
        }
    }
    
    private func colorButton(for colorHex: String) -> some View {
        Button(action: {
            newTagColor = colorHex
        }) {
            Circle()
                .fill(Color(hex: colorHex) ?? .gray)
                .frame(width: 40, height: 40)
                .overlay(
                    Circle()
                        .stroke(
                            newTagColor == colorHex ? DS.Colors.primary : DS.Colors.separator,
                            lineWidth: newTagColor == colorHex ? 3 : 1
                        )
                )
                .scaleEffect(newTagColor == colorHex ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: newTagColor)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var saveButton: some View {
        Button(action: onSave) {
            if isCreatingTag {
                ProgressView()
                    .scaleEffect(0.8)
            } else {
                Text("save".local())
                    .fontWeight(.semibold)
            }
        }
        .disabled(newTagName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isCreatingTag)
    }
}

