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
    public var crossingTypeRaw: String
    public var statusRaw: String
    public var lastUpdated: Date
    public var estimatedDelay: Double?
    public var nextUpdate: Date?
    
    public init(name: String, lat: Double, lon: Double, crossingType: CommuteAPI.CrossingType = .rail, status: CommuteAPI.CrossingStatus = .unknown) {
        self.name = name
        self.lat = lat
        self.lon = lon
        self.crossingTypeRaw = crossingType.rawValue
        self.statusRaw = status.rawValue
        self.lastUpdated = Date()
    }
    
    public var coordinate: CLLocationCoordinate2D {
        .init(latitude: lat, longitude: lon)
    }
    
    public var location: CLLocation {
        .init(latitude: lat, longitude: lon)
    }
    
    public var type: CommuteAPI.CrossingType {
        get { CommuteAPI.CrossingType(rawValue: crossingTypeRaw) ?? .rail }
        set { crossingTypeRaw = newValue.rawValue }
    }
    
    public var status: CommuteAPI.CrossingStatus {
        get { CommuteAPI.CrossingStatus(rawValue: statusRaw) ?? .unknown }
        set { statusRaw = newValue.rawValue }
    }
    
    public func toDTO() -> CommuteAPI.CrossingDTO {
        CommuteAPI.CrossingDTO(
            id: id.uuidString,
            name: name,
            type: type,
            status: status,
            lastUpdated: lastUpdated,
            location: .init(latitude: lat, longitude: lon),
            estimatedDelay: estimatedDelay,
            nextUpdate: nextUpdate
        )
    }
    
    public static func fromDTO(_ dto: CommuteAPI.CrossingDTO) -> Crossing {
        let crossing = Crossing(
            name: dto.name,
            lat: dto.location.latitude,
            lon: dto.location.longitude,
            crossingType: dto.type,
            status: dto.status
        )
        crossing.lastUpdated = dto.lastUpdated
        crossing.estimatedDelay = dto.estimatedDelay
        crossing.nextUpdate = dto.nextUpdate
        return crossing
    }
} 
