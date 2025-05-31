//
//  USGSLocationView.swift
//  USGS
//
//  Created by Jonathan Melitski on 5/27/25.
//

import SwiftUI
import USGSShared

struct USGSLocationView: View {
    let id: String
    
    @State var data: USGSData?
    @EnvironmentObject var vm: SharedViewModel
    
    
    var body: some View {
        ScrollView {
            Group {
                if let data {
                    VStack {
                        Text(data.cfs ?? "")
                    }
                    .toolbar {
                        ToolbarItem(placement: .primaryAction) {
                            Button {
                                if vm.favoriteLocations.contains(where: { $0 == id }) {
                                    vm.removeFavoriteLocation(id)
                                } else {
                                    vm.addFavoriteLocation(id)
                                }
                            } label: {
                                Image(systemName: "star\(vm.favoriteLocations.contains(where: { $0 == id }) ? ".fill" : "")")
                            }
                        }
                    }
                }
            }
                .onAppear {
                    Task { @MainActor in
                        self.data = try? await NetworkManager.shared.getUSGSData(for: id)
                    }
                }
        }
        // dynamic name
        .navigationTitle("Beaverkill")
        
        
            
//        Group {
//            if let data {
//                ScrollView {
//                    VStack {
//                        Text(data.cfs ?? "")
//                    }
//                }
//            }
//        }
//        .onAppear {
//            Task { @MainActor in
//                self.data = try? await NetworkManager.shared.getUSGSData(for: id)
//                print("i'm gonna cum")
//            }
//        }
    }
    
}
