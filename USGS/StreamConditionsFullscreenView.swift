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
    }
}

struct StreamConditionsDetailViewStack: View {
    @Binding var location: Location
    @State var editingWidget: Bool = false
    
    @ObservedObject var vm = SharedViewModel.shared
    
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
            
            
            HStack(spacing: 16) {
                DetailViewActionButton(systemName: "widget.small", text: "Edit Widget") {
                    withAnimation {
                        editingWidget = true
                    }
                }
                DetailViewActionButton(
                    systemName: (vm.currentProfile?.gauges.contains(where: { $0.id == location.id }) ?? false) ? "star.fill" : "star",
                    text: (vm.currentProfile?.gauges.contains(where: { $0.id == location.id }) ?? false) ? "Remove Favorite" : "Add Favorite") {
                        if vm.currentProfile?.gauges.contains(where: { $0.id == location.id }) ?? false {
                            vm.removeFavoriteLocation(location.id)
                        } else {
                            vm.addFavoriteLocation(location)
                        }
                }
                DetailViewActionButton(systemName: "info.circle.text.page", text: "Edit This Page") {
                    
                }
                
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .sheet(isPresented: $editingWidget) {
            VStack {
                TabView {
                    VStack {
                        MediumWidgetView(data: location)
                            .padding()
                            .background {
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(LinearGradient(colors: [location.settings.widgetSettings.topColor.toSwiftUIColor, location.settings.widgetSettings.bottomColor.toSwiftUIColor], startPoint: .top, endPoint: .bottom))
                            }
                            .frame(height: 150)
                            .shadow(radius: 8)
                        Spacer()
                    }
                    
                    VStack {
                        SmallWidgetView(data: location)
                            .padding()
                            .background {
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(LinearGradient(colors: [location.settings.widgetSettings.topColor.toSwiftUIColor, location.settings.widgetSettings.bottomColor.toSwiftUIColor], startPoint: .top, endPoint: .bottom))
                            }
                            .frame(width: 150, height: 150)
                            .shadow(radius: 8)
                        Spacer()
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                .frame(height: 175)
                
                ScrollView {
                    WidgetSettingsView(location: $location)
                }
            }
            .padding()
            .overlay {
                VStack {
                    HStack {
                        Spacer()
                        Group {
                            if #available(iOS 26, *) {
                                Button {
                                    withAnimation {
                                        editingWidget = false
                                    }
                                } label: {
                                    Text("Done")
                                        .padding(4)
                                }
                                .buttonStyle(.glassProminent)
                            } else {
                                Button {
                                    withAnimation {
                                        editingWidget = false
                                    }
                                } label: {
                                    Text("Done")
                                        .padding(4)
                                }
                                .buttonStyle(.borderedProminent)
                            }
                        }
                        .font(.headline)
                        .padding(16)
                    }
                    Spacer()
                }
            }
            
            
        }
    }
}

struct DetailViewActionButton: View {
    let systemName: String
    let text: String
    let action: () -> ()
    
    var body: some View {
        Button {
            action()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .foregroundStyle(.thickMaterial)
                HStack(alignment: .center, spacing: 8) {
                    Image(systemName: systemName)
                    Text(text)
                }
                .padding(8)
            }
            
            
        }
    }
}



#Preview {
    NavigationView {
        StreamConditionsFullscreenView(location: Location.sampleData)
    }
}


