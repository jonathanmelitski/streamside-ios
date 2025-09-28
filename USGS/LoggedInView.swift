//
//  LoggedInView.swift
//  USGS
//
//  Created by Jonathan Melitski on 9/28/25.
//

import SwiftUI
import USGSShared

struct LoggedInView: View {
    @ObservedObject var vm = SharedViewModel.shared
    
    var body: some View {
        TabView(selection: $vm.selectedTab) {
            Tab("Conditions", systemImage: "figure.fishing", value: .conditions) {
                NavigationStack(path: $vm.nav) {
                    StreamConditionsView()
                        .navigationDestination(for: Location.self) { loc in
                            StreamConditionsFullscreenView(location: loc)
                        }
                        .navigationDestination(for: String.self) { str in
                            switch str {
                            case "ADD NEW":
                                SearchView()
                            default:
                                exit(EXIT_FAILURE)
                            }
                        }
                }
            }
            Tab("My Map", systemImage: "map", value: .maps) {
                NavigationStack {
                    UserPersonalMapView()
                }
            }
            
            Tab("Auth Test", systemImage: "gearshape", value: .fish) {
                AuthTestView()
            }
        }
        .tabViewStyle(.sidebarAdaptable)
        .environmentObject(vm)
        .onAppear {
            Task {
                await vm.refreshData()
            }
        }
        .onChange(of: vm.selectedTab) {
            self.vm.nav.removeLast(vm.nav.count)
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
            if let loc = vm.locationData[locationId] {
                vm.nav.append(loc)
            }
            
        }
    }
}
