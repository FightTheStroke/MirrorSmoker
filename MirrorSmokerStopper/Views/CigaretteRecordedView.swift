//
//  CigaretteRecordedView.swift
//  MirrorSmokerStopper
//
//  Created by Assistant on 02/01/25.
//

import SwiftUI
import WidgetKit

struct CigaretteRecordedView: View {
    let timestamp: Date
    let tags: [String]?
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.largeTitle)
                .foregroundColor(.green)
            
            Text("Cigarette Recorded")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                Text("Time: \(timestamp.formatted(date: .omitted, time: .shortened))")
                    .font(.body)
                    .foregroundColor(.secondary)
                
                if let tags = tags, !tags.isEmpty {
                    Text("Tags: \(tags.joined(separator: ", "))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Text("Keep tracking your progress!")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}