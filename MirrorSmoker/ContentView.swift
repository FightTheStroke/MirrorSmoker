//
//  ContentView.swift
//  Mirror Smoker
//
//  Created by Roberto D'Angelo on 31/08/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Cigarette.timestamp, order: .reverse) private var cigarettes: [Cigarette]
    
    // Statistiche giornaliere
    private var todayCount: Int {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        return cigarettes.filter { $0.timestamp >= today && $0.timestamp < tomorrow }.count
    }
    
    private var yesterdayCount: Int {
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: Date())!
        let startOfYesterday = calendar.startOfDay(for: yesterday)
        let endOfYesterday = calendar.date(byAdding: .day, value: 1, to: startOfYesterday)!
        return cigarettes.filter { $0.timestamp >= startOfYesterday && $0.timestamp < endOfYesterday }.count
    }
    
    private var deltaTodayVsYesterday: Int {
        todayCount - yesterdayCount
    }
    
    private var percentChangeTodayVsYesterday: Double? {
        guard yesterdayCount > 0 else { return nil }
        return (Double(deltaTodayVsYesterday) / Double(yesterdayCount)) * 100.0
    }
    
    private var dailyStats: [(Date, Int)] {
        let grouped = Dictionary(grouping: cigarettes) { cigarette in
            cigarette.dayOnly
        }
        return grouped.map { (date, cigarettes) in
            (date, cigarettes.count)
        }.sorted { $0.0 > $1.0 }
    }
    
    // Altezza stimata della barra footer (più bassa, barra piena)
    private let footerEstimatedHeight: CGFloat = 60

    var body: some View {
        NavigationSplitView {
            ZStack {
                VStack(spacing: 0) {
                    // Header con statistiche del giorno
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "lungs")
                                .font(.title2)
                                .foregroundColor(.red)
                            
                            VStack(alignment: .leading) {
                                Text("Oggi")
                                    .font(.headline)
                                Text("\(todayCount) sigarette")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(todayCount > 20 ? .red : todayCount > 10 ? .orange : .primary)
                            }
                            Spacer()
                        }
                        
                        // Pulsante grande per aggiungere sigaretta
                        Button(action: addCigarette) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                Text("Fumata una sigaretta")
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                    .background(AppColors.systemGray6)
                    
                    // Lista delle sigarette di oggi
                    List {
                        Section("Oggi") {
                            let todayCigarettes = cigarettes.filter { cigarette in
                                Calendar.current.isDateInToday(cigarette.timestamp)
                            }
                            
                            if todayCigarettes.isEmpty {
                                Text("Nessuna sigaretta fumata oggi! 🎉")
                                    .foregroundColor(.secondary)
                                    .italic()
                            } else {
                                ForEach(todayCigarettes) { cigarette in
                                    HStack {
                                        Image(systemName: "smoke")
                                            .foregroundColor(.red)
                                        
                                        VStack(alignment: .leading) {
                                            Text(cigarette.timestamp, format: .dateTime.hour().minute())
                                                .font(.headline)
                                            if !cigarette.note.isEmpty {
                                                Text(cigarette.note)
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        
                                        Spacer()
                                    }
                                }
                                .onDelete(perform: deleteCigarettes)
                            }
                        }
                        
                        if !dailyStats.isEmpty && dailyStats.count > 1 {
                            Section("Storico") {
                                ForEach(dailyStats.dropFirst(), id: \.0) { date, count in
                                    NavigationLink {
                                        DayDetailView(date: date, cigarettes: cigarettes.filter { $0.dayOnly == date })
                                    } label: {
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text(date, format: .dateTime.weekday(.wide).day().month())
                                                    .font(.headline)
                                                Text("\(count) sigarette")
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
                    
                    // Footer barra piena a bordo schermo
                    quickStatsFooter
                        .background(AppColors.secondarySystemBackground)
                        .ignoresSafeArea(edges: [.horizontal]) // occupa tutta la larghezza visibile
                }
                
                // Floating Action Button in basso a destra
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: addCigarette) {
                            Image(systemName: "plus")
                                .font(.title2)
                                .padding(16)
                                .background(
                                    Circle().fill(Color.red)
                                )
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.18), radius: 8, x: 0, y: 4)
                        }
                        .simultaneousGesture(
                            LongPressGesture(minimumDuration: 0.35)
                                .onEnded { _ in showAddWithNoteAlert() }
                        )
                        .padding(.trailing, 16)
                        .padding(.bottom, footerEstimatedHeight + 8)
                        .accessibilityLabel("Nuova sigaretta")
                        .accessibilityHint("Tocco: aggiunge subito. Pressione prolungata: aggiungi con nota.")
                    }
                }
                .allowsHitTesting(true)
            }
            .navigationTitle("Tracker Sigarette")
#if os(macOS)
            .navigationSplitViewColumnWidth(min: 250, ideal: 300)
#endif
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
#endif
            }
        } detail: {
            StatisticsView(cigarettes: cigarettes)
        }
        .alert("Aggiungi nota", isPresented: $showingAddAlert) {
            TextField("Nota opzionale", text: $noteText)
            Button("Aggiungi") { addCigaretteWithNote() }
            Button("Annulla", role: .cancel) { }
        }
        .sheet(isPresented: $showingWeeklyStats) {
            WeeklyStatsView(cigarettes: cigarettes)
        }
    }
    
    // MARK: - Footer View: barra compatta full-width
    private var quickStatsFooter: some View {
        VStack(spacing: 0) {
            // Bordo superiore sottile per separare dalla List
            Rectangle()
                .fill(Color.black.opacity(0.06))
                .frame(height: 0.5)
                .edgesIgnoringSafeArea(.horizontal)
            
            HStack(spacing: 10) {
                // Oggi
                compactChip(
                    title: "Oggi",
                    value: "\(todayCount)",
                    accent: todayCount == 0 ? .green : todayCount <= 5 ? .blue : todayCount <= 10 ? .orange : .red
                )
                
                // Ieri
                compactChip(
                    title: "Ieri",
                    value: "\(yesterdayCount)",
                    accent: .primary
                )
                
                // Diff + %
                compactDiffChip
                
                // Report (icona)
                Button(action: showWeeklyStats) {
                    Image(systemName: "chart.bar")
                        .font(.headline)
                        .frame(width: 40, height: 40)
                        .background(Color.clear)
                        .contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .accessibilityLabel("Statistiche complete")
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, minHeight: footerEstimatedHeight, alignment: .center)
            .background(AppColors.secondarySystemBackground) // stesso colore fino ai bordi
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
                .fill(AppColors.systemBackground)
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
                .fill(AppColors.systemBackground)
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
    
    @State private var showingAddAlert = false
    @State private var showingWeeklyStats = false
    @State private var noteText = ""

    private func addCigarette() {
        withAnimation {
            let newCigarette = Cigarette()
            modelContext.insert(newCigarette)
        }
    }
    
    private func showAddWithNoteAlert() {
        noteText = ""
        showingAddAlert = true
    }
    
    private func addCigaretteWithNote() {
        withAnimation {
            let newCigarette = Cigarette(note: noteText)
            modelContext.insert(newCigarette)
        }
        noteText = ""
    }
    
    private func showWeeklyStats() {
        showingWeeklyStats = true
    }

    private func deleteCigarettes(offsets: IndexSet) {
        withAnimation {
            let todayCigarettes = cigarettes.filter { cigarette in
                Calendar.current.isDateInToday(cigarette.timestamp)
            }
            
            for index in offsets {
                if index < todayCigarettes.count {
                    modelContext.delete(todayCigarettes[index])
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Cigarette.self, inMemory: true)
}
