//
//  CommuteAPI.swift
//  commute
//
//  Created by Drew Goldstein on 4/20/25.
//

import Foundation

enum CommuteAPI {
    // MARK: - Configuration
    private static let baseURL = URL(string: "https://api.commute.aremac.tech")!
    
    // MARK: - Enums
    enum CrossingType: String, Decodable {
        case rail = "RAIL"
        case drawBridge = "DRAW_BRIDGE"
    }
    
    enum CrossingStatus: String, Decodable {
        case open = "OPEN"
        case closed = "CLOSED"
        case warning = "WARNING"
        case unknown = "UNKNOWN"
    }
    
    // MARK: - Models
    struct CrossingDTO: Decodable {
        let id: String
        let name: String
        let type: CrossingType
        let status: CrossingStatus
        let lastUpdated: Date
        let location: Location
        let estimatedDelay: Double?
        let nextUpdate: Date?
        
        struct Location: Decodable {
            let latitude: Double
            let longitude: Double
        }
    }
    
    struct APIError: Error, Decodable {
        let error: String
        let message: String
    }
    
    // MARK: - Fetcher
    static func fetchCrossings() async throws -> [CrossingDTO] {
        let url = baseURL.appendingPathComponent("crossings")
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        // Handle rate limiting
        if httpResponse.statusCode == 429 {
            let retryAfter = httpResponse.value(forHTTPHeaderField: "Retry-After")
            throw APIError(error: "rate_limit_exceeded",
                          message: "Rate limit exceeded. Please try again later.\(retryAfter.map { " Retry after \($0) seconds." } ?? "")")
        }
        
        // Handle other errors
        guard httpResponse.statusCode == 200 else {
            if let error = try? JSONDecoder.iso8601.decode(APIError.self, from: data) {
                throw error
            }
            throw URLError(.badServerResponse)
        }
        
        let envelope = try JSONDecoder.iso8601.decode(CrossingsEnvelope.self, from: data)
        return envelope.crossings
    }
    
    // MARK: - Private envelope
    private struct CrossingsEnvelope: Decodable {
        let crossings: [CrossingDTO]
        let lastUpdated: Date
    }
}

// MARK: - Helper
fileprivate extension JSONDecoder {
    static var iso8601: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
