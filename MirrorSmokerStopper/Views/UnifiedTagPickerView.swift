//
//  UnifiedTagPickerView.swift
//  MirrorSmokerStopper
//
//  Unified tag picker with all tags in one list
//

import SwiftUI
import SwiftData

struct UnifiedTagPickerView: View {
    @Binding var selectedTags: [Tag]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query(sort: \Tag.name) private var allTags: [Tag]
    @StateObject private var tagManager = TagManager.shared
    
    @State private var showingAddTag = false
    @State private var newTagName = ""
    @State private var selectedColor = "#4DABF7"
    @State private var editingTag: Tag?
    
    let columns = [
        GridItem(.adaptive(minimum: 100), spacing: DS.Space.sm)
    ]
    
    @ViewBuilder
    private var selectedTagsSection: some View {
        if !selectedTags.isEmpty {
            VStack(alignment: .leading, spacing: DS.Space.sm) {
                Text(NSLocalizedString("tags.selected", comment: ""))
                    .font(DS.Text.caption)
                    .foregroundColor(DS.Colors.textSecondary)
                    .padding(.horizontal)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DS.Space.sm) {
                        ForEach(selectedTags) { tag in
                            TagChip(tag: tag, isSelected: true) {
                                withAnimation {
                                    selectedTags.removeAll { $0.id == tag.id }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    private var allTagsGrid: some View {
        LazyVGrid(columns: columns, spacing: DS.Space.md) {
            ForEach(allTags) { tag in
                TagChip(
                    tag: tag,
                    isSelected: selectedTags.contains { $0.id == tag.id }
                ) {
                    withAnimation {
                        if let index = selectedTags.firstIndex(where: { $0.id == tag.id }) {
                            selectedTags.remove(at: index)
                        } else {
                            selectedTags.append(tag)
                        }
                    }
                }
                .contextMenu {
                    Button {
                        editingTag = tag
                    } label: {
                        Label(NSLocalizedString("edit", comment: ""), systemImage: "pencil")
                    }
                    
                    Button(role: .destructive) {
                        deleteTag(tag)
                    } label: {
                        Label(NSLocalizedString("delete", comment: ""), systemImage: "trash")
                    }
                }
            }
            
            // Add new tag button
            Button {
                showingAddTag = true
            } label: {
                VStack(spacing: DS.Space.xs) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                    Text(NSLocalizedString("tag.add.new", comment: ""))
                        .font(DS.Text.caption)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .foregroundColor(DS.Colors.primary)
                .background(DS.Colors.glassSecondary)
                .cornerRadius(DS.Size.buttonRadiusSmall)
            }
        }
        .padding()
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DS.Space.lg) {
                    selectedTagsSection
                    allTagsGrid
                }
            }
            .background(DS.Colors.background)
            .navigationTitle(NSLocalizedString("tags.title", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(NSLocalizedString("cancel", comment: "")) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("done", comment: "")) {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $showingAddTag) {
                AddTagSheet(
                    tagName: $newTagName,
                    selectedColor: $selectedColor,
                    onSave: {
                        saveNewTag()
                    }
                )
            }
            .sheet(item: $editingTag) { tag in
                EditTagSheet(tag: tag, modelContext: modelContext)
            }
        }
        .task {
            // Initialize default tags if needed
            await tagManager.initializeDefaultTags(in: modelContext)
        }
    }
    
    private func saveNewTag() {
        guard !newTagName.isEmpty else { return }
        
        do {
            try tagManager.addTag(
                name: newTagName,
                colorHex: selectedColor,
                in: modelContext
            )
            newTagName = ""
            showingAddTag = false
        } catch {
            // Handle error adding tag - show alert to user
        }
    }
    
    private func deleteTag(_ tag: Tag) {
        do {
            // Remove from selected if it's there
            selectedTags.removeAll { $0.id == tag.id }
            // Delete the tag
            try tagManager.deleteTag(tag, in: modelContext)
        } catch {
            // Error deleting tag
        }
    }
}

// MARK: - Tag Chip Component
struct TagChip: View {
    let tag: Tag
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DS.Space.xs) {
                Circle()
                    .fill(tag.color)
                    .frame(width: 10, height: 10)
                
                Text(TagManager.localizedName(for: tag))
                    .font(DS.Text.caption)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                }
            }
            .padding(.horizontal, DS.Space.sm)
            .padding(.vertical, DS.Space.xs)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: DS.Size.buttonRadiusSmall)
                    .fill(isSelected ? tag.color.opacity(0.2) : DS.Colors.glassSecondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: DS.Size.buttonRadiusSmall)
                            .stroke(isSelected ? tag.color : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Add Tag Sheet
struct AddTagSheet: View {
    @Binding var tagName: String
    @Binding var selectedColor: String
    let onSave: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    let colors = [
        "#FF6B6B", "#4DABF7", "#8B6F3A", "#F06595",
        "#FFA94D", "#CC5DE8", "#69DB7C", "#FFD43B",
        "#748FFC", "#868E96", "#FF8787", "#A9E34B"
    ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: DS.Space.lg) {
                // Name input
                VStack(alignment: .leading, spacing: DS.Space.sm) {
                    Text(NSLocalizedString("tag.name", comment: ""))
                        .font(DS.Text.caption)
                        .foregroundColor(DS.Colors.textSecondary)
                    
                    TextField(NSLocalizedString("tag.name.placeholder", comment: ""), text: $tagName)
                        .textFieldStyle(.roundedBorder)
                }
                
                // Color picker
                VStack(alignment: .leading, spacing: DS.Space.sm) {
                    Text(NSLocalizedString("tag.color", comment: ""))
                        .font(DS.Text.caption)
                        .foregroundColor(DS.Colors.textSecondary)
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: DS.Space.sm) {
                        ForEach(colors, id: \.self) { color in
                            Circle()
                                .fill(Color(hex: color) ?? .blue)
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: selectedColor == color ? 3 : 0)
                                )
                                .scaleEffect(selectedColor == color ? 1.2 : 1.0)
                                .onTapGesture {
                                    withAnimation(.spring()) {
                                        selectedColor = color
                                    }
                                }
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle(NSLocalizedString("tag.add.new", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(NSLocalizedString("cancel", comment: "")) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("save", comment: "")) {
                        onSave()
                        dismiss()
                    }
                    .disabled(tagName.isEmpty)
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Edit Tag Sheet
struct EditTagSheet: View {
    let tag: Tag
    let modelContext: ModelContext
    
    @State private var tagName: String = ""
    @State private var selectedColor: String = ""
    @Environment(\.dismiss) private var dismiss
    @StateObject private var tagManager = TagManager.shared
    
    let colors = [
        "#FF6B6B", "#4DABF7", "#8B6F3A", "#F06595",
        "#FFA94D", "#CC5DE8", "#69DB7C", "#FFD43B",
        "#748FFC", "#868E96", "#FF8787", "#A9E34B"
    ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: DS.Space.lg) {
                // Name input
                VStack(alignment: .leading, spacing: DS.Space.sm) {
                    Text(NSLocalizedString("tag.name", comment: ""))
                        .font(DS.Text.caption)
                        .foregroundColor(DS.Colors.textSecondary)
                    
                    TextField(NSLocalizedString("tag.name.placeholder", comment: ""), text: $tagName)
                        .textFieldStyle(.roundedBorder)
                }
                
                // Color picker
                VStack(alignment: .leading, spacing: DS.Space.sm) {
                    Text(NSLocalizedString("tag.color", comment: ""))
                        .font(DS.Text.caption)
                        .foregroundColor(DS.Colors.textSecondary)
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: DS.Space.sm) {
                        ForEach(colors, id: \.self) { color in
                            Circle()
                                .fill(Color(hex: color) ?? .blue)
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: selectedColor == color ? 3 : 0)
                                )
                                .scaleEffect(selectedColor == color ? 1.2 : 1.0)
                                .onTapGesture {
                                    withAnimation(.spring()) {
                                        selectedColor = color
                                    }
                                }
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle(NSLocalizedString("tag.edit", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(NSLocalizedString("cancel", comment: "")) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("save", comment: "")) {
                        saveChanges()
                    }
                    .disabled(tagName.isEmpty)
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            tagName = TagManager.localizedName(for: tag)
            selectedColor = tag.colorHex
        }
    }
    
    private func saveChanges() {
        do {
            try tagManager.updateTag(
                tag,
                name: tagName,
                colorHex: selectedColor,
                in: modelContext
            )
            dismiss()
        } catch {
            // Error updating tag
        }
    }
}