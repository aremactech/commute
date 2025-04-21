//
//  LiveActivityManager.swift
//  commute
//
//  Created by Drew Goldstein on 4/20/25.
//

import ActivityKit
import CoreLocation

class LiveActivityManager: ObservableObject {
    @Published var currentActivity: Activity<widgetAttributes>?
    private let locationManager: LocationManager
    private var timer: Timer?
    
    init(locationManager: LocationManager) {
        self.locationManager = locationManager
    }
    
    func startLiveActivity(for crossing: Crossing) {
        let attributes = widgetAttributes(crossingName: crossing.name)
        let contentState = widgetAttributes.ContentState(
            minutes: Int(crossing.estimatedDelay ?? 0),
            summary: "\(crossing.status.rawValue) - \(crossing.name)"
        )
        
        do {
            let activity = try Activity.request(
                attributes: attributes,
                contentState: contentState,
                pushType: nil
            )
            currentActivity = activity
            startLocationUpdates()
        } catch {
            print("Error starting live activity: \(error.localizedDescription)")
        }
    }
    
    func stopLiveActivity() {
        Task {
            await currentActivity?.end(dismissalPolicy: .immediate)
            currentActivity = nil
            stopLocationUpdates()
        }
    }
    
    private func startLocationUpdates() {
        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            Task { [weak self] in
                await self?.updateLiveActivity()
            }
        }
    }
    
    private func stopLocationUpdates() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateLiveActivity() async {
        guard let activity = currentActivity,
              let crossings = try? await CommuteAPI.fetchCrossings(),
              let nearestCrossing = locationManager.checkNearestCrossing(crossings: crossings.map { Crossing.fromDTO($0) }) else { return }
        
        let contentState = widgetAttributes.ContentState(
            minutes: Int(nearestCrossing.estimatedDelay ?? 0),
            summary: "\(nearestCrossing.status.rawValue) - \(nearestCrossing.name)"
        )
        
        await activity.update(using: contentState)
    }
} 
