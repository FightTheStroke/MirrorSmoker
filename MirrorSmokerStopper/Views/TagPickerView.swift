//
//  TagPickerView.swift
//  Mirror Smoker
//
//  Created by Roberto D'Angelo on 27/08/24.
//

import SwiftUI
import SwiftData

struct TagPickerView: View {
    @Binding var selectedTags: [Tag]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Tag.name) private var allTags: [Tag]
    
    @State private var showingCreateTag = false
    @State private var newTagName = ""
    @State private var newTagColor = "#007AFF"
    @State private var tagToDelete: Tag?
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    if allTags.isEmpty {
                        // Empty state
                        VStack(spacing: 20) {
                            Image(systemName: "tag.circle")
                                .font(.system(size: 60))
                                .foregroundStyle(.secondary)
                            
                            VStack(spacing: 8) {
                                Text(NSLocalizedString("tags.none.title", comment: ""))
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                
                                Text(NSLocalizedString("tags.none.subtitle", comment: ""))
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                            
                            Button(action: { showingCreateTag = true }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text(NSLocalizedString("tags.create.first", comment: ""))
                                }
                                .fontWeight(.medium)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(.blue)
                                .foregroundStyle(.white)
                                .cornerRadius(25)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                    } else {
                        // Tags grid
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            ForEach(allTags) { tag in
                                TagCard(
                                    tag: tag,
                                    isSelected: selectedTags.contains(where: { $0.id == tag.id }),
                                    onTap: { toggleTagSelection(tag) },
                                    onDelete: { 
                                        tagToDelete = tag
                                        showingDeleteAlert = true
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(NSLocalizedString("select.tags", comment: ""))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("done", comment: "")) {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
                
                if !allTags.isEmpty {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: { showingCreateTag = true }) {
                            Image(systemName: "plus")
                                .fontWeight(.medium)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingCreateTag) {
                CreateTagView(
                    tagName: $newTagName,
                    tagColor: $newTagColor,
                    isPresented: $showingCreateTag,
                    onSave: saveNewTag
                )
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
            .alert(NSLocalizedString("tags.delete.title", comment: ""), isPresented: $showingDeleteAlert, presenting: tagToDelete) { tag in
                Button(NSLocalizedString("cancel", comment: ""), role: .cancel) {
                    tagToDelete = nil
                }
                Button(NSLocalizedString("delete", comment: ""), role: .destructive) {
                    confirmDeleteTag(tag)
                }
            } message: { tag in
                Text(String(format: NSLocalizedString("tags.delete.message", comment: ""), tag.name))
            }
        }
    }
    
    private func toggleTagSelection(_ tag: Tag) {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        
        if let index = selectedTags.firstIndex(where: { $0.id == tag.id }) {
            selectedTags.remove(at: index)
        } else {
            selectedTags.append(tag)
        }
    }
    
    private func confirmDeleteTag(_ tag: Tag) {
        // Remove from selected tags if present
        if let selectedIndex = selectedTags.firstIndex(where: { $0.id == tag.id }) {
            selectedTags.remove(at: selectedIndex)
        }
        
        // Delete from database
        modelContext.delete(tag)
        
        do {
            try modelContext.save()
        } catch {
            print("Error deleting tag: \(error)")
        }
        
        tagToDelete = nil
    }
    
    private func saveNewTag() {
        let trimmedName = newTagName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        // Check if tag name already exists
        let existingTag = allTags.first { $0.name.lowercased() == trimmedName.lowercased() }
        guard existingTag == nil else {
            print("Tag with name '\(trimmedName)' already exists")
            return
        }
        
        let newTag = Tag(name: trimmedName, colorHex: newTagColor)
        modelContext.insert(newTag)
        
        do {
            try modelContext.save()
            // Reset form
            newTagName = ""
            newTagColor = "#007AFF"
        } catch {
            print("Error saving tag: \(error)")
        }
    }
}

struct TagCard: View {
    let tag: Tag
    let isSelected: Bool
    let onTap: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                HStack {
                    // Color indicator
                    Circle()
                        .fill(tag.color)
                        .frame(width: 20, height: 20)
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                    
                    Spacer()
                    
                    // Delete button
                    Button(action: onDelete) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.gray.opacity(0.6))
                            .font(.system(size: 16))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // Tag name
                Text(tag.name)
                    .font(.headline)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)
                
                // Selection indicator
                HStack {
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.blue)
                            .font(.system(size: 18))
                    } else {
                        Image(systemName: "circle")
                            .foregroundStyle(.gray)
                            .font(.system(size: 18))
                    }
                    
                    Text(isSelected ? "Selezionato" : "Tocca per selezionare")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? .blue : .clear, lineWidth: 2)
            )
            .scaleEffect(isSelected ? 0.98 : 1.0)
            .animation(.spring(response: 0.3), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CreateTagView: View {
    @Binding var tagName: String
    @Binding var tagColor: String
    @Binding var isPresented: Bool
    var onSave: () -> Void
    
    @FocusState private var isTagNameFocused: Bool
    
    // Predefined colors with better selection
    private let predefinedColors = [
        "#FF3B30", "#FF9500", "#FFCC02", "#30D158", "#007AFF", 
        "#5856D6", "#AF52DE", "#FF2D92", "#A2845E", "#8E8E93",
        "#FF6B6B", "#4ECDC4", "#45B7D1", "#96CEB4", "#FECA57",
        "#FF9FF3", "#54A0FF", "#5F27CD", "#00D2D3", "#FF9F43"
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Preview section
                    VStack(spacing: 16) {
                        Text(NSLocalizedString("tags.preview.title", comment: ""))
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        
                        HStack(spacing: 12) {
                            Circle()
                                .fill(Color.fromHex(tagColor) ?? .blue)
                                .frame(width: 24, height: 24)
                                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                            
                            Text(tagName.isEmpty ? NSLocalizedString("tags.preview", comment: "") : tagName)
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundStyle(tagName.isEmpty ? .secondary : .primary)
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                        )
                    }
                    
                    // Name input
                    VStack(alignment: .leading, spacing: 8) {
                        Text(NSLocalizedString("tags.name.title", comment: ""))
                            .font(.headline)
                        
                        TextField(NSLocalizedString("tags.name.placeholder", comment: ""), text: $tagName)
                            .focused($isTagNameFocused)
                            .textFieldStyle(.roundedBorder)
                            .textInputAutocapitalization(.words)
                            .submitLabel(.done)
                    }
                    
                    // Color selection
                    VStack(alignment: .leading, spacing: 16) {
                        Text(NSLocalizedString("tags.color", comment: ""))
                            .font(.headline)
                        
                        // Predefined colors grid
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 16) {
                            ForEach(predefinedColors, id: \.self) { colorHex in
                                Button(action: {
                                    tagColor = colorHex
                                    let impact = UIImpactFeedbackGenerator(style: .light)
                                    impact.impactOccurred()
                                }) {
                                    Circle()
                                        .fill(Color.fromHex(colorHex) ?? .gray)
                                        .frame(width: 40, height: 40)
                                        .overlay(
                                            Circle()
                                                .stroke(tagColor == colorHex ? Color.primary : Color.clear, lineWidth: 3)
                                        )
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white, lineWidth: tagColor == colorHex ? 2 : 0)
                                        )
                                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                                        .scaleEffect(tagColor == colorHex ? 1.1 : 1.0)
                                        .animation(.spring(response: 0.3), value: tagColor == colorHex)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        
                        // Custom color picker
                        HStack {
                            Text(NSLocalizedString("tags.color.custom", comment: ""))
                                .font(.subheadline)
                            
                            Spacer()
                            
                            ColorPicker("", selection: .init(
                                get: { Color.fromHex(tagColor) ?? .blue },
                                set: { tagColor = $0.toHex() }
                            ))
                            .labelsHidden()
                        }
                        .padding(.top, 8)
                    }
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(NSLocalizedString("tags.create.title", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(NSLocalizedString("cancel", comment: "")) {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("save", comment: "")) {
                        onSave()
                        isPresented = false
                    }
                    .disabled(tagName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                isTagNameFocused = true
            }
        }
    }
}

#Preview {
    NavigationView {
        TagPickerView(selectedTags: .constant([]))
            .modelContainer(for: Tag.self, inMemory: true)
    }
}