import SwiftUI
import SwiftData

struct TagPickerView: View {
    @Binding var selectedTags: [Tag]
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Tag.name) private var allTags: [Tag]
    @State private var showingCreateTag = false
    @State private var newTagName = ""
    @State private var newTagColor = "#007AFF"
    
    var body: some View {
        DSCard {
            VStack(spacing: DS.Space.md) {
                DSSectionHeader(NSLocalizedString("tags.select.title", comment: ""))
                if allTags.isEmpty {
                    VStack(spacing: DS.Space.md) {
                        Image(systemName: "tag")
                            .font(.largeTitle)
                            .foregroundColor(DS.Colors.secondary)
                        Text(NSLocalizedString("tags.none.subtitle", comment: ""))
                            .font(DS.Text.body)
                            .foregroundColor(DS.Colors.textSecondary)
                    }
                } else {
                    ForEach(allTags) { tag in
                        HStack {
                            Circle()
                                .fill(tag.color)
                                .frame(width: 16, height: 16)
                            Text(tag.name)
                                .font(.body)
                            Spacer()
                            if selectedTags.contains(where: { $0.id == tag.id }) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(DS.Colors.primary)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            toggleTagSelection(tag)
                        }
                    }
                }
                DSButton(NSLocalizedString("tags.create.title", comment: ""), icon: "plus", style: .secondary) {
                    showingCreateTag = true
                }
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
}