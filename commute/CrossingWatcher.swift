//
//  CrossingWatcher.swift
//  commute
//
//  Created by Drew Goldstein on 4/20/25.
//

// File: CrossingWatcher.swift   (iOS app target)
import Foundation
import CoreLocation
import Combine
import SwiftData
import ActivityKit

@MainActor
final class CrossingWatcher: NSObject, ObservableObject, CLLocationManagerDelegate {

    static let shared = CrossingWatcher()
    @Published var statusText = "…"

    private let loc  = CLLocationManager()
    private let car  = CarConnectionMonitor()
    private let store: ModelContainer
    private var cancellables = Set<AnyCancellable>()

    private let triRailURL = URL(string: "https://gtfsr.tri-rail.com/TripUpdate.pb")!
    private let bridgeURL  = URL(string: "https://api.fl511.com/drawbridges?ids=123")!

    private var currentActivity: Activity<widgetAttributes>?     // ⬅ use widgetAttributes

    private override init() {
        store = try! ModelContainer(for: Crossing.self)
        super.init()
        loc.delegate = self
        loc.requestAlwaysAuthorization()
        loc.desiredAccuracy = kCLLocationAccuracyBest
        loc.startUpdatingLocation()

        car.$inCar
            .sink { [weak self] _ in self?.evaluateNow() }
            .store(in: &cancellables)
    }

    func locationManager(_ m: CLLocationManager, didUpdateLocations _: [CLLocation]) {
        evaluateNow()
    }

    private func evaluateNow() {
        guard car.inCar, let here = loc.location else { return }
        Task { await computeIfNeeded(from: here) }
    }

    private func nearest(from pos: CLLocation) -> Crossing? {
        let all = (try? store.mainContext.fetch(FetchDescriptor<Crossing>())) ?? []
        return all.min { pos.distance(from: $0.location) < pos.distance(from: $1.location) }
    }

    private func computeIfNeeded(from pos: CLLocation) async {
        guard let cross = nearest(from: pos),
              pos.distance(from: cross.location) < 1_600 else { return }

        let etaMin = Int(pos.distance(from: cross.location) / 15.0)
        let summary = "⏱️ \(cross.name) in \(etaMin) min – clear"
        cross.lastStatus = summary
        try? store.mainContext.save()
        if summary != statusText { statusText = summary }
        try? await publish(cross: cross, eta: etaMin, summary: summary)
    }

    private func publish(cross: Crossing, eta: Int, summary: String) async throws {
        let state = widgetAttributes.ContentState(minutes: eta, summary: summary)
        if let activity = currentActivity {
            await activity.update(ActivityContent(state: state, staleDate: .now + 15*60))
        } else {
            let attr = widgetAttributes(crossingName: cross.name)
            currentActivity = try Activity.request(
                attributes: attr,
                content: ActivityContent(state: state, staleDate: .now + 15*60)
            )
        }
    }
}
