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
        if vm.currentProfile != nil {
            LoggedInView()
        } else {
            LandingView()
        }
    }
}

#Preview {
    ContentView()
}
