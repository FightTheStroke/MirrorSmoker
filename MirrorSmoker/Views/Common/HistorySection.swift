//
//  HistorySection.swift
//  Mirror Smoker
//
//  Created by Roberto D'Angelo on 31/08/25.
//

import SwiftUI
import SwiftData

struct HistorySection: View {
    let dailyStats: [(Date, Int)]
    let cigarettes: [Cigarette]
    
    var body: some View {
        if !dailyStats.isEmpty && dailyStats.count > 1 {
            Section(String(localized: "section.history", defaultValue: "Storico")) {
                ForEach(dailyStats.dropFirst(), id: \.0) { date, count in
                    NavigationLink {
                        DayDetailView(date: date, cigarettes: cigarettes.filter { $0.dayOnly == date })
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(date, format: .dateTime.weekday(.wide).day().month())
                                    .font(.headline)
                                Text("\(count) \(String(localized: "cigarettes", defaultValue: "sigarette"))")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Circle()
                                .fill(count > 20 ? Color.red : count > 10 ? Color.orange : Color.green)
                                .frame(width: 12, height: 12)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    List {
        HistorySection(
            dailyStats: [
                (Date(), 5),
                (Calendar.current.date(byAdding: .day, value: -1, to: Date())!, 8)
            ],
            cigarettes: []
        )
    }
}
