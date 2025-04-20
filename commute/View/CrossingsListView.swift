//
//  CrossingsListView.swift
//  commute
//
//  Created by Drew Goldstein on 4/20/25.
//

import SwiftUI

struct CrossingsListView: View {
    @StateObject private var store = CrossingStore.shared
    @State private var showAdd = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.crossings) { c in
                    NavigationLink {
                        CrossingDetailView(crossing: c)
                    } label: {
                        CrossingRow(crossing: c)
                    }
                }
                .onDelete { store.delete($0) }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Crossings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showAdd.toggle() } label: { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $showAdd) { AddCrossingView() }
        }
    }
}

struct CrossingRow: View {
    let crossing: Crossing
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(crossing.name).font(.headline)
            Text(crossing.lastStatus).font(.caption).foregroundStyle(.secondary)
        }
    }
}
