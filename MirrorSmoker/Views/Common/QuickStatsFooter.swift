//
//  QuickStatsFooter.swift
//  Mirror Smoker
//
//  Created by Roberto D'Angelo on 31/08/25.
//

import SwiftUI

struct QuickStatsFooter: View {
    let todayCount: Int
    let yesterdayCount: Int
    let deltaTodayVsYesterday: Int
    let percentChangeTodayVsYesterday: Double?
    let onShowWeeklyStats: () -> Void
    
    private let footerEstimatedHeight: CGFloat = 60
    
    var body: some View {
        VStack(spacing: 0) {
            // Bordo superiore sottile per separare dalla List
            Rectangle()
                .fill(Color.black.opacity(0.06))
                .frame(height: 0.5)
                .edgesIgnoringSafeArea(.horizontal)
            
            HStack(spacing: 10) {
                // Oggi
                compactChip(
                    title: String(localized: "today.title", defaultValue: "Oggi"),
                    value: "\(todayCount)",
                    accent: todayCount == 0 ? .green : todayCount <= 5 ? .blue : todayCount <= 10 ? .orange : .red
                )
                
                // Ieri
                compactChip(
                    title: String(localized: "yesterday.title", defaultValue: "Ieri"),
                    value: "\(yesterdayCount)",
                    accent: .primary
                )
                
                // Diff + %
                compactDiffChip
                
                // Report (icona)
                Button(action: onShowWeeklyStats) {
                    Image(systemName: "chart.bar")
                        .font(.headline)
                        .frame(width: 40, height: 40)
                        .background(Color.clear)
                        .contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .accessibilityLabel(String(localized: "a11y.full.stats", defaultValue: "Statistiche complete"))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, minHeight: footerEstimatedHeight, alignment: .center)
            .background(Color(.secondarySystemBackground))
        }
    }
    
    // Elemento uniforme compatto
    private func compactChip(title: String, value: String, accent: Color) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(accent)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, minHeight: 40)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(.systemBackground))
        )
    }
    
    // Chip combinato differenza + percentuale, compatto
    private var compactDiffChip: some View {
        let diff = deltaTodayVsYesterday
        let isUp = diff > 0
        let neutral = diff == 0
        let fg: Color = neutral ? .secondary : (isUp ? .red : .green)
        let bg = (neutral ? Color.gray : (isUp ? Color.red : Color.green)).opacity(0.12)
        
        return VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: neutral ? "equal" : (isUp ? "arrow.up" : "arrow.down"))
                    .font(.caption)
                Text(neutral ? "0" : "\(abs(diff))")
                    .font(.subheadline).bold()
            }
            HStack(spacing: 4) {
                Image(systemName: percentChangeTodayVsYesterday == nil ? "percent" : (isUp ? "arrow.up.right" : "arrow.down.right"))
                    .font(.caption2)
                Text(percentText)
                    .font(.caption).bold()
            }
        }
        .frame(maxWidth: .infinity, minHeight: 40)
        .padding(.vertical, 6)
        .foregroundColor(fg)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(bg)
                        .opacity(0.5)
                )
        )
    }
    
    private var percentText: String {
        if let pct = percentChangeTodayVsYesterday {
            return String(format: "%@%.0f%%", deltaTodayVsYesterday > 0 ? "+" : "", abs(pct))
        } else {
            return yesterdayCount == 0 ? "n/d" : "0%"
        }
    }
}

#Preview {
    QuickStatsFooter(
        todayCount: 5,
        yesterdayCount: 8,
        deltaTodayVsYesterday: -3,
        percentChangeTodayVsYesterday: -37.5,
        onShowWeeklyStats: {}
    )
}
