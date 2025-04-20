//
//  StartCommuteIntent.swift
//  commute
//
//  Created by Drew Goldstein on 4/20/25.
//

import AppIntents

struct StartCommuteIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Start Commute"
    static var description = IntentDescription("Begin the commute Live Activity")

    func perform() async throws -> some IntentResult {
        try await widgetController.startNow()
        return .result()
    }
}
