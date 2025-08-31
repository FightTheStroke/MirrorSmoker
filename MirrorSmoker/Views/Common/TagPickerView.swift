//
//  TagPickerView.swift
//  Mirror Smoker
//
//  Created by Roberto D'Angelo on 31/08/25.
//

import SwiftUI
import SwiftData

struct TagPickerView: View {
    @Binding var selected: Set<Tag.ID>
    let existingTags: [Tag]
    let onConfirm: ([Tag]) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var newTagName = ""
    @State private var newTagColor = "#FF0000"
    
    private let colors = [
        "#FF0000", "#FF6B00", "#FFD700", "#32CD32",
        "#00CED1", "#1E90FF", "#9370DB", "#FF69B4"
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Create new tag section
                VStack(spacing: 12) {
                    Text("Create New Tag")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 12) {
                        TextField("Tag name", text: $newTagName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        // Anteprima del colore scelto dalla palette
                        Circle()
                            .fill(Color(hex: newTagColor) ?? .red)
                            .frame(width: 28, height: 28)
                            .overlay(
                                Circle().stroke(Color.primary.opacity(0.2), lineWidth: 1)
                            )
                            .accessibilityLabel("Selected color")
                    }
                    
                    // Color palette
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 8) {
                        ForEach(colors, id: \.self) { colorHex in
                            Circle()
                                .fill(Color(hex: colorHex) ?? .red)
                                .frame(width: 30, height: 30)
                                .overlay(
                                    Circle()
                                        .stroke(newTagColor == colorHex ? Color.primary : Color.clear, lineWidth: 2)
                                )
                                .onTapGesture {
                                    newTagColor = colorHex
                                }
                                .accessibilityLabel(colorHex)
                        }
                    }
                    
                    Button("Add Tag") {
                        addNewTag()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(newTagName.isEmpty)
                }
                .padding()
                .background(Color(.systemGray6))
                
                // Existing tags selection
                List {
                    Section("Select Tags") {
                        ForEach(existingTags) { tag in
                            HStack {
                                Circle()
                                    .fill(tag.swiftUIColor)
                                    .frame(width: 20, height: 20)
                                
                                Text(tag.name)
                                
                                Spacer()
                                
                                if selected.contains(tag.id) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if selected.contains(tag.id) {
                                    selected.remove(tag.id)
                                } else {
                                    selected.insert(tag.id)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Tags")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        let chosenTags = existingTags.filter { selected.contains($0.id) }
                        onConfirm(chosenTags)
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func addNewTag() {
        guard !newTagName.isEmpty else { return }
        // Crea e salva nel ModelContext; @Query in ContentView aggiornerà allTags automaticamente
        let newTag = Tag(name: newTagName, color: newTagColor)
        modelContext.insert(newTag)
        try? modelContext.save()
        // Seleziona automaticamente il nuovo tag
        selected.insert(newTag.id)
        // Reset form
        newTagName = ""
        newTagColor = "#FF0000"
    }
}

#Preview {
    TagPickerView(
        selected: .constant([]),
        existingTags: [
            Tag(name: "Work", color: "#FF0000"),
            Tag(name: "Social", color: "#00FF00")
        ],
        onConfirm: { _ in }
    )
}
