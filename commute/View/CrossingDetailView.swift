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

    var body: some View {
        VStack(spacing: 12) {
            Map(position: .constant(.region(
                .init(center: crossing.coordinate, span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01)))))
                .mapControls { MapUserLocationButton() }
                .frame(height: 250)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            HStack {
                Image(systemName: "location")
                Text("\(crossing.coordinate.latitude, specifier: "%.5f"), \(crossing.coordinate.longitude, specifier: "%.5f")")
            }
            .font(.footnote)

            Text("Last status:")
                .font(.subheadline.bold())
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(crossing.lastStatus)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()
        }
        .padding()
        .navigationTitle(crossing.name)
    }
}
