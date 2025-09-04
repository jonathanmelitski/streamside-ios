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
    @State var camera: MKCoordinateRegion? = nil
    @State var allowNewSearch: Bool = false
    @State var searching: Bool = false
    @State var locations: [Location]? = nil
    @State var alertText: String? = nil
    
    var body: some View {
        let presentAlert = Binding(get: {
            alertText != nil
        }, set: { newValue in
            if !newValue {
                alertText = nil
            }
        })
        
        ZStack {
            Map {
                ForEach(locations ?? [], id: \.id) { location in
                    Marker(coordinate: .init(latitude: location.location.latitude, longitude: location.location.longitude)) {
                        Text(location.name)
                    }
                }
            }
            .onMapCameraChange { ctx in
                camera = ctx.region
                allowNewSearch = true
            }
            
            if searching {
                ProgressView()
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 16)
                    }
            }
            
            if allowNewSearch {
                VStack {
                    Spacer()
                    Button {
                        self.vm.addFavoriteLocation("04250200")
                        self.allowNewSearch = false
                        
//                        self.searching = true
//                        if let camera {
//                            let north = camera.center.latitude + camera.span.latitudeDelta / 2
//                            let south = camera.center.latitude - camera.span.latitudeDelta / 2
//                            let east = camera.center.longitude + camera.span.longitudeDelta / 2
//                            let west = camera.center.longitude - camera.span.longitudeDelta / 2
//                            
//                            Task {
//                                if let data = try? await NetworkManager.shared.getUSGSLocations(in: .init(northernLat: north, southernLat: south, easternLong: east, westernLong: west)) {
//                                    withAnimation {
//                                        self.locations = Location.getArray(from: data)
//                                    }
//                                } else {
//                                    alertText = "Unable to fetch location data. Try a smaller area or check your connection."
//                                }
//                                self.searching = false
//                            }
      //                  }
                    } label: {
                        Text("Load Add Salmon")
                            .foregroundStyle(.black)
                            .padding()
                            .background {
                                RoundedRectangle(cornerRadius: 16)
                                    .foregroundStyle(.ultraThickMaterial)
                            }
                    }
                    .padding()
                }
            }
        }
        
        .alert(isPresented: presentAlert) {
            Alert(title: Text("Error"))
        }
        
//        Text("SearchView")
//            .onTapGesture {
//                vm.addFavoriteLocation("01420500")
//            }
//        Text("Rremove")
//            .onTapGesture {
//                vm.removeFavoriteLocation("01420500")
//            }
//        Text("Fetch")
//            .onTapGesture {
//                Task {
//                    let data = try? await NetworkManager.shared.getUSGSLocations(in: .init(northernLat: 42.227977, southernLat: 41.524483, easternLong: -74.189429, westernLong: -75.321021))
//                    let locs = Location.getArray(from: data!)
//                }
//            }
    }
}

#Preview {
    SearchView()
        .environmentObject(SharedViewModel.shared)
}
