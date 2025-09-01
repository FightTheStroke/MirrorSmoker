//
//  TodayCigarettesList.swift
//  Mirror Smoker
//
//  Created by Roberto D'Angelo on 27/08/24.
//

import SwiftUI
import SwiftData

struct TodayCigarettesList: View {
    // Make parameters optional with default values
    var todayCigarettes: [Cigarette] = []
    var onDelete: (Cigarette) -> Void = { _ in }
    var onAddTags: (Cigarette) -> Void = { _ in }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text(NSLocalizedString("todays.cigarettes", comment: ""))
                    .font(.headline)
                
                Spacer()
            }
            
            if todayCigarettes.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "lungs.fill")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    
                    Text(NSLocalizedString("today.cigarettes.list.empty", comment: ""))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            } else {
                ForEach(todayCigarettes, id: \.id) { cigarette in
                    HStack {
                        Image(systemName: "lungs.fill")
                            .foregroundColor(.red)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(cigarette.timestamp, format: .dateTime.hour().minute())
                                .font(.subheadline)
                            
                            // Safely unwrap optional tags
                            if let tags = cigarette.tags, !tags.isEmpty {
                                HStack {
                                    ForEach(tags.prefix(3)) { tag in
                                        Text(tag.name)
                                            .font(.caption2)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.blue)
                                            .foregroundColor(.white)
                                            .cornerRadius(4)
                                    }
                                    
                                    if tags.count > 3 {
                                        Text("+\(tags.count - 3)")
                                            .font(.caption2)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.gray)
                                            .foregroundColor(.white)
                                            .cornerRadius(4)
                                    }
                                }
                            }
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 8) {
                            Button(action: {
                                onAddTags(cigarette)
                            }) {
                                Image(systemName: "tag")
                                    .foregroundColor(.blue)
                            }
                            
                            Button(action: {
                                onDelete(cigarette)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                }
            }
        }
    }
}

#Preview {
    TodayCigarettesList()
}