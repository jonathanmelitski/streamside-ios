//
//  UserPersonalMapView.swift
//  USGS
//
//  Created by Jonathan Melitski on 9/27/25.
//

import SwiftUI
import USGSShared
import MapKit

struct UserPersonalMapView: View {
    @ObservedObject var vm = SharedViewModel.shared
    @State var highlightedLocation: CLLocationCoordinate2D?
    @State var selectedCoordinate: UserSavedCoordinate?
    @State var detent: PresentationDetent = .medium
    @State var showSettings: Bool = false
    @AppStorage("annotationSize") var annotationSize: Int = 24
    @AppStorage("labelsOn") var showLabels: Bool = true
    @AppStorage("showFavoritedGauges") var showGauges: Bool = true
    
    var body: some View {
        MapReader { reader in
            Map {
                ForEach(vm.userSavedCoordinates) { coord in
                    Annotation("", coordinate: coord.location) {
                        VStack {
                            Circle()
                                .fill(LinearGradient(colors: [
                                    coord.color.toSwiftUIColor.mix(with: .white, by: 0.3),
                                    coord.color.toSwiftUIColor
                                ], startPoint: .top, endPoint: .bottom))
                                .frame(width: CGFloat(annotationSize))
                                .overlay {
                                    Image(systemName: coord.iconString)
                                        .font(.caption)
                                        .foregroundStyle(.white)
                                }
                                .shadow(radius: 4)
                            if showLabels {
                                Text(coord.name)
                                    .font(.caption)
                                    .multilineTextAlignment(.center)
                                    .bold()
                                    .shadow(color: Color(UIColor.systemBackground), radius: 4)
                            }
                        }
                        .padding()
                        .onTapGesture {
                            withAnimation {
                                self.selectedCoordinate = coord
                            }
                        }
                    }
                    .annotationTitles(.hidden)
                }
                if showGauges {
                    ForEach(vm.locationData.values.sorted(by: { $0.name < $1.name })) { loc in
                        Marker(coordinate: CLLocationCoordinate2D(latitude: loc.location.latitude, longitude: loc.location.longitude), label: { Text(loc.name.uppercased()) })
                            .tag(loc)
                    }
                }
                if let highlightedLocation {
                    Annotation("", coordinate: highlightedLocation) {
                        VStack {
                            Image(systemName: "fish")
                                .font(.caption)
                                .foregroundStyle(.white)
                                .padding(4)
                                .background {
                                    Circle()
                                        .fill(LinearGradient(colors: [Color.pink, Color.red], startPoint: .top, endPoint: .bottom))
                                }
                                .shadow(radius: 4)
                            Text("Drag to location\nthen press \"Save\"")
                                .font(.caption)
                                .multilineTextAlignment(.center)
                                .bold()
                                .shadow(color: Color(UIColor.systemBackground), radius: 4)
                        }
                        .padding()
                        .gesture(
                            DragGesture(coordinateSpace: .global)
                                .onChanged { val in
                                    self.highlightedLocation = reader.convert(.init(x: val.startLocation.x + val.translation.width, y: val.startLocation.y + val.translation.height), from: .global)
                                }
                        )
                        
                    }
                    .annotationSubtitles(.hidden)
                    .annotationTitles(.hidden)
                }
            }
            .toolbar {
                if highlightedLocation == nil {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            withAnimation {
                                self.showSettings.toggle()
                            }
                        } label: {
                            Image(systemName: "gearshape.fill")
                        }
                        .popover(isPresented: $showSettings, attachmentAnchor: .point(.bottom), arrowEdge: .bottom, content: {
                            VStack {
                                Toggle("Show Labels", isOn: $showLabels)
                                Toggle("Show Favorite Gauges", isOn: $showGauges)
                                Stepper("Marker Size", onIncrement: {
                                    withAnimation {
                                        self.annotationSize = Int(Double(self.annotationSize) * 1.2)
                                    }
                                }, onDecrement: {
                                    withAnimation {
                                        self.annotationSize = Int(Double(self.annotationSize) / 1.2)
                                    }
                                })
                            }
                            .padding()
                            .presentationCompactAdaptation(.popover)
                        })
                    }
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            withAnimation {
                                highlightedLocation = reader.convert(.init(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY), from: .global)
                                selectedCoordinate = nil
                            }
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                } else {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            withAnimation {
                                highlightedLocation = nil
                            }
                        } label: {
                            Text("Cancel")
                        }
                    }
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            withAnimation {
                                if let highlightedLocation {
                                    let loc: UserSavedCoordinate = .init(location: highlightedLocation, name: "")
                                    vm.addCoordinate(loc)
                                    self.selectedCoordinate = loc
                                }
                                self.highlightedLocation = nil
                            }
                        } label: {
                            Text("Save")
                        }
                    }
                }
            }
            
        }
        .sheet(item: $selectedCoordinate, onDismiss: { self.detent = .medium }) { loc in
            CoordinateDetailView(coordinate: loc)
                .padding()
            .presentationDetents([.medium, .large], selection: $detent)
            .presentationBackgroundInteraction(.enabled(upThrough: .medium))
        }
    }
}
