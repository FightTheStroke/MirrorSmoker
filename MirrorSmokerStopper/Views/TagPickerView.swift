import SwiftUI
import SwiftData
import os.log

struct TagPickerView: View {
    @Binding var selectedTags: [Tag]
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Tag.name) private var allTags: [Tag]
    @State private var showingCreateTag = false
    @State private var newTagName = ""
    @State private var newTagColor = Color.blue
    
    // Predefined colors for tags
    let tagColors: [Color] = [
        .blue, .red, .green, .orange, .purple, .pink, .yellow, .gray,
        .indigo, .teal, .mint, .cyan, .brown
    ]
    
    private static let logger = Logger(subsystem: "com.fightthestroke.MirrorSmokerStopper", category: "TagPickerView")
    
    var body: some View {
        VStack(spacing: DS.Space.md) {
            // Header
            HStack {
                Text(NSLocalizedString("tags.select.title", comment: ""))
                    .font(DS.Text.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.horizontal)
            
            // Selected tags preview
            if !selectedTags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DS.Space.sm) {
                        ForEach(selectedTags) { tag in
                            HStack(spacing: DS.Space.xs) {
                                Circle()
                                    .fill(tag.color)
                                    .frame(width: 12, height: 12)
                                Text(TagManager.localizedName(for: tag))
                                    .font(DS.Text.caption)
                                    .fontWeight(.medium)
                                Image(systemName: "xmark.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(DS.Colors.textSecondary)
                            }
                            .padding(.horizontal, DS.Space.sm)
                            .padding(.vertical, DS.Space.xs)
                            .background(DS.Colors.backgroundSecondary)
                            .cornerRadius(12)
                            .onTapGesture {
                                removeTag(tag)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            // All tags list
            if allTags.isEmpty {
                VStack(spacing: DS.Space.md) {
                    Image(systemName: "tag.slash")
                        .font(.largeTitle)
                        .foregroundColor(DS.Colors.textSecondary)
                    Text(NSLocalizedString("tags.none.subtitle", comment: ""))
                        .font(DS.Text.body)
                        .foregroundColor(DS.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .frame(maxWidth: .infinity, maxHeight: 200)
            } else {
                ScrollView {
                    LazyVStack(spacing: DS.Space.sm) {
                        ForEach(allTags) { tag in
                            TagRowView(tag: tag, isSelected: selectedTags.contains(where: { $0.id == tag.id })) {
                                toggleTagSelection(tag)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            // Create new tag button
            DSButton(
                NSLocalizedString("tags.create.title", comment: ""),
                icon: "plus",
                style: .secondary
            ) {
                showingCreateTag = true
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .sheet(isPresented: $showingCreateTag) {
            CreateTagView(
                tagName: $newTagName,
                tagColor: $newTagColor,
                isPresented: $showingCreateTag
            ) { name, color in
                createNewTag(name: name, color: color)
            }
        }
    }
    
    private func toggleTagSelection(_ tag: Tag) {
        if let idx = selectedTags.firstIndex(where: { $0.id == tag.id }) {
            selectedTags.remove(at: idx)
        } else {
            selectedTags.append(tag)
        }
    }
    
    private func removeTag(_ tag: Tag) {
        if let idx = selectedTags.firstIndex(where: { $0.id == tag.id }) {
            selectedTags.remove(at: idx)
        }
    }
    
    private func createNewTag(name: String, color: Color) {
        let newTag = Tag()
        newTag.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        newTag.colorHex = color.toHex() ?? "#007AFF"
        
        modelContext.insert(newTag)
        
        do {
            try modelContext.save()
        } catch {
            Self.logger.error("Error creating tag: \(error.localizedDescription)")
        }
    }
}

// MARK: - Tag Row View
struct TagRowView: View {
    let tag: Tag
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        HStack {
            HStack(spacing: DS.Space.md) {
                Circle()
                    .fill(tag.color)
                    .frame(width: 16, height: 16)
                
                Text(TagManager.localizedName(for: tag))
                    .font(DS.Text.body)
                    .foregroundColor(DS.Colors.textPrimary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(DS.Colors.primary)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, DS.Space.sm)
            .background(isSelected ? DS.Colors.primary.opacity(0.1) : DS.Colors.backgroundSecondary)
            .cornerRadius(10)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - Create Tag View
struct CreateTagView: View {
    @Binding var tagName: String
    @Binding var tagColor: Color
    @Binding var isPresented: Bool
    let onSave: (String, Color) -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: DS.Space.lg) {
                // Tag name input
                VStack(alignment: .leading, spacing: DS.Space.sm) {
                    Text(NSLocalizedString("TagManager.localizedName(for: tag).label", comment: ""))
                        .font(DS.Text.body)
                        .fontWeight(.medium)
                    
                    TextField(NSLocalizedString("tag.placeholder.example", comment: ""), text: $tagName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textInputAutocapitalization(.words)
                }
                .padding(.horizontal)
                
                // Color selection
                VStack(alignment: .leading, spacing: DS.Space.sm) {
                    Text(NSLocalizedString("color.label", comment: ""))
                        .font(DS.Text.body)
                        .fontWeight(.medium)
                    
                    // Predefined colors grid
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: DS.Space.sm), count: 6), spacing: DS.Space.sm) {
                        ForEach(tagColors, id: \.self) { color in
                            Circle()
                                .fill(color)
                                .frame(width: 30, height: 30)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: tagColor == color ? 3 : 0)
                                )
                                .onTapGesture {
                                    tagColor = color
                                }
                        }
                    }
                }
                .padding(.horizontal)
                
                // Preview
                VStack(alignment: .leading, spacing: DS.Space.sm) {
                    Text(NSLocalizedString("preview.label", comment: ""))
                        .font(DS.Text.body)
                        .fontWeight(.medium)
                    
                    HStack(spacing: DS.Space.md) {
                        Circle()
                            .fill(tagColor)
                            .frame(width: 16, height: 16)
                        
                        Text(tagName.isEmpty ? NSLocalizedString("TagManager.localizedName(for: tag).preview", comment: "") : tagName)
                            .font(DS.Text.body)
                            .foregroundColor(DS.Colors.textPrimary)
                        
                        Spacer()
                    }
                    .padding()
                    .background(DS.Colors.backgroundSecondary)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle(NSLocalizedString("new.tag.title", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(NSLocalizedString("cancel.button", comment: "")) {
                        isPresented = false
                        tagName = ""
                        tagColor = .blue
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("save.button", comment: "")) {
                        if !tagName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            onSave(tagName, tagColor)
                            tagName = ""
                            tagColor = .blue
                            isPresented = false
                        }
                    }
                    .fontWeight(.semibold)
                    .disabled(tagName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    // Predefined colors for tags
    let tagColors: [Color] = [
        .blue, .red, .green, .orange, .purple, .pink, .yellow, .gray,
        .indigo, .teal, .mint, .cyan, .brown
    ]
}

// MARK: - Color Extension
extension Color {
    func toHex() -> String? {
        let uic = UIColor(self)
        guard let components = uic.cgColor.components, components.count >= 3 else {
            return nil
        }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        return String(format: "#%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
    }
    
}