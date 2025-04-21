//
//  SettingsView.swift
//  commute
//
//  Created by Drew Goldstein on 4/20/25.
//

import SwiftUI
import WidgetKit

struct SettingsView: View {
    // Display Settings
    @AppStorage("unitsMetric") private var useMetric = false
    @AppStorage("showSpeed") private var showSpeed = true
    @AppStorage("showETA") private var showETA = true
    @AppStorage("showProgress") private var showProgress = true
    @AppStorage("showTraffic") private var showTraffic = true
    @AppStorage("showSatellite") private var showSatellite = false
    @AppStorage("showUserLocation") private var showUserLocation = true
    
    // Update Settings
    @AppStorage("refreshInterval") private var refreshInterval = 30
    @AppStorage("updateBuffer") private var updateBuffer = 2
    @AppStorage("autoRefresh") private var autoRefresh = true
    @AppStorage("backgroundUpdates") private var backgroundUpdates = true
    
    // Notification Settings
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("notificationSound") private var notificationSound = "default"
    @AppStorage("notificationVibration") private var notificationVibration = true
    @AppStorage("notificationInterval") private var notificationInterval = 5
    @AppStorage("criticalAlerts") private var criticalAlerts = true
    @AppStorage("notificationPreview") private var notificationPreview = true
    
    // Widget Settings
    @AppStorage("widgetStyle") private var widgetStyle = "compact"
    @AppStorage("widgetShowIcon") private var widgetShowIcon = true
    @AppStorage("widgetShowTime") private var widgetShowTime = true
    @AppStorage("widgetShowSpeed") private var widgetShowSpeed = true
    @AppStorage("widgetShowETA") private var widgetShowETA = true
    @AppStorage("widgetShowStatus") private var widgetShowStatus = true
    
    private let refreshIntervals = [15, 30, 60, 120, 300]
    private let notificationIntervals = [1, 2, 5, 10, 15, 30]
    private let widgetStyles = ["compact", "expanded", "minimal"]
    private let notificationSounds = ["default", "bell", "chime", "alert"]
    
    var body: some View {
        Form {
            // Display Settings Section
            Section {
                Toggle("Show User Location", isOn: $showUserLocation)
                Toggle("Show Traffic", isOn: $showTraffic)
                Toggle("Show Satellite View", isOn: $showSatellite)
                Toggle("Use Metric Units", isOn: $useMetric)
                Toggle("Show Speed", isOn: $showSpeed)
                Toggle("Show ETA", isOn: $showETA)
                Toggle("Show Progress Bar", isOn: $showProgress)
            } header: {
                Text("Display")
            } footer: {
                Text("Customize how information is displayed on the map and in the app.")
            }
            
            // Update Settings Section
            Section {
                Toggle("Auto Refresh", isOn: $autoRefresh)
                
                if autoRefresh {
                    Picker("Refresh Interval", selection: $refreshInterval) {
                        ForEach(refreshIntervals, id: \.self) { interval in
                            Text("\(interval) seconds").tag(interval)
                        }
                    }
                    
                    Stepper("Update Buffer: \(updateBuffer) minutes", value: $updateBuffer, in: 1...10)
                    Toggle("Background Updates", isOn: $backgroundUpdates)
                }
            } header: {
                Text("Updates")
            } footer: {
                Text("Control how often the app checks for new crossing information. Background updates allow the app to stay current even when not in use.")
            }
            
            // Notification Settings Section
            Section {
                Toggle("Enable Notifications", isOn: $notificationsEnabled)
                
                if notificationsEnabled {
                    Toggle("Critical Alerts", isOn: $criticalAlerts)
                    Toggle("Show Preview", isOn: $notificationPreview)
                    
                    Picker("Sound", selection: $notificationSound) {
                        ForEach(notificationSounds, id: \.self) { sound in
                            Text(sound.capitalized).tag(sound)
                        }
                    }
                    
                    Toggle("Vibration", isOn: $notificationVibration)
                    
                    Picker("Check Interval", selection: $notificationInterval) {
                        ForEach(notificationIntervals, id: \.self) { interval in
                            Text("\(interval) minutes").tag(interval)
                        }
                    }
                }
            } header: {
                Text("Notifications")
            } footer: {
                Text("Configure how and when you receive notifications about crossing status changes. Critical alerts will notify you even when Do Not Disturb is enabled.")
            }
            
            // Widget Settings Section
            Section {
                Picker("Widget Style", selection: $widgetStyle) {
                    ForEach(widgetStyles, id: \.self) { style in
                        Text(style.capitalized).tag(style)
                    }
                }
                
                Toggle("Show Icon", isOn: $widgetShowIcon)
                Toggle("Show Time", isOn: $widgetShowTime)
                Toggle("Show Speed", isOn: $widgetShowSpeed)
                Toggle("Show ETA", isOn: $widgetShowETA)
                Toggle("Show Status", isOn: $widgetShowStatus)
            } header: {
                Text("Widget")
            } footer: {
                Text("Customize what information appears in your widgets. Different styles may show different amounts of information.")
            }
            
            // About Section
            Section {
                NavigationLink {
                    AboutView()
                } label: {
                    HStack {
                        Text("About")
                        Spacer()
                        Image(systemName: "info.circle")
                            .foregroundStyle(.secondary)
                    }
                }
            } footer: {
                Text("Learn more about the app and its features.")
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Done") {
                    // Dismiss the sheet
                    NotificationCenter.default.post(name: NSNotification.Name("DismissSettings"), object: nil)
                }
            }
        }
    }
}

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Commute")
                    .font(.largeTitle.bold())
                
                Text("This app predicts rail‑crossing and bridge delays, "
                     + "uses Live Activities for at‑a‑glance info, "
                     + "and stores your favourite crossings on‑device.")
                    .foregroundStyle(.secondary)
                
                Divider()
                
                Text("Features")
                    .font(.title3.bold())
                
                VStack(alignment: .leading, spacing: 8) {
                    AboutFeatureRow(icon: "map", title: "Interactive Map",
                             description: "View all crossings on a map with real-time status updates")
                    AboutFeatureRow(icon: "bell", title: "Notifications",
                             description: "Get notified when crossings change status")
                    AboutFeatureRow(icon: "chart.bar", title: "Status Overview",
                             description: "Quick view of all crossing statuses")
                    AboutFeatureRow(icon: "gearshape", title: "Customizable",
                             description: "Adjust settings to your preferences")
                }
                
                Divider()
                
                Text("Version 1.0.0")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AboutFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.tint)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
} 
