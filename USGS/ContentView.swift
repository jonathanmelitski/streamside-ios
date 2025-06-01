//
//  ContentView.swift
//  USGS
//
//  Created by Jonathan Melitski on 5/26/25.
//

import SwiftUI
import USGSShared
import MapKit

struct ContentView: View {
    @ObservedObject var vm = SharedViewModel.shared
    
    var body: some View {
        TabView(selection: $vm.selectedTab) {
            Tab("Search", systemImage: "magnifyingglass", value: .locations) {
                SearchView()
            }
            Tab("Conditions", systemImage: "figure.fishing", value: .conditions) {
                StreamConditionsView()
            }
            Tab("Options", systemImage: "gear", value: .settings) {
                Text("Settings!")
            }
        }
        
        .tabViewStyle(.sidebarAdaptable)
        .environmentObject(vm)
        .onAppear {
            Task {
                await vm.refreshData()
            }
        }
        .onOpenURL { url in
            // Widget handling
            guard url.scheme == "usgswidget" else {
                return
            }
            guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                print("Invalid URL")
                return
            }

            guard let action = components.host, action == "open-conditions" else {
                print("Unknown URL, we can't handle this one!")
                return
            }

            guard let locationId = components.queryItems?.first(where: { $0.name == "id" })?.value else {
                print("Location not found")
                return
            }

            vm.selectedTab = .conditions
            guard vm.locationData.keys.contains(where: { $0 == locationId }) else { return }
            
            vm.selectedLocation = locationId
            
        }
    }
}

#Preview {
    ContentView()
}
