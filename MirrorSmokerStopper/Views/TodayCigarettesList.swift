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
                    // Prima riga: ora + azioni
                    HStack(spacing: DS.Space.md) {
                        Image(systemName: "lungs.fill")
                            .foregroundColor(DS.Colors.cigarette)
                            .font(.system(size: DS.Size.iconSize))
                        
                        Text(cigarette.timestamp, format: .dateTime.hour().minute())
                            .font(DS.Text.body)
                            .fontWeight(.medium)
                        
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
                    
                    if let tags = cigarette.tags, !tags.isEmpty {
                        // Layout che fa andare i tag prima sulla stessa riga, poi a capo
                        WrappingHStack(tags: tags) { tag in
                            Text(tag.name)
                                .font(DS.Text.caption)
                                .padding(.horizontal, DS.Space.sm)
                                .padding(.vertical, DS.Space.xs)
                                .background(tag.color)
                                .foregroundColor(.white)
                                .cornerRadius(DS.Size.buttonRadius / 2)
                        }
                        .padding(.leading, DS.Size.iconSize + DS.Space.md) // Allineato con il testo
                    }
                }
                .padding(.vertical, DS.Space.md)
                .padding(.horizontal, DS.Space.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(DS.Size.buttonRadius)
            }
        }
    }
}

// Helper per layout tag che vanno a capo quando necessario
struct WrappingHStack<Data: RandomAccessCollection, Content: View>: View where Data.Element: Identifiable {
    let tags: Data
    let content: (Data.Element) -> Content
    
    var body: some View {
        GeometryReader { geometry in
            self.generateContent(in: geometry)
        }
        .frame(height: calculateHeight(for: tags, in: UIScreen.main.bounds.width - 100))
    }
    
    private func generateContent(in geometry: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        var lineHeight = CGFloat.zero
        
        return ZStack(alignment: .topLeading) {
            ForEach(Array(tags.enumerated()), id: \.element.id) { index, tag in
                content(tag)
                    .background(
                        GeometryReader { geo in
                            Color.clear.onAppear {
                                let tagWidth = geo.size.width
                                let tagHeight = geo.size.height
                                
                                if width + tagWidth > geometry.size.width {
                                    width = tagWidth + DS.Space.xs
                                    height += lineHeight + DS.Space.xs
                                    lineHeight = tagHeight
                                } else {
                                    width += tagWidth + DS.Space.xs
                                    lineHeight = max(lineHeight, tagHeight)
                                }
                            }
                        }
                    )
                    .offset(x: calculateXOffset(for: index, in: geometry.size.width),
                           y: calculateYOffset(for: index, in: geometry.size.width))
            }
        }
    }
    
    private func calculateXOffset(for index: Int, in width: CGFloat) -> CGFloat {
        // Calcolo semplificato per demo - in implementazione reale sarebbe più complesso
        let itemsPerRow = max(1, Int(width / 100))
        return CGFloat(index % itemsPerRow) * 100
    }
    
    private func calculateYOffset(for index: Int, in width: CGFloat) -> CGFloat {
        let itemsPerRow = max(1, Int(width / 100))
        return CGFloat(index / itemsPerRow) * 35
    }
    
    private func calculateHeight(for items: Data, in width: CGFloat) -> CGFloat {
        let itemsPerRow = max(1, Int(width / 100))
        let rows = (items.count + itemsPerRow - 1) / itemsPerRow
        return CGFloat(rows * 35)
    }
}

struct TodayCigarettes_Preview: PreviewProvider {
    static var previews: some View {
        TodayCigarettesList()
            .modelContainer(for: [Cigarette.self, Tag.self, UserProfile.self], inMemory: true)
    }
}