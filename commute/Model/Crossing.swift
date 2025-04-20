//
//  Crossing.swift
//  commute
//
//  Created by Drew Goldstein on 4/20/25.
//

import Foundation
import SwiftData
import CoreLocation

@Model public final class Crossing: Identifiable {
    public var id = UUID()
    public var name: String
    public var lat: Double
    public var lon: Double
    public var lastStatus = "Unknown"

    public init(name: String, lat: Double, lon: Double) {
        self.name = name
        self.lat  = lat
        self.lon  = lon
    }

    public var coordinate: CLLocationCoordinate2D {
        .init(latitude: lat, longitude: lon)
    }
    public var location: CLLocation {
        .init(latitude: lat, longitude: lon)
    }
}
