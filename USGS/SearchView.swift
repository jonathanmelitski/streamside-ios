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
    }
}
