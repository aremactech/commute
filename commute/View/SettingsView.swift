//
//  SettingsView.swift
//  commute
//
//  Created by Drew Goldstein on 4/20/25.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("unitsMetric") private var useMetric = false

    var body: some View {
        Form {
            Toggle("Use metric units (km)", isOn: $useMetric)
            NavigationLink("About") { AboutView() }
        }
        .navigationTitle("Settings")
    }
}

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Commute").font(.largeTitle.bold())
                Text("This app predicts rail‑crossing and bridge delays, "
                     + "uses Live Activities for at‑a‑glance info, "
                     + "and stores your favourite crossings on‑device.")
            }
            .padding()
        }
        .navigationTitle("About")
    }
}
