import SwiftUI
import SwiftData

struct TodayCigarettesList: View {
    var todayCigarettes: [Cigarette] = []
    var onDelete: (Cigarette) -> Void = { _ in }
    var onAddTags: (Cigarette) -> Void = { _ in }
    
    var body: some View {
        Section {
            ForEach(todayCigarettes, id: \.id) { cigarette in
                HStack(spacing: DS.Space.md) {
                    Image(systemName: "lungs.fill")
                        .foregroundColor(DS.Colors.cigarette)
                        .font(.system(size: DS.Size.iconSize))
                    
                    Text(cigarette.timestamp, format: .dateTime.hour().minute())
                        .font(DS.Text.body)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    if let tags = cigarette.tags, !tags.isEmpty {
                        HStack(spacing: DS.Space.xs) {
                            ForEach(tags.prefix(3)) { tag in
                                Text(tag.name)
                                    .font(DS.Text.caption2)
                                    .padding(.horizontal, DS.Space.xs)
                                    .padding(.vertical, 2)
                                    .background(tag.color)
                                    .foregroundColor(.white)
                                    .cornerRadius(6)
                            }
                            
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
                .listRowInsets(EdgeInsets(top: DS.Space.md, leading: 0, bottom: DS.Space.md, trailing: 0))
                .listRowBackground(Color(.secondarySystemGroupedBackground))
                .swipeActions(edge: .leading) {
                    Button {
                        onAddTags(cigarette)
                    } label: {
                        Label(NSLocalizedString("add.tags", comment: ""), systemImage: "tag")
                    }
                    .tint(DS.Colors.primary)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        onDelete(cigarette)
                    } label: {
                        Label(NSLocalizedString("delete", comment: ""), systemImage: "trash")
                    }
                }
            }
        } header: {
            HStack {
                Text(NSLocalizedString("todays.cigarettes", comment: ""))
                    .font(DS.Text.body)
                    .foregroundColor(DS.Colors.textPrimary)
                Spacer()
            }
        }
    }
}