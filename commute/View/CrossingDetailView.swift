//
//  CrossingDetailView.swift
//  commute
//
//  Created by Drew Goldstein on 4/20/25.
//

import SwiftUI
import MapKit

struct CrossingDetailView: View {
    let crossing: Crossing
    @State private var showDirections = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Map Section
                Map(position: .constant(.region(
                    .init(center: crossing.coordinate, span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01)))))
                    .mapControls { MapUserLocationButton() }
                    .frame(height: 250)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(alignment: .bottomTrailing) {
                        Button {
                            showDirections = true
                        } label: {
                            Image(systemName: "arrow.triangle.turn.up.right.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.white)
                                .padding(8)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                        .padding(8)
                    }
                
                // Status Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Status")
                        .font(.headline)
                    
                    HStack {
                        StatusBadge(status: crossing.status)
                        Spacer()
                        if let delay = crossing.estimatedDelay {
                            Text("\(Int(delay)) min delay")
                                .font(.subheadline.bold())
                                .foregroundStyle(delay > 5 ? .red : .green)
                        }
                    }
                    
                    Text("Last Updated: \(crossing.lastUpdated.formatted(date: .omitted, time: .shortened))")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Location Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Location")
                        .font(.headline)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Coordinates")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text("\(crossing.coordinate.latitude, specifier: "%.6f"), \(crossing.coordinate.longitude, specifier: "%.6f")")
                                .font(.subheadline)
                        }
                        
                        Spacer()
                        
                        Button {
                            let url = URL(string: "maps://?q=\(crossing.coordinate.latitude),\(crossing.coordinate.longitude)")!
                            UIApplication.shared.open(url)
                        } label: {
                            Image(systemName: "map")
                                .font(.title2)
                        }
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // History Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Recent Status")
                        .font(.headline)
                    
                    Text(crossing.lastStatus)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding()
        }
        .navigationTitle(crossing.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showDirections) {
            NavigationStack {
                DirectionsView(crossing: crossing)
            }
        }
    }
}

struct StatusBadge: View {
    let status: CommuteAPI.CrossingStatus
    
    var body: some View {
        Text(status.rawValue)
            .font(.subheadline.bold())
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(statusColor)
            .foregroundStyle(.white)
            .clipShape(Capsule())
    }
    
    private var statusColor: Color {
        switch status {
        case .open:
            return .green
        case .closed:
            return .red
        case .warning:
            return .yellow
        case .unknown:
            return .gray
        }
    }
}

struct DirectionsView: View {
    let crossing: Crossing
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List {
            Section {
                Button {
                    let url = URL(string: "maps://?saddr=&daddr=\(crossing.coordinate.latitude),\(crossing.coordinate.longitude)")!
                    UIApplication.shared.open(url)
                } label: {
                    Label("Get Directions", systemImage: "arrow.triangle.turn.up.right.circle")
                }
            } footer: {
                Text("This will open Apple Maps with directions to the crossing.")
            }
        }
        .navigationTitle("Directions")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        CrossingDetailView(crossing: Crossing(
            name: "Sample Crossing",
            lat: 26.1224,
            lon: -80.1373,
            crossingType: .rail,
            status: .open
        ))
    }
} 
