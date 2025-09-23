//
//  SearchView.swift
//  USGS
//
//  Created by Jonathan Melitski on 5/27/25.
//

import SwiftUI
import USGSShared
import MapKit
import DotLottie

struct SearchView: View {
    @EnvironmentObject var vm: SharedViewModel
    @State var locationsToShow: [BasicLocation] = []
    @State var selectedLocation: BasicLocation? = nil
    @State var selectedLocationData: Location? = nil
    @State var showTextSearchSheet: Bool = false
    @State var mapCameraPosition: MapCameraPosition = .automatic
    var body: some View {
        ZStack {
            Map(position: $mapCameraPosition, selection: $selectedLocation) {
                ForEach(locationsToShow) { loc in
                    Marker(coordinate: CLLocationCoordinate2D(latitude: loc.geo.latitude, longitude: loc.geo.longitude), label: { Text(loc.name.uppercased()) })
                        .tag(loc)
                }
            }
            .onMapCameraChange(frequency: .continuous) { ctx in
                guard ctx.camera.distance < 200000 else { return }
                filter(ctx)
            }
            .onMapCameraChange(frequency: .onEnd) { ctx in
                guard ctx.camera.distance > 200000 else { return }
                guard ctx.camera.distance < 1000000 else {
                    withAnimation {
                        self.locationsToShow = []
                    }
                    return
                }
                filter(ctx)
            }
            VStack {
                Spacer()
                if let selectedLocationData {
                    MediumWidgetView(data: selectedLocationData)
                        .frame(height: 150)
                        .background {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(LinearGradient(colors: [Color("TopGradient"), Color("BottomGradient")], startPoint: .top, endPoint: .bottom))
                        }
                        .overlay {
                            HStack {
                                Spacer()
                                VStack {
                                    Button {
                                        if vm.favoriteLocations.contains(where: { $0 == selectedLocation?.id }) {
                                            vm.removeFavoriteLocation(selectedLocation!.id)
                                        } else {
                                            vm.addFavoriteLocation(selectedLocation!.id)
                                        }
                                        
                                    } label: {
                                        Image(systemName: vm.favoriteLocations.contains(where: { $0 == selectedLocation?.id }) ? "star.fill" : "star")
                                            .foregroundStyle(.yellow)
                                            .font(.title)
                                    }
                                    .padding()
                                    
                                    Spacer()
                                }
                            }
                        }
                        .padding()
                        .shadow(radius: 8)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .onChange(of: selectedLocation) {
            self.showTextSearchSheet = false
            guard let loc = selectedLocation else {
                withAnimation(.easeOut(duration: 0.2)) {
                    selectedLocationData = nil
                }
                return
            }
            
            Task {
                let data = try? await vm.fetchLocationData(loc.id)
                withAnimation(.easeOut(duration: 0.2)) {
                    selectedLocationData = data
                    self.mapCameraPosition = .camera(.init(centerCoordinate: .init(latitude: loc.geo.latitude, longitude: loc.geo.longitude), distance: 10000))
                }
            }
            
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    withAnimation {
                        self.showTextSearchSheet = true
                    }
                } label: {
                    Image(systemName: "magnifyingglass")
                }
            }
        }
        .sheet(isPresented: $showTextSearchSheet) {
            LocationSearchSheetView(selectedLocation: $selectedLocation)
                .padding()
        }
    }
    
    func filter(_ ctx: MapCameraUpdateContext) {
        let minLat = ctx.region.center.latitude - ctx.region.span.latitudeDelta / 2
        let maxLat = ctx.region.center.latitude + ctx.region.span.latitudeDelta / 2
        let minLong = ctx.region.center.longitude - ctx.region.span.longitudeDelta / 2
        let maxLong = ctx.region.center.longitude + ctx.region.span.longitudeDelta / 2
        
        withAnimation {
            self.locationsToShow = vm.allLocations.filter { el in
                let lat = el.geo.latitude
                let long = el.geo.longitude
                
                return lat >= minLat && lat <= maxLat && long >= minLong && long <= maxLong
            }
        }
    }
}

struct LocationSearchSheetView: View {
    @Binding var selectedLocation: BasicLocation?
    @ObservedObject var vm = SharedViewModel.shared
    
    @State var query: String = ""
    
    var body: some View {
        VStack {
            TextField("Search", text: $query, prompt: Text("Search Locations").font(.title2))
            Divider()
            List(vm.allLocations.sorted(by: {
                if $0.state == $1.state {
                    return $0.name < $1.name
                } else {
                    return $0.state < $1.state
                }
            }).filter({ query != "" ? $0.name.lowercased().contains(query.lowercased()) : true }), id: \.self) { location in
                Button(action: {
                    self.selectedLocation = location
                }) {
                    Text(location.name)
                }
                .buttonStyle(.plain)
                .textCase(.uppercase)
            }
            .listStyle(.plain)
        }
    }
}

#Preview {
    NavigationStack {
        SearchView()
            .environmentObject(SharedViewModel.shared)
    }
}
