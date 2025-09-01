//
//  TagSelectorForTimeSheet.swift
//  Mirror Smoker
//
//  Created by Roberto D'Angelo on 31/08/25.
//

import SwiftUI
import SwiftData

struct TagSelectionRow: View {
    let tag: Tag
    let cigarettesInRange: [Cigarette]
    let onTap: () -> Void
    
    private var taggedCigarettes: [Cigarette] {
        cigarettesInRange.filter { cigarette in
            cigarette.tags?.contains(tag) ?? false
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Tag color indicator
                Circle()
                    .fill(tag.color)
                    .frame(width: 20, height: 20)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(tag.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if !taggedCigarettes.isEmpty {
                        Text("\(taggedCigarettes.count) already tagged in this period")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding()
            .background(AppColors.systemGray6)
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CreateNewTagSheet: View {
    @Binding var tagName: String
    @Binding var tagColor: String
    @Binding var isPresented: Bool
    let onSave: (Tag) -> Void
    
    @Environment(\.modelContext) private var modelContext
    
    private let availableColors = [
        "#007AFF", "#FF3B30", "#FF9500", "#FFCC00",
        "#34C759", "#5AC8FA", "#AF52DE", "#FF2D92",
        "#A2845E", "#8E8E93"
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tag Name")
                        .font(.headline)
                    
                    TextField("Enter tag name", text: $tagName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Color")
                        .font(.headline)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                        ForEach(availableColors, id: \.self) { colorHex in
                            Button(action: {
                                tagColor = colorHex
                            }) {
                                Circle()
                                    .fill(Color.fromHex(colorHex) ?? .blue)
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Circle()
                                            .stroke(tagColor == colorHex ? Color.primary : Color.clear, lineWidth: 3)
                                    )
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("New Tag")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let newTag = Tag(name: tagName, colorHex: tagColor)
                        modelContext.insert(newTag)
                        
                        do {
                            try modelContext.save()
                            onSave(newTag)
                            isPresented = false
                        } catch {
                            print("Error saving tag: \(error)")
                        }
                    }
                    .disabled(tagName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

struct TagSelectorForTimeSheet: View {
    let hourRange: HourRange
    let selectedDate: Date
    let onTagSelected: (Tag) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var allTags: [Tag]
    
    @State private var showingCreateTag = false
    @State private var newTagName = ""
    @State private var newTagColor = "#007AFF"
    
    private var timeRangeText: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let startTime = calendar.date(byAdding: .hour, value: hourRange.start, to: startOfDay)!
        let endTime = calendar.date(byAdding: .hour, value: hourRange.end, to: startOfDay)!
        
        return "\(formatter.string(from: startTime)) - \(formatter.string(from: endTime))"
    }
    
    private var dateText: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: selectedDate)
    }
    
    private var cigarettesInRange: [Cigarette] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let startTime = calendar.date(byAdding: .hour, value: hourRange.start, to: startOfDay)!
        let endTime = calendar.date(byAdding: .hour, value: hourRange.end, to: startOfDay)!
        
        let descriptor = FetchDescriptor<Cigarette>(
            predicate: #Predicate { cigarette in
                cigarette.timestamp >= startTime && cigarette.timestamp < endTime
            }
        )
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Error fetching cigarettes: \(error)")
            return []
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header Info
                VStack(spacing: 12) {
                    Text("Add Tag to Time Period")
                        .font(.headline)
                    
                    VStack(spacing: 4) {
                        Text(dateText)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(timeRangeText)
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    
                    if cigarettesInRange.isEmpty {
                        Text("No cigarettes in this time period")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(8)
                    } else {
                        Text("\(cigarettesInRange.count) cigarette\(cigarettesInRange.count == 1 ? "" : "s") in this period")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(AppColors.systemGray6)
                .cornerRadius(12)
                
                // Tag List
                if allTags.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "tag")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        
                        Text("No tags available")
                            .font(.headline)
                        
                        Text("Create a new tag to categorize this time period")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button("Create First Tag") {
                            showingCreateTag = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(allTags) { tag in
                                TagSelectionRow(
                                    tag: tag,
                                    cigarettesInRange: cigarettesInRange
                                ) {
                                    onTagSelected(tag)
                                    dismiss()
                                }
                            }
                        }
                        .padding()
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Select Tag")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("New Tag") {
                        showingCreateTag = true
                    }
                }
            }
            .sheet(isPresented: $showingCreateTag) {
                CreateNewTagSheet(
                    tagName: $newTagName,
                    tagColor: $newTagColor,
                    isPresented: $showingCreateTag,
                    onSave: { tag in
                        onTagSelected(tag)
                        dismiss()
                    }
                )
                .presentationDetents([.medium])
            }
        }
    }
}