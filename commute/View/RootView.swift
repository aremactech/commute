//
//  RootView.swift
//  commute
//
//  Created by Drew Goldstein on 4/20/25.
//

import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem { Label("Dashboard", systemImage: "gauge.medium") }

            CrossingsListView()
                .tabItem { Label("Crossings", systemImage: "list.bullet") }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
    }
}
