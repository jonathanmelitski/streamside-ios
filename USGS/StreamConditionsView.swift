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
        let showSheet = Binding(get: { vm.selectedLocation != nil }, set: { new in
            if !new {
                vm.selectedLocation = nil
            }
        })
        
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(vm.favoriteLocations, id: \.self) { el in
                        Group {
                            if let kv = vm.usgsData.first(where: { $0.key == el }) {
                                if let val = kv.value {
                                    Button {
                                        vm.selectedLocation = kv.key
                                    } label: {
                                        MediumWidgetView(data: val)
                                    }
                                } else {
                                    Text("Unable to fetch data for \(el)")
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
                .navigationTitle("My Locations")
                .navigationBarTitleDisplayMode(.large)
            }
            .sheet(isPresented: showSheet) {
                StreamConditionsFullscreenView()
            }
        }
        
    }
}
