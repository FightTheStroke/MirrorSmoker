//
//  FloatingActionButton.swift
//  Mirror Smoker
//
//  Created by Roberto D'Angelo on 31/08/25.
//

import SwiftUI

struct FloatingActionButton: View {
    let footerHeight: CGFloat
    let onQuickAdd: () -> Void
    let onAddWithTags: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: onQuickAdd) {
                    Image(systemName: "plus")
                        .font(.title2)
                        .padding(16)
                        .background(
                            Circle().fill(Color.red)
                        )
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.18), radius: 8, x: 0, y: 4)
                }
                .contextMenu {
                    Button(action: onAddWithTags) {
                        Label(String(localized: "button.add.with.tags", defaultValue: "Aggiungi con tag"), systemImage: "tag.fill")
                    }
                }
                .padding(.trailing, 16)
                .padding(.bottom, footerHeight + 8)
                .accessibilityLabel(String(localized: "a11y.new.cigarette", defaultValue: "Nuova sigaretta"))
                .accessibilityHint(String(localized: "a11y.new.cigarette.hint", defaultValue: "Tocco: aggiunge subito. Premi a lungo per aggiungere con tag."))
            }
        }
        .allowsHitTesting(true)
    }
}

#Preview {
    FloatingActionButton(
        footerHeight: 60,
        onQuickAdd: {},
        onAddWithTags: {}
    )
}
