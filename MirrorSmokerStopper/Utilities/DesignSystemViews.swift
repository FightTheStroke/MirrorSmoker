// filepath: /Users/roberdan/Desktop/MirrorSmoker/MirrorSmokerStopper/Utilities/DesignSystemViews.swift
//
//  DesignSystemViews.swift
//  MirrorSmokerStopper
//
//  Created by Assistant on 09/01/25.
//

import SwiftUI

// Simple card container used across the app
struct DSCard<Content: View>: View {
    private let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Space.md) {
            content()
        }
        .padding(DS.Space.md)
        .background(DS.Colors.card)
        .cornerRadius(DS.Size.cardRadius)
        .dsShadow(DS.Shadow.small)
    }
}

// Section header used to display section titles
struct DSSectionHeader: View {
    let title: String

    init(_ title: String) {
        self.title = title
    }

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Text(title)
                .font(DS.Text.title3)
                .foregroundStyle(DS.Colors.textPrimary)
            Spacer()
        }
        .padding(.bottom, DS.Space.xs)
    }
}
