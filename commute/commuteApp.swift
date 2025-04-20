//
//  commuteApp.swift
//  commute
//
//  Created by Drew Goldstein on 4/8/25.
//

import SwiftUI
import SwiftData

@main
struct CommuteApp: App {
    var body: some Scene {
        WindowGroup { ContentView() }
            .modelContainer(for: [Crossing.self])
    }
}
