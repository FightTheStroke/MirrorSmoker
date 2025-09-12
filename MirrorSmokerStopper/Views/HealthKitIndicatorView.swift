//
//  HealthKitIndicatorView.swift
//  MirrorSmokerStopper
//
//  Created to satisfy Apple's requirement for clear HealthKit identification
//

import SwiftUI

struct HealthKitIndicatorView: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "heart.text.square.fill")
                .font(.system(size: 20))
                .foregroundColor(.pink)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Powered by Apple HealthKit")
                    .font(.caption)
                    .fontWeight(.medium)
                
                Text("Health data analysis on device")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.pink.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(Color.pink.opacity(0.3), lineWidth: 1)
        )
    }
}

struct HealthKitMiniIndicator: View {
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "heart.text.square.fill")
                .font(.caption2)
                .foregroundColor(.pink)
            Text("HealthKit")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        HealthKitIndicatorView()
        HealthKitMiniIndicator()
    }
    .padding()
}