//
//  ConnectivityManager.swift
//  Mirror Smoker
//
//  Created by Roberto D’Angelo on 31/08/25.
//

import Foundation
import WatchConnectivity
import SwiftData
import Combine

// DTOs per messaggi codificabili (evitiamo di serializzare direttamente i modelli SwiftData)
struct CigaretteDTO: Codable, Identifiable {
    let id: UUID
    let timestamp: Date
    let note: String
    let tagNames: [String]
    
    init(id: UUID = UUID(), timestamp: Date = Date(), note: String = "", tagNames: [String] = []) {
        self.id = id
        self.timestamp = timestamp
        self.note = note
        self.tagNames = tagNames
    }
    
    init(from model: Cigarette) {
        self.id = model.id
        self.timestamp = model.timestamp
        self.note = model.note
        self.tagNames = model.tags.map { $0.name }
    }
}

enum RealtimeMessageType: String, Codable {
    case addCigarette
    case deleteCigarette
    case snapshotToday
}

struct RealtimeEnvelope: Codable {
    let type: RealtimeMessageType
    let payload: Data
}

final class ConnectivityManager: NSObject, ObservableObject {
    static let shared = ConnectivityManager()
    
    private var modelContext: ModelContext?
    
    private override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
        }
    }
    
    func configure(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func activate() {
        guard WCSession.isSupported() else { return }
        WCSession.default.activate()
    }
    
    // MARK: - Send helpers
    
    func sendAddCigarette(_ dto: CigaretteDTO) {
        send(type: .addCigarette, dto: dto)
    }
    
    func sendDeleteCigarette(id: UUID) {
        struct DeleteDTO: Codable { let id: UUID }
        send(type: .deleteCigarette, dto: DeleteDTO(id: id))
    }
    
    // Invia uno snapshot delle sigarette di oggi (fallback o allineamento iniziale)
    func sendTodaySnapshot(from cigarettes: [Cigarette]) {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        let todays = cigarettes.filter { $0.timestamp >= today && $0.timestamp < tomorrow }
        let dtos = todays.map { CigaretteDTO(from: $0) }
        send(type: .snapshotToday, dto: dtos, preferContext: true)
    }
    
    // MARK: - Core send
    
    private func send<T: Codable>(type: RealtimeMessageType, dto: T, preferContext: Bool = false) {
        guard WCSession.isSupported() else { return }
        do {
            let payload = try JSONEncoder().encode(dto)
            let envelope = RealtimeEnvelope(type: type, payload: payload)
            let data = try JSONEncoder().encode(envelope)
            
            let session = WCSession.default
            if session.isReachable, !preferContext {
                session.sendMessage(["realtime": data], replyHandler: nil, errorHandler: nil)
            } else {
                // Fallback: applicationContext tiene l’ultimo snapshot coerente
                try session.updateApplicationContext(["realtime": data])
            }
        } catch {
            // In produzione: loggare errori
        }
    }
}

// MARK: - WCSessionDelegate
extension ConnectivityManager: WCSessionDelegate {
    // iOS-only callbacks
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
    #endif
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // Gestione stato/diagnostica
    }
    
    // Ricezione messaggi in tempo reale
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        guard let data = message["realtime"] as? Data else { return }
        handle(envelopeData: data)
    }
    
    // Ricezione application context (ultimo snapshot)
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        guard let data = applicationContext["realtime"] as? Data else { return }
        handle(envelopeData: data)
    }
    
    // Fallback background via userInfo
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        guard let data = userInfo["realtime"] as? Data else { return }
        handle(envelopeData: data)
    }
    
    // MARK: - Handle incoming
    
    private func handle(envelopeData: Data) {
        guard let envelope = try? JSONDecoder().decode(RealtimeEnvelope.self, from: envelopeData) else { return }
        
        switch envelope.type {
        case .addCigarette:
            if let dto = try? JSONDecoder().decode(CigaretteDTO.self, from: envelope.payload) {
                upsert(dto: dto)
            }
        case .deleteCigarette:
            struct DeleteDTO: Codable { let id: UUID }
            if let dto = try? JSONDecoder().decode(DeleteDTO.self, from: envelope.payload) {
                deleteIfPresent(id: dto.id)
            }
        case .snapshotToday:
            if let dtos = try? JSONDecoder().decode([CigaretteDTO].self, from: envelope.payload) {
                mergeSnapshot(dtos: dtos)
            }
        }
    }
    
    // MARK: - SwiftData apply helpers
    
    private func upsert(dto: CigaretteDTO) {
        guard let modelContext else { return }
        DispatchQueue.main.async {
            let fetch = FetchDescriptor<Cigarette>()
            let existing = try? modelContext.fetch(fetch).first(where: { $0.id == dto.id })
            let c = existing ?? Cigarette(timestamp: dto.timestamp, note: dto.note)
            c.id = dto.id
            c.timestamp = dto.timestamp
            c.note = dto.note
            // Risolvi/crea tag per nome
            c.tags = self.findOrCreateTags(names: dto.tagNames, in: modelContext)
            if existing == nil {
                modelContext.insert(c)
            }
            try? modelContext.save()
        }
    }
    
    private func deleteIfPresent(id: UUID) {
        guard let modelContext else { return }
        DispatchQueue.main.async {
            let fetch = FetchDescriptor<Cigarette>()
            if let existing = try? modelContext.fetch(fetch).first(where: { $0.id == id }) {
                modelContext.delete(existing)
                try? modelContext.save()
            }
        }
    }
    
    private func mergeSnapshot(dtos: [CigaretteDTO]) {
        guard let modelContext else { return }
        DispatchQueue.main.async {
            let fetch = FetchDescriptor<Cigarette>()
            guard let all = try? modelContext.fetch(fetch) else { return }
            let calendar = Calendar.current
            let todayStart = calendar.startOfDay(for: Date())
            let todayEnd = calendar.date(byAdding: .day, value: 1, to: todayStart)!
            let todays = all.filter { $0.timestamp >= todayStart && $0.timestamp < todayEnd }
            let todaysByID = Dictionary(uniqueKeysWithValues: todays.map { ($0.id, $0) })
            
            for dto in dtos {
                if let existing = todaysByID[dto.id] {
                    existing.timestamp = dto.timestamp
                    existing.note = dto.note
                    existing.tags = self.findOrCreateTags(names: dto.tagNames, in: modelContext)
                } else {
                    let c = Cigarette(timestamp: dto.timestamp, note: dto.note)
                    c.id = dto.id
                    c.tags = self.findOrCreateTags(names: dto.tagNames, in: modelContext)
                    modelContext.insert(c)
                }
            }
            try? modelContext.save()
        }
    }
    
    // Risolve o crea Tag per nome. Colori: se non esiste, assegna un default.
    private func findOrCreateTags(names: [String], in context: ModelContext) -> [Tag] {
        guard !names.isEmpty else { return [] }
        let fetch = FetchDescriptor<Tag>()
        let existingTags = (try? context.fetch(fetch)) ?? []
        var result: [Tag] = []
        for name in names {
            if let t = existingTags.first(where: { $0.name.caseInsensitiveCompare(name) == .orderedSame }) {
                result.append(t)
            } else {
                let new = Tag(name: name, color: "#FF6B00")
                context.insert(new)
                result.append(new)
            }
        }
        return result
    }
}
