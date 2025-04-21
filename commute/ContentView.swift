//
//  ContentView.swift
//  commute
//
//  Created by Drew Goldstein on 4/8/25.
//

import SwiftUI
import SwiftData
import MapKit

// MARK: - Map Annotation
struct MapAnnotationItem: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let name: String
    let crossing: CommuteAPI.CrossingDTO
}

// MARK: - CrossingAnnotation
struct CrossingAnnotation: View {
    let crossing: CommuteAPI.CrossingDTO
    @State private var isSelected = false
    
    var body: some View {
        Button {
            isSelected.toggle()
        } label: {
            ZStack {
                Circle()
                    .fill(.white)
                    .frame(width: 40, height: 40)
                    .shadow(radius: 2)
                
                Image(systemName: iconName)
                    .font(.title2)
                    .foregroundStyle(iconColor)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(statusColor)
                            .frame(width: 32, height: 32)
                    )
                }
            }
            .buttonStyle(.plain)
            .sheet(isPresented: $isSelected) {
                NavigationStack {
                    CrossingDetailView(crossing: Crossing.fromDTO(crossing))
                }
            }
        }
        
        private var iconName: String {
            switch crossing.type {
            case .rail:
                return "tram.fill"
            case .drawBridge:
                return "ferry.fill"
            }
        }
        
        private var iconColor: Color {
            switch crossing.status {
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
        
        private var statusColor: Color {
            switch crossing.status {
            case .open:
                return .green.opacity(0.2)
            case .closed:
                return .red.opacity(0.2)
            case .warning:
                return .yellow.opacity(0.2)
            case .unknown:
                return .gray.opacity(0.2)
            }
        }
    }

// MARK: - StatusBanner
struct StatusBanner: View {
    let summary: String
    
    var body: some View {
        Text(summary)
            .font(.callout.bold())
            .padding(8)
            .background(.ultraThickMaterial, in: Capsule())
            .padding(.top, 8)
    }
}

// MARK: - Map Content
struct MapContent: View {
    let crossings: [CommuteAPI.CrossingDTO]
    @Binding var region: MKCoordinateRegion
    
    private var annotations: [MapAnnotationItem] {
        crossings.map { crossing in
            MapAnnotationItem(
                coordinate: CLLocationCoordinate2D(
                    latitude: crossing.location.latitude,
                    longitude: crossing.location.longitude
                ),
                name: crossing.name,
                crossing: crossing
            )
        }
    }
    
    var body: some View {
        Map(initialPosition: .region(region)) {
            ForEach(annotations) { item in
                Annotation(item.name, coordinate: item.coordinate) {
                    CrossingAnnotation(crossing: item.crossing)
                }
            }
        }
        .mapStyle(.standard)
    }
}

// MARK: - ContentView
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var crossings: [Crossing]
    @State private var selectedCrossing: Crossing?
    @State private var mapPosition = MapCameraPosition.region(
        .init(center: .init(latitude: 26.1224, longitude: -80.1373),
              span: .init(latitudeDelta: 0.1, longitudeDelta: 0.1))
    )
    @State private var showAddSheet = false
    @State private var showSettings = false
    @State private var showFilters = false
    @State private var selectedFilter: CommuteAPI.CrossingType? = nil
    @State private var showUserLocation = true
    @State private var mapStyle: MapStyle = .standard
    @State private var showTraffic = false
    @State private var showSatellite = false
    @State private var showAnnotations = true
    @State private var showStatusBar = true
    @State private var refreshInterval: Double = 30
    @State private var showNotifications = true
    @State private var showLiveActivities = true
    @State private var useMetricUnits = false
    @State private var apiStatus = "Loading..."
    @State private var lastUpdate = Date()
    @State private var isInitialized = false
    
    private let refreshIntervals: [Double] = [15, 30, 60, 120]
    
    var filteredCrossings: [Crossing] {
        if let filter = selectedFilter {
            return crossings.filter { $0.type == filter }
        }
        return crossings
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Map(position: $mapPosition) {
                    if showUserLocation {
                        UserAnnotation()
                    }
                    
                    if showAnnotations {
                        ForEach(filteredCrossings) { crossing in
                            Annotation(crossing.name, coordinate: crossing.coordinate) {
                                CrossingAnnotation(crossing: crossing.toDTO())
                            }
                        }
                    }
                }
                .mapStyle(mapStyle)
                .mapControls {
                    MapUserLocationButton()
                    MapCompass()
                    MapScaleView()
                }
                .safeAreaInset(edge: .bottom) {
                    if showStatusBar {
                        StatusBarView(crossings: filteredCrossings)
                            .padding()
                            .background(.ultraThinMaterial)
                    }
                }
                
                VStack(spacing: 0) {
                    HStack {
                        Button {
                            showFilters.toggle()
                        } label: {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .font(.title2)
                        }
                        
                        Spacer()
                        
                        Menu {
                            Button {
                                showUserLocation.toggle()
                            } label: {
                                Label(showUserLocation ? "Hide Location" : "Show Location",
                                      systemImage: showUserLocation ? "location.slash" : "location")
                            }
                            
                            Button {
                                showAnnotations.toggle()
                            } label: {
                                Label(showAnnotations ? "Hide Annotations" : "Show Annotations",
                                      systemImage: showAnnotations ? "mappin.slash" : "mappin")
                            }
                            
                            Button {
                                showStatusBar.toggle()
                            } label: {
                                Label(showStatusBar ? "Hide Status" : "Show Status",
                                      systemImage: showStatusBar ? "chart.bar.xaxis" : "chart.bar")
                            }
                            
                            Divider()
                            
                            Button {
                                mapStyle = .standard
                            } label: {
                                Label("Standard", systemImage: "map")
                            }
                            
                            Button {
                                mapStyle = .hybrid
                            } label: {
                                Label("Hybrid", systemImage: "map.fill")
                            }
                            
                            Button {
                                mapStyle = .imagery
                            } label: {
                                Label("Satellite", systemImage: "globe")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .font(.title2)
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    
                    if showFilters {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                FilterButton(title: "All", isSelected: selectedFilter == nil) {
                                    selectedFilter = nil
                                }
                                
                                FilterButton(title: "Rail", isSelected: selectedFilter == .rail) {
                                    selectedFilter = .rail
                                }
                                
                                FilterButton(title: "Draw Bridge", isSelected: selectedFilter == .drawBridge) {
                                    selectedFilter = .drawBridge
                                }
                            }
                            .padding()
                        }
                        .background(.ultraThinMaterial)
                    }
                }
            }
            .navigationTitle("Commute")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        Task {
                            await refreshData()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddCrossingView()
            }
            .sheet(isPresented: $showSettings) {
                NavigationStack {
                    SettingsView()
                }
                .presentationDetents([.large])
            }
            .task {
                if !isInitialized {
                    await initializeAPI()
                }
            }
            .onChange(of: refreshInterval) { _ in
                Task {
                    await refreshData()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("DismissSettings"))) { _ in
                showSettings = false
            }
        }
    }
    
    private func initializeAPI() async {
        print("🚀 Initializing API...")
        do {
            // Just try to fetch crossings to check if API is available
            let crossings = try await CommuteAPI.fetchCrossings()
            print("✅ API is online and returned \(crossings.count) crossings")
            isInitialized = true
            await refreshData()
        } catch {
            print("❌ Failed to initialize API: \(error.localizedDescription)")
        }
    }
    
    private func refreshData() async {
        guard isInitialized else {
            print("⚠️ API not initialized yet")
            return
        }
        
        do {
            let crossings = try await CommuteAPI.fetchCrossings()
            print("📥 Retrieved \(crossings.count) crossings from API")
            
            // Clear existing crossings
            try modelContext.delete(model: Crossing.self)
            
            // Insert new crossings
            for dto in crossings {
                let crossing = Crossing.fromDTO(dto)
                modelContext.insert(crossing)
            }
            
            try modelContext.save()
            print("✅ Successfully updated \(crossings.count) crossings in model context")
            lastUpdate = Date()
            apiStatus = "Online"
        } catch {
            print("❌ Error refreshing data: \(error.localizedDescription)")
            apiStatus = "Error: \(error.localizedDescription)"
        }
    }
}

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.accentColor : Color.clear)
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color.accentColor, lineWidth: 1)
                )
        }
    }
}

struct FeatureRow: View {
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

struct StatusBarView: View {
    let crossings: [Crossing]
    
    var body: some View {
        HStack {
            ForEach(CommuteAPI.CrossingStatus.allCases, id: \.self) { status in
                VStack {
                    Text("\(crossings.filter { $0.status == status }.count)")
                        .font(.headline)
                    Text(status.rawValue)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Crossing.self, inMemory: true)
} 
