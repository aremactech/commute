//
//  CrossingStore.swift
//  commute
//
//  Created by Drew Goldstein on 4/8/25.
//

import Foundation
import SwiftData

/// Shared SwiftData wrapper that keeps the `Crossing` list in memory
/// and syncs it with the new Commute API.
@MainActor
final class CrossingStore: ObservableObject {

    // MARK: – Singleton
    static let shared = CrossingStore()

    // MARK: – Published list used by SwiftUI views
    @Published private(set) var crossings: [Crossing] = []

    // MARK: – SwiftData context
    private let context: ModelContext

    // MARK: – Init
    private init() {
        // Fatal if SwiftData container fails ‑ early crash in dev
        context = ModelContext(try! ModelContainer(for: Crossing.self))
        load()
        Task { await refreshFromAPI() }          // initial sync
    }

    // MARK: – Public CRUD helpers
    func add(name: String, lat: Double, lon: Double) {
        let c = Crossing(name: name, lat: lat, lon: lon)
        context.insert(c)
        load()
    }

    func delete(_ offsets: IndexSet) {
        offsets.map { crossings[$0] }.forEach(context.delete)
        load()
    }

    // MARK: – Load from SwiftData
    func load() {
        crossings = (try? context.fetch(FetchDescriptor<Crossing>())) ?? []
    }

    // MARK: – API sync
    /// Pull latest crossings from the Commute API and upsert into SwiftData.
    func refreshFromAPI() async {
        guard let apiList = try? await CommuteAPI.fetchCrossings() else { return }

        // Index current crossings by id for quick lookup
        var existingDict = Dictionary(uniqueKeysWithValues:
            crossings.map { ($0.id.uuidString, $0) })

        for dto in apiList {
            if let existing = existingDict[dto.id] {
                // update existing
                existing.name = dto.name
                existing.lat  = dto.location.latitude
                existing.lon  = dto.location.longitude
                existing.lastStatus = dto.status.rawValue
            } else {
                // insert new
                let c = Crossing(name: dto.name,
                                 lat: dto.location.latitude,
                                 lon: dto.location.longitude)
                c.lastStatus = dto.status.rawValue
                context.insert(c)
            }
        }
        await MainActor.run { load() }
    }
}
