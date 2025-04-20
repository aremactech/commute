//
//  ContentView.swift
//  commute
//
//  Created by Drew Goldstein on 4/8/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var ctx
    @Query private var crossings: [Crossing]
    @State private var newName = ""

    @StateObject private var watcher = CrossingWatcher.shared

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text(watcher.statusText)
                    .font(.headline)
                    .padding()

                List {
                    ForEach(crossings) { c in
                        HStack {
                            Text(c.name)
                            Spacer()
                            Text(c.lastStatus).font(.caption)
                        }
                    }
                    .onDelete { idx in
                        idx.forEach { ctx.delete(crossings[$0]) }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)

                HStack {
                    TextField("Add crossing name…", text: $newName)
                    Button {
                        addDemoCrossing()
                    } label: {
                        Label("Add", systemImage: "plus.circle.fill")
                            .labelStyle(.titleAndIcon)
                    }
                    .disabled(newName.isEmpty)
                }
                .textFieldStyle(.roundedBorder)
                .padding()
            }
            .navigationTitle("Commute")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { EditButton() }
        }
    }

    private func addDemoCrossing() {
        withAnimation {
            let demo = Crossing(name: newName, lat: 26.1224, lon: -80.1373) // Fort Laud example
            ctx.insert(demo)
            newName = ""
        }
    }
}
