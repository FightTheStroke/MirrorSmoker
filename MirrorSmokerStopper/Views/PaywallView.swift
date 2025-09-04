//
//  PaywallView.swift
//  MirrorSmokerStopper
//
//  Created by Claude on 03/09/25.
//

import SwiftUI

struct PaywallView: View {
    let trigger: StoreConfiguration.PaywallTrigger
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("settings.premium.title".local())
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("settings.premium.description".local())
                    .multilineTextAlignment(.center)
                    .padding()
                
                // Placeholder premium features list
                VStack(alignment: .leading, spacing: 10) {
                    FeatureRow(icon: "brain.head.profile", text: "AI Coaching")
                    FeatureRow(icon: "chart.bar.fill", text: "Advanced Analytics")
                    FeatureRow(icon: "tag.fill", text: "Unlimited Tags")
                    FeatureRow(icon: "square.and.arrow.up", text: "Data Export")
                }
                .padding()
                
                Spacer()
                
                Button(action: {
                    dismiss()
                }) {
                    Text("settings.continue.free".local())
                        .foregroundColor(.secondary)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("close".local()) {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            Text(text)
            Spacer()
        }
    }
}

#Preview {
    PaywallView(trigger: .settingsUpgrade)
}