//
//  StreamConditionsView.swift
//  USGS
//
//  Created by Jonathan Melitski on 5/28/25.
//

import SwiftUI
import USGSShared
import FirebaseAuth

struct StreamConditionsView: View {
    @EnvironmentObject var vm: SharedViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(vm.favoriteLocations.sorted(), id: \.self) { el in
                    Group {
                        if let value = (vm.currentProfile?.gauges ?? []).first(where: { $0.id == el.id }) {
                            NavigationLink(value: value) {
                                MediumWidgetView(data: value)
                            }
                        } else {
                            Text("Unable to fetch data")
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
            ToolbarItem(placement: .primaryAction) {
                Button("Logout") {
                    try? vm.logOut()
                }
            }
        }
        .navigationTitle("My Locations")
    }
}
