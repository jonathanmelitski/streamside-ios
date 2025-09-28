//
//  StreamConditionsView.swift
//  USGS
//
//  Created by Jonathan Melitski on 5/28/25.
//

import SwiftUI
import USGSShared

struct StreamConditionsView: View {
    @EnvironmentObject var vm: SharedViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(vm.favoriteLocations.sorted(by: {
                    if vm.widgetPreferredLocation == $0 { return true }
                    if vm.widgetPreferredLocation == $1 { return false }
                    return $0 < $1
                }), id: \.self) { el in
                    Group {
                        if let kv = vm.locationData.first(where: { $0.key == el }) {
                            let val = kv.value
                            NavigationLink(value: val) {
                                MediumWidgetView(data: val)
                            }
                        } else {
                            Text("Unable to fetch data for \(el)")
                        }
                    }
                    .overlay {
                        HStack {
                            Spacer()
                            VStack {
                                Button {
                                    withAnimation {
                                        if vm.widgetPreferredLocation == el {
                                            vm.setPreferredWidgetLocation(nil)
                                        } else {
                                            vm.setPreferredWidgetLocation(el)
                                        }
                                    }
                                    
                                } label: {
                                    Image(systemName: vm.widgetPreferredLocation == el ? "crown.fill" : "crown")
                                        .foregroundStyle(.yellow)
                                        .opacity(vm.widgetPreferredLocation == el ? 1.0 : 0.3)
                                }
                                
                                Spacer()
                            }
                        }
                    }
                    .padding()
                    .frame(height: 150)
                    .background {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(LinearGradient(colors: [Color("TopGradient"), Color("BottomGradient")], startPoint: .top, endPoint: .bottom))
                    }
                    
                    .padding()
                    .shadow(radius: 8)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    vm.nav.append("ADD NEW")
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .navigationTitle("My Locations")
    }
}
