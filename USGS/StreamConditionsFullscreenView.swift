//
//  StreamConditionsFullscreenView.swift
//  USGS
//
//  Created by Jonathan Melitski on 5/29/25.
//

import SwiftUI
import USGSShared
import MapKit

struct StreamConditionsFullscreenView: View {
    @State var location: Location
    
    static let mainDimension: CGFloat = 140
    @State var cameraPosition: MapCameraPosition
    @ObservedObject var vm = SharedViewModel.shared
    
    init(location: Location) {
        self.location = location
        self.cameraPosition = .camera(.init(centerCoordinate: CLLocationCoordinate2D(latitude: location.location.latitude, longitude: location.location.longitude), distance: 5000))
    }
    
    var body: some View {
        // Two-way body with divider. ultra thick
        ZStack {
            Map(position: $cameraPosition)
                .ignoresSafeArea()
                .disabled(true)
                .blur(radius: 6)
            ScrollView {
                StreamConditionsDetailViewStack(location: $location)
            }
        }
        .onChange(of: location) {
            if let locIdx = SharedViewModel.shared.currentProfile?.gauges.firstIndex(where: { $0.id == location.id }) {
                SharedViewModel.shared.currentProfile?.gauges[locIdx] = location
            }
            // potentially invalidate widget?
        }
        .toolbar {
//            ToolbarItem(placement: .primaryAction) {
//                Button {
//                    withAnimation {
//                        SharedViewModel.shared.selectedTab = .maps(location: CLLocationCoordinate2D(latitude: location.location.latitude, longitude: location.location.longitude))
//                        
//                    }
//                } label: {
//                    Image(systemName: "map")
//                }
//            }
            
            ToolbarItem(placement: .primaryAction) {
                Button {
                    if vm.currentProfile?.gauges.contains(where: { $0.id == location.id }) ?? false {
                        vm.removeFavoriteLocation(location.id)
                    } else {
                        vm.addFavoriteLocation(location)
                    }
                    
                } label: {
                    Image(systemName: (vm.currentProfile?.gauges.contains(where: { $0.id == location.id }) ?? false) ? "star.fill" : "star")
                        .foregroundStyle(.yellow)
                }
            }
        }
        
    }
}

struct StreamConditionsDetailViewStack: View {
    @Binding var location: Location
    @State var editingWidget: Bool = false
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            HStack {
                Spacer()
                VStack(alignment: .center) {
                    Group {
                        if let (river, location, state) = location.tupledName {
                            Text(river)
                                .font(.largeTitle)
                                .bold()
                            if let state {
                                Text("\(location), \(state)")
                                    .font(.headline)
                            } else {
                                Text("\(location)")
                                    .font(.headline)
                            }
                        }
                    }
                    .multilineTextAlignment(.center)
                }
                .padding()
                Spacer()
            }
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .foregroundStyle(.thickMaterial)
            }
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .foregroundStyle(.thickMaterial)
                VStack(spacing: 0) {
                    Rectangle()
                        .foregroundStyle(Color.clear)
                        .frame(height: 150)
                    if editingWidget {
                        WidgetSettingsView(location: $location)
                            .padding()
                            .transition(.asymmetric(insertion: .push(from: .top), removal: .push(from: .bottom)))
                        Spacer()
                    }
                }
                VStack {
                    Button {
                        withAnimation {
                            self.editingWidget.toggle()
                        }
                    } label: {
                        MediumWidgetView(data: location)
                            .padding()
                            .background {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(LinearGradient(colors: [Color("TopGradient"), Color("BottomGradient")], startPoint: .top, endPoint: .bottom))
                            }
                            .overlay {
                                VStack {
                                    Spacer()
                                    Text("(tap to edit widget)")
                                        .font(.caption)
                                        .italic()
                                        .foregroundStyle(Color("GraphAxisForeground"))
                                }
                            }
                    }
                    .buttonStyle(.plain)
                    .frame(height: 150)
                    
                    if editingWidget {
                        Spacer()
                    }
                }
                .shadow(radius: 4)
            }
            
            Spacer()
        }
        .padding(.horizontal)
    }
}



#Preview {
    NavigationView {
        StreamConditionsFullscreenView(location: Location.sampleData)
    }
}


