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
            VStack(spacing: 0) {
                if allTags.isEmpty {
                    // Empty state
                    VStack(spacing: 16) {
                        Image(systemName: "tag")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        
                        Text("No tags yet")
                            .font(.headline)
                        
                        Text("Create your first tag to categorize your cigarettes")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button("Create First Tag") {
                            showingCreateTag = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGroupedBackground))
                } else {
                    List {
                        Section {
                            ForEach(allTags) { tag in
                                TagRowView(
                                    tag: tag,
                                    isSelected: selectedTags.contains(where: { $0.id == tag.id })
                                ) {
                                    toggleTagSelection(tag)
                                }
                            }
                            .onDelete(perform: deleteTag)
                        } header: {
                            Text("Available Tags")
                        } footer: {
                            Text("Swipe left on a tag to delete it")
                                .font(.caption)
                        }
                    }
                    .listStyle(.insetGrouped)
                    .background(Color(.systemGroupedBackground))
                }
            }
            .navigationTitle("Select Tags")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingCreateTag = true
                    } label: {
                        Label("Create Tag", systemImage: "plus")
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
            .alert("Delete Tag", isPresented: $showingDeleteAlert, presenting: tagToDelete) { tag in
                Button("Cancel", role: .cancel) {
                    tagToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    confirmDeleteTag(tag)
                }
            } message: { tag in
                Text("Are you sure you want to delete '\(tag.name)'? This action cannot be undone.")
            }
        }
    }
    
    private func toggleTagSelection(_ tag: Tag) {
        if let index = selectedTags.firstIndex(where: { $0.id == tag.id }) {
            selectedTags.remove(at: index)
        } else {
            selectedTags.append(tag)
        }
    }
    
    private func deleteTag(at offsets: IndexSet) {
        guard let index = offsets.first else { return }
        let tag = allTags[index]
        tagToDelete = tag
        showingDeleteAlert = true
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
        
        Task { @MainActor in
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
}

struct TagRowView: View {
    let tag: Tag
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Color indicator
            Circle()
                .fill(tag.color)
                .frame(width: 16, height: 16)
                .overlay(
                    Circle()
                        .stroke(Color(.systemGray4), lineWidth: 0.5)
                )
            
            // Tag name
            Text(tag.name)
                .font(.body)
            
            Spacer()
            
            // Selection indicator
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 20))
            } else {
                Image(systemName: "circle")
                    .foregroundColor(.gray)
                    .font(.system(size: 20))
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            // Add haptic feedback
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            onTap()
        }
        .listRowBackground(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? Color.blue.opacity(0.1) : Color(.systemBackground))
        )
    }
}

struct CreateTagView: View {
    @Binding var tagName: String
    @Binding var tagColor: String
    @Binding var isPresented: Bool
    var onSave: () -> Void
    
    @FocusState private var isTagNameFocused: Bool
    
    // Predefined colors
    private let predefinedColors = [
        "#FF3B30", "#FF9500", "#FFCC00", "#34C759", "#007AFF", 
        "#5856D6", "#AF52DE", "#FF2D92", "#A2845E", "#8E8E93"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Tag Name", text: $tagName)
                        .focused($isTagNameFocused)
                        .textInputAutocapitalization(.words)
                        .submitLabel(.done)
                        .onSubmit {
                            if !tagName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                onSave()
                                isPresented = false
                            }
                        }
                } header: {
                    Text("Tag Name")
                } footer: {
                    Text("Choose a descriptive name for your tag")
                }
                
                Section {
                    // Custom color picker
                    ColorPicker("Custom Color", selection: .init(
                        get: { Color.fromHex(tagColor) ?? .blue },
                        set: { tagColor = $0.toHex() }
                    ))
                    
                    // Predefined colors grid
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                        ForEach(predefinedColors, id: \.self) { colorHex in
                            Circle()
                                .fill(Color.fromHex(colorHex) ?? .gray)
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Circle()
                                        .stroke(tagColor == colorHex ? Color.primary : Color.clear, lineWidth: 2)
                                )
                                .onTapGesture {
                                    tagColor = colorHex
                                    let impact = UIImpactFeedbackGenerator(style: .light)
                                    impact.impactOccurred()
                                }
                        }
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Color")
                } footer: {
                    Text("Tap a color to select it, or use the custom color picker")
                }
                
                // Preview section
                Section {
                    HStack(spacing: 12) {
                        Circle()
                            .fill(Color.fromHex(tagColor) ?? .blue)
                            .frame(width: 16, height: 16)
                        
                        Text(tagName.isEmpty ? "Tag Preview" : tagName)
                            .foregroundColor(tagName.isEmpty ? .secondary : .primary)
                        
                        Spacer()
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Preview")
                }
            }
            .navigationTitle("Create Tag")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave()
                        isPresented = false
                    }
                    .disabled(tagName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .fontWeight(.semibold)
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        isTagNameFocused = false
                    }
                }
            }
        }
        .onAppear {
            // Focus the text field when the view appears
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