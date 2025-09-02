// filepath: /Users/roberdan/Desktop/MirrorSmoker/MirrorSmokerStopper/Utilities/DesignSystemViews.swift
//
//  DesignSystemViews.swift
//  MirrorSmokerStopper
//
//  Created by Assistant on 09/01/25.
//

import SwiftUI

// Section header used to display section titles
struct DSSectionHeader: View {
    let title: String
    let subtitle: String?

    init(_ title: String, subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Space.xs) {
            HStack(alignment: .center, spacing: 0) {
                Text(title)
                    .font(DS.Text.title3)
                    .foregroundStyle(DS.Colors.textPrimary)
                Spacer()
            }
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(DS.Text.caption)
                    .foregroundStyle(DS.Colors.textSecondary)
            }
        }
        .padding(.bottom, DS.Space.xs)
    }
}