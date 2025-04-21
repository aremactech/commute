//
//  CrossingWatcher.swift
//  commute
//
//  Created by Drew Goldstein on 4/20/25.
//

import Foundation
import CoreLocation
import Combine
import ActivityKit


@MainActor
final class CrossingWatcher: NSObject, ObservableObject, CLLocationManagerDelegate {

    static let shared = CrossingWatcher()

    // Published properties for UI updates
    @Published var currentSummary: String = "Locating…"
    @Published var crossings: [CommuteAPI.CrossingDTO] = []

    private let loc = CLLocationManager()
    private var pollTimer: AnyCancellable?
    private var currentActivity: Activity<widgetAttributes>?

    private override init() {
        super.init()
        loc.delegate = self
        loc.requestAlwaysAuthorization()
        loc.desiredAccuracy = kCLLocationAccuracyBest
        loc.startUpdatingLocation()

        // Poll new API every 30 s while app is foreground
        pollTimer = Timer.publish(every: 30, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.updateStatus() }
    }

    // CLLocation delegate
    func locationManager(_: CLLocationManager, didUpdateLocations _: [CLLocation]) {
        updateStatus()
    }

    // MARK: - Core logic
    private func updateStatus() {
        guard let here = loc.location else { return }

        Task {
            do {
                // Fetch all crossings
                crossings = try await CommuteAPI.fetchCrossings()
                
                // Find nearest crossing
                guard let dto = try await nearestCrossing(to: here) else { return }

                // Convert API location to CoreLocation
                let dtoCoord = CLLocation(latitude: dto.location.latitude,
                                          longitude: dto.location.longitude)

                let etaMin = Int(here.distance(from: dtoCoord) / 15.0)        // 15 m/s ≈ 34 mph
                let statusText = dto.status.rawValue   // enum's raw String
                let summary = "⏱️ \(dto.name) in \(etaMin) min – \(statusText.capitalized)"

                await MainActor.run {
                    currentSummary = summary
                    try? publishLiveActivity(name: dto.name, eta: etaMin, summary: summary)
                }
            } catch {
                print("Error updating status: \(error)")
            }
        }
    }

    private func nearestCrossing(to pos: CLLocation) async throws -> CommuteAPI.CrossingDTO? {
        return crossings.min {
            let a = CLLocation(latitude: $0.location.latitude, longitude: $0.location.longitude)
            let b = CLLocation(latitude: $1.location.latitude, longitude: $1.location.longitude)
            return pos.distance(from: a) < pos.distance(from: b)
        }
    }

    // MARK: - Live Activity
    private func publishLiveActivity(name: String, eta: Int, summary: String) throws {
        let state = widgetAttributes.ContentState(minutes: eta, summary: summary)

        if let act = currentActivity {
            Task { await act.update(ActivityContent(state: state, staleDate: .now + 15*60)) }
        } else {
            let attr = widgetAttributes(crossingName: name)
            currentActivity = try Activity.request(
                attributes: attr,
                content: ActivityContent(state: state, staleDate: .now + 15*60))
        }
    }

    // ─────────────────────────────────────────
    // Called by widgetController.startNow()
    // ─────────────────────────────────────────
    func manualTrigger(for dto: CommuteAPI.CrossingDTO, initial summary: String) async throws {
        try publishLiveActivity(name: dto.name, eta: 0, summary: summary)
    }
}
