//
//  DashboardView.swift
//  USGS
//
//  Created by Jonathan Melitski on 1/12/26.
//

import SwiftUI
import USGSShared

struct DashboardView: View {
    @Binding var location: Location
    
    var body: some View {
        VStack {
            Text("Hello world!")
            Button("Print!") {
                print(location.settings.dashboardSettings)
            }
            Button("Add Sections") {
                let newSection = DashboardDisplaySection(metric: location.metrics.first!.descriptor)
                location = location.withUpdatedSettings({ settings in
                    settings.dashboardSettings.displaySections = [newSection]
                })
            }
            Button("Print Encoding") {
                let data = try! JSONEncoder().encode(location.settings.dashboardSettings)
                print(String(data: data, encoding: .utf8)!)
                
                let decoded = try! JSONDecoder().decode(DashboardSettings.self, from: data)
                
                let reenc = try! JSONEncoder().encode(decoded)
                print(String(data: data, encoding: .utf8)!)
            }
            Text(String(location.settings.dashboardSettings.displaySections.count))
        }
    }
}

#Preview {
    NavigationStack {
        DashboardView(location: .constant(Location.sampleData))
    }
}
