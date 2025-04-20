//
//  CrossingStore.swift
//  commute
//
//  Created by Drew Goldstein on 4/20/25.
//

import Foundation
import SwiftData

@MainActor
final class CrossingStore: ObservableObject {
    static let shared = CrossingStore()

    @Published private(set) var crossings: [Crossing] = []

    private let context: ModelContext

    // ─────────────────────────────────────────────
    // 1‑line force‑unwrap: crashes early if container fails
    // ─────────────────────────────────────────────
    private init() {
        context = ModelContext(try! ModelContainer(for: Crossing.self))
        load()
    }
    // If you prefer graceful handling, swap the init for:
    /*
    private init() {
        do {
            context = ModelContext(try ModelContainer(for: Crossing.self))
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
        load()
    }
    */

    // MARK: - CRUD
    func load() {
        crossings = (try? context.fetch(FetchDescriptor<Crossing>())) ?? []
    }

    func add(name: String, lat: Double, lon: Double) {
        let x = Crossing(name: name, lat: lat, lon: lon)
        context.insert(x)
        load()
    }

    func delete(_ offsets: IndexSet) {
        offsets.map { crossings[$0] }.forEach(context.delete)
        load()
    }
}
