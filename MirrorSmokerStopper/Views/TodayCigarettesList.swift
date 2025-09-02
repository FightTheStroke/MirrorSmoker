import SwiftUI
import SwiftData

struct TodayCigarettesList: View {
    var todayCigarettes: [Cigarette] = []
    var onDelete: (Cigarette) -> Void = { _ in }
    var onAddTags: (Cigarette) -> Void = { _ in }
    
    var body: some View {
        DSCard {
            VStack(spacing: DS.Space.md) {
                DSSectionHeader(NSLocalizedString("todays.cigarettes", comment: ""))
                if todayCigarettes.isEmpty {
                    VStack(spacing: DS.Space.md) {
                        Image(systemName: "lungs.fill")
                            .font(.largeTitle)
                            .foregroundColor(DS.Colors.success)
                        Text(NSLocalizedString("today.cigarettes.list.empty", comment: ""))
                            .font(DS.Text.body)
                            .foregroundColor(DS.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.vertical, DS.Space.lg)
                } else {
                    VStack(spacing: DS.Space.sm) {
                        ForEach(todayCigarettes, id: \.id) { cigarette in
                            HStack(spacing: DS.Space.md) {
                                Image(systemName: "lungs.fill")
                                    .foregroundColor(DS.Colors.cigarette)
                                    .font(.system(size: DS.Size.iconSize))
                                
                                VStack(alignment: .leading, spacing: DS.Space.xs) {
                                    Text(cigarette.timestamp, format: .dateTime.hour().minute())
                                        .font(DS.Text.body)
                                        .fontWeight(.medium)
                                    
                                    if let tags = cigarette.tags, !tags.isEmpty {
                                        HStack(spacing: DS.Space.xs) {
                                            ForEach(tags.prefix(3)) { tag in
                                                Text(tag.name)
                                                    .font(DS.Text.small)
                                                    .padding(.horizontal, DS.Space.sm)
                                                    .padding(.vertical, DS.Space.xs)
                                                    .background(tag.color)
                                                    .foregroundColor(.white)
                                                    .cornerRadius(DS.Size.buttonRadius / 2)
                                            }
                                            if tags.count > 3 {
                                                Text("+\(tags.count - 3)")
                                                    .font(DS.Text.small)
                                                    .padding(.horizontal, DS.Space.sm)
                                                    .padding(.vertical, DS.Space.xs)
                                                    .background(DS.Colors.textSecondary)
                                                    .foregroundColor(.white)
                                                    .cornerRadius(DS.Size.buttonRadius / 2)
                                            }
                                        }
                                    }
                                }
                                Spacer()
                                HStack(spacing: DS.Space.sm) {
                                    Button(action: { onAddTags(cigarette) }) {
                                        Image(systemName: "tag")
                                            .foregroundColor(DS.Colors.primary)
                                            .font(.system(size: DS.Size.iconSize))
                                    }
                                    Button(action: { onDelete(cigarette) }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(DS.Colors.danger)
                                            .font(.system(size: DS.Size.iconSize))
                                    }
                                }
                            }
                            .padding(.vertical, DS.Space.sm)
                            .padding(.horizontal, DS.Space.md)
                            .background(Color(.secondarySystemGroupedBackground))
                            .cornerRadius(DS.Size.buttonRadius)
                        }
                    }
                }
            }
        }
    }
}