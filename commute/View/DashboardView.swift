//
//  DashboardView.swift
//  commute
//
//  Created by Drew Goldstein on 4/20/25.
//

import SwiftUI

struct DashboardView: View {
    @StateObject private var watcher = CrossingWatcher.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Live Status")
                .font(.title2.bold())


            Spacer()
        }
        .padding()
        .navigationTitle("Commute")
    }
}
