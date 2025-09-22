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
            VStack(alignment: .leading, spacing: 8) {
                ForEach(vm.favoriteLocations, id: \.self) { el in
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
        .navigationTitle("My Locations")
    }
}
