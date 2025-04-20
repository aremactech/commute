//
//  widgetController.swift
//  commute
//
//  Created by Drew Goldstein on 4/20/25.
//

import Foundation
import ActivityKit

@MainActor
enum widgetController {

    private static var activity: Activity<widgetAttributes>?

    // ─────────────────────────────────────────────
    // Convenience: Kick‑off with the user’s first crossing
    // ─────────────────────────────────────────────
    static func startNow() async throws {
        // Use the first saved crossing if available; otherwise fall back to a placeholder.
        let cross = CrossingStore.shared.crossings.first ?? Crossing(name: "Unknown", lat: 0, lon: 0)

        // Initial  “calculating…” summary
        let summary = "⏱️ \(cross.name) – calculating…"
        try await start(name: cross.name, minutes: 0, summary: summary)
    }

    // ─────────────────────────────────────────────
    // Explicit requester
    // ─────────────────────────────────────────────
    static func start(name: String, minutes: Int, summary: String) async throws {
        let attr    = widgetAttributes(crossingName: name)
        let content = ActivityContent(
            state: widgetAttributes.ContentState(minutes: minutes, summary: summary),
            staleDate: Date.now.addingTimeInterval(15 * 60)   // +15 min
        )
        activity = try Activity.request(attributes: attr, content: content)
    }

    // ─────────────────────────────────────────────
    // Publish incremental updates
    // ─────────────────────────────────────────────
    static func update(minutes: Int, summary: String) async throws {
        guard let act = activity else { return }
        let content = ActivityContent(
            state: widgetAttributes.ContentState(minutes: minutes, summary: summary),
            staleDate: Date.now.addingTimeInterval(15 * 60)
        )
        await act.update(content)
    }
}
