//
//  widgetAttributes.swift
//  commute
//
//  Created by Drew Goldstein on 4/20/25.
//

import ActivityKit

struct widgetAttributes: ActivityAttributes {          // ⬅ lowercase ‘w’

    struct ContentState: Codable, Hashable {
        var minutes: Int
        var summary: String
    }

    var crossingName: String
}
