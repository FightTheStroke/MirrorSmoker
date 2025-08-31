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
    @Query private var allTags: [Tag]
    
    @State private var showingCreateTag = false
    @State private var newTagName = ""
    @State private var newTagColor = "#007AFF"
    
    var body: some View {
        NavigationView {
            VStack {
                if allTags.isEmpty {
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
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(allTags) { tag in
                            HStack {
                                Circle()
                                    .fill(tag.color)
                                    .frame(width: 12, height: 12)
                                
                                Text(tag.name)
                                
                                Spacer()
                                
                                if selectedTags.contains(where: { $0.id == tag.id }) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if let index = selectedTags.firstIndex(where: { $0.id == tag.id }) {
                                    selectedTags.remove(at: index)
                                } else {
                                    selectedTags.append(tag)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Tags")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        // Dismiss the view
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Create") {
                        showingCreateTag = true
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
            }
            .onAppear {
                // Create sample tags if none exist
                if allTags.isEmpty {
                    createSampleTags()
                }
            }
        }
    }
    
    private func saveNewTag() {
        let newTag = Tag(name: newTagName, colorHex: newTagColor)
        modelContext.insert(newTag)
        try? modelContext.save()
        
        // Reset form
        newTagName = ""
        newTagColor = "#007AFF"
    }
    
    private func createSampleTags() {
        let sampleTags = [
            Tag(name: "Work", colorHex: "#FF0000"),
            Tag(name: "Social", colorHex: "#00FF00")
        ]
        
        for tag in sampleTags {
            modelContext.insert(tag)
        }
        
        try? modelContext.save()
    }
}

struct CreateTagView: View {
    @Binding var tagName: String
    @Binding var tagColor: String
    @Binding var isPresented: Bool
    var onSave: () -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Tag Details")) {
                    TextField("Tag Name", text: $tagName)
                    
                    ColorPicker("Color", selection: .init(
                        get: { Color.fromHex(tagColor) ?? .blue },
                        set: { tagColor = $0.toHex() }
                    ))
                }
            }
            .navigationTitle("Create Tag")
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
                }
            }
        }
    }
}

#Preview {
    TagPickerView(selectedTags: .constant([]))
}