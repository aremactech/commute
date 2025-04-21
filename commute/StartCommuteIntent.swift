//
//  StartCommuteIntent.swift
//  commute
//
//  Created by Drew Goldstein on 4/20/25.
//

import AppIntents
import CoreLocation

// MARK: - Intent Error
enum IntentError: Error {
    case unsupported
}

// MARK: - Intent Value Conformance
extension Crossing: _IntentValue {
    public typealias ValueType = String
    public typealias UnwrappedType = String
    
    public struct Specification: ResolverSpecification {
        public typealias ResolvedValue = Crossing
        public typealias InputValue = String
        public typealias Output = Crossing
        public typealias Element = any Resolver
        public typealias Iterator = Array<any Resolver>.Iterator
        
        public func makeIterator() -> Iterator {
            [].makeIterator()
        }
        
        public static func resolve(_ value: String) async throws -> Crossing {
            // TODO: Implement proper resolution
            throw IntentError.unsupported
        }
        
        public static func resolve(_ value: String) async throws -> [Crossing] {
            // TODO: Implement proper resolution
            throw IntentError.unsupported
        }
    }
    
    public static var defaultResolverSpecification: Specification {
        Specification()
    }
    
    public static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "Crossing")
    }
    
    public var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: LocalizedStringResource(stringLiteral: name))
    }
    
    public var intentValue: String {
        name
    }
    
    public static func resolve(_ value: String) async throws -> Crossing {
        try await Specification.resolve(value)
    }
}

// MARK: - Start Commute Intent
struct StartCommuteIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Start Commute"
    static var description = IntentDescription("Begin the commute Live Activity")

    func perform() async throws -> some IntentResult {
        try await widgetController.startNow()
        return .result()
    }
}

// MARK: - Options Provider
struct CrossingOptionsProvider: DynamicOptionsProvider {
    func results() async throws -> [Crossing] {
        // TODO: Implement actual crossing fetching
        return []
    }
}

