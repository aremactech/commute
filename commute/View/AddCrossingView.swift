//
//  AddCrossingView.swift
//  commute
//
//  Created by Drew Goldstein on 4/20/25.
//

import SwiftUI
import MapKit

struct AddCrossingView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var mapPosition = MapCameraPosition.region(
        .init(center: .init(latitude: 26.1224, longitude: -80.1373),
              span: .init(latitudeDelta: 0.05, longitudeDelta: 0.05))
    )

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Map(position: $mapPosition)
                    .mapStyle(.standard(elevation: .flat))
                    .frame(height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                TextField("Crossing name", text: $name)
                    .textFieldStyle(.roundedBorder)

                Button("Add Crossing") {
                    let center = mapPosition.region?.center ?? .init()
                    CrossingStore.shared.add(name: name,
                                             lat: center.latitude,
                                             lon: center.longitude)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(name.isEmpty)
                Spacer()
            }
            .padding()
            .navigationTitle("New Crossing")
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Cancel", action: { dismiss() }) } }
        }
    }
}
