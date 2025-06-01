//
//  SearchView.swift
//  USGS
//
//  Created by Jonathan Melitski on 5/27/25.
//

import SwiftUI
import USGSShared

struct SearchView: View {
    @EnvironmentObject var vm: SharedViewModel
    
    var body: some View {
        Text("SearchView")
            .onTapGesture {
                vm.addFavoriteLocation("01420500")
            }
        Text("Rremove")
            .onTapGesture {
                vm.removeFavoriteLocation("01420500")
            }
        Text("Fetch")
            .onTapGesture {
                Task {
                    let data = try? await NetworkManager.shared.getUSGSLocations(in: .init(northernLat: 42.227977, southernLat: 41.524483, easternLong: -74.189429, westernLong: -75.321021))
                    let locs = Location.getArray(from: data!)
                }
            }
    }
}
