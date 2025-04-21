//
//  CommuteAPI.swift
//  commute
//
//  Created by Drew Goldstein on 4/20/25.
//

import Foundation

public enum CommuteAPI {
    // MARK: - Configuration
    #if DEBUG
    // Try multiple development URLs in order
    private static let devURLs = [
        "http://localhost:1337/api",
        "http://192.168.1.84:1337/api",
        "http://127.0.0.1:1337/api"
    ]
    private static var currentDevURL: URL?
    private static var baseURL: URL {
        get async {
            if let current = currentDevURL {
                return current
            }
            // Try to find a working dev server
            for urlString in devURLs {
                if let url = URL(string: urlString),
                   await isServerReachable(url) {
                    currentDevURL = url
                    print("✅ Found working dev server at: \(url.absoluteString)")
                    return url
                }
            }
            // Fall back to production if no dev server found
            print("⚠️ No dev server found, falling back to production")
            return URL(string: "https://api.commute.aremac.tech")!
        }
    }
    #else
    private static let baseURL = URL(string: "https://api.commute.aremac.tech")!
    #endif
    
    // MARK: - Development Server Check
    #if DEBUG
    private static func isServerReachable(_ url: URL) async -> Bool {
        do {
            let statusURL = url.appendingPathComponent("status")
            var request = URLRequest(url: statusURL)
            request.timeoutInterval = 2 // Short timeout for quick check
            
            let (_, response) = try await URLSession.shared.data(for: request)
            return (response as? HTTPURLResponse)?.statusCode == 200
        } catch {
            return false
        }
    }
    #endif
    
    // MARK: - Enums
    public enum CrossingType: String, Decodable, Equatable, CaseIterable {
        case rail = "RAIL"
        case drawBridge = "DRAW_BRIDGE"
    }
    
    public enum CrossingStatus: String, Decodable, Equatable, CaseIterable {
        case open = "OPEN"
        case closed = "CLOSED"
        case warning = "WARNING"
        case unknown = "UNKNOWN"
    }
    
    // MARK: - Models
    public struct CrossingDTO: Decodable, Equatable {
        public let id: String
        public let name: String
        public let type: CrossingType
        public let status: CrossingStatus
        public let lastUpdated: Date
        public let location: Location
        public let estimatedDelay: Double?
        public let nextUpdate: Date?
        
        public struct Location: Decodable, Equatable {
            public let latitude: Double
            public let longitude: Double
            
            public init(latitude: Double, longitude: Double) {
                self.latitude = latitude
                self.longitude = longitude
            }
        }
        
        public init(id: String, name: String, type: CrossingType, status: CrossingStatus, lastUpdated: Date, location: Location, estimatedDelay: Double? = nil, nextUpdate: Date? = nil) {
            self.id = id
            self.name = name
            self.type = type
            self.status = status
            self.lastUpdated = lastUpdated
            self.location = location
            self.estimatedDelay = estimatedDelay
            self.nextUpdate = nextUpdate
        }
        
        enum CodingKeys: String, CodingKey {
            case id
            case name
            case type
            case status
            case lastUpdated
            case location
            case estimatedDelay
            case nextUpdate
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(String.self, forKey: .id)
            name = try container.decode(String.self, forKey: .name)
            type = try container.decode(CrossingType.self, forKey: .type)
            status = try container.decode(CrossingStatus.self, forKey: .status)
            
            // Handle date decoding with custom formatter
            let dateFormatter = ISO8601DateFormatter()
            dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            
            let lastUpdatedString = try container.decode(String.self, forKey: .lastUpdated)
            if let date = dateFormatter.date(from: lastUpdatedString) {
                lastUpdated = date
            } else {
                throw DecodingError.dataCorruptedError(forKey: .lastUpdated, in: container, debugDescription: "Date string does not match format expected by formatter.")
            }
            
            location = try container.decode(Location.self, forKey: .location)
            estimatedDelay = try container.decodeIfPresent(Double.self, forKey: .estimatedDelay)
            
            if let nextUpdateString = try container.decodeIfPresent(String.self, forKey: .nextUpdate) {
                if let date = dateFormatter.date(from: nextUpdateString) {
                    nextUpdate = date
                } else {
                    throw DecodingError.dataCorruptedError(forKey: .nextUpdate, in: container, debugDescription: "Date string does not match format expected by formatter.")
                }
            } else {
                nextUpdate = nil
            }
        }
    }
    
    public struct APIError: Error, Decodable {
        public let error: String
        public let message: String
    }
    
    // MARK: - Fetcher
    public static func fetchCrossings() async throws -> [CrossingDTO] {
        #if DEBUG
        let url = (await baseURL).appendingPathComponent("crossings")
        print("🌐 Fetching crossings from: \(url.absoluteString)")
        #else
        let url = baseURL.appendingPathComponent("crossings")
        #endif
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return try await performRequest(request)
    }
    
    // MARK: - Private Helpers
    private static func performRequest(_ request: URLRequest) async throws -> [CrossingDTO] {
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
        let lastUpdated: String
        
        enum CodingKeys: String, CodingKey {
            case crossings
            case lastUpdated
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            crossings = try container.decode([CrossingDTO].self, forKey: .crossings)
            lastUpdated = try container.decode(String.self, forKey: .lastUpdated)
        }
    }
}

// MARK: - Helper
fileprivate extension JSONDecoder {
    static var iso8601: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            // Try multiple date formatters
            let formatters: [DateFormatter] = [
                {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                    formatter.locale = Locale(identifier: "en_US_POSIX")
                    formatter.timeZone = TimeZone(secondsFromGMT: 0)
                    return formatter
                }(),
                {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                    formatter.locale = Locale(identifier: "en_US_POSIX")
                    formatter.timeZone = TimeZone(secondsFromGMT: 0)
                    return formatter
                }()
            ]
            
            // Try ISO8601DateFormatter first
            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = isoFormatter.date(from: dateString) {
                return date
            }
            
            // Try other formatters
            for formatter in formatters {
                if let date = formatter.date(from: dateString) {
                    return date
                }
            }
            
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateString)")
        }
        return decoder
    }
} 
