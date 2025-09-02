import SwiftUI
import SwiftData

struct TodayCigarettesList: View {
    var todayCigarettes: [Cigarette] = []
    var onDelete: (Cigarette) -> Void = { _ in }
    var onAddTags: (Cigarette) -> Void = { _ in }
    
    var body: some View {
        VStack(spacing: DS.Space.sm) {
            ForEach(todayCigarettes, id: \.id) { cigarette in
                VStack(alignment: .leading, spacing: DS.Space.sm) {
                    // Prima riga: ora + tags
                    HStack(spacing: DS.Space.md) {
                        Image(systemName: "lungs.fill")
                            .foregroundColor(DS.Colors.cigarette)
                            .font(.system(size: DS.Size.iconSize))
                        
                        Text(cigarette.timestamp, format: .dateTime.hour().minute())
                            .font(DS.Text.body)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        // Tags in the same line
                        if let tags = cigarette.tags, !tags.isEmpty {
                            HStack(spacing: DS.Space.xs) {
                                ForEach(tags.prefix(3)) { tag in // Limit to 3 tags for space
                                    Text(tag.name)
                                        .font(DS.Text.caption2)
                                        .padding(.horizontal, DS.Space.xs)
                                        .padding(.vertical, 2)
                                        .background(tag.color)
                                        .foregroundColor(.white)
                                        .cornerRadius(6)
                                }
                                
                                // Show +N if there are more tags
                                if tags.count > 3 {
                                    Text("+\(tags.count - 3)")
                                        .font(DS.Text.caption2)
                                        .padding(.horizontal, DS.Space.xs)
                                        .padding(.vertical, 2)
                                        .background(DS.Colors.backgroundSecondary)
                                        .foregroundColor(DS.Colors.textSecondary)
                                        .cornerRadius(6)
                                }
                            }
                        }
                    }
                }
                .padding(.vertical, DS.Space.md)
                .padding(.horizontal, DS.Space.sm) // Ridotto il padding orizzontale
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(DS.Size.buttonRadius)
                .contentShape(Rectangle()) // Necessario per gli swipe
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        onDelete(cigarette)
                    } label: {
                        Label("Elimina", systemImage: "trash")
                    }
                }
                .swipeActions(edge: .leading) {
                    Button {
                        onAddTags(cigarette)
                    } label: {
                        Label("Tag", systemImage: "tag")
                            .labelStyle(.iconOnly)
                    }
                    .tint(DS.Colors.primary)
                }
            }
        }
    }
}