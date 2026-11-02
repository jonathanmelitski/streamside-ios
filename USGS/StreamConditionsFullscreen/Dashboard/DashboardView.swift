//
//  DashboardView.swift
//  USGS
//
//  Created by Jonathan Melitski on 1/12/26.
//

import SwiftUI
import USGSShared

struct DashboardView: View {
    @Binding var location: Location?
    @State var stubSectionIndex: Int? = nil
    
    var body: some View {
        if let location {
            VStack {
                if location.settings.dashboardSettings.displaySections.count == 0 && stubSectionIndex == nil {
                    Button {
                        withAnimation {
                            stubSectionIndex = 0
                        }
                    } label: {
                        VStack(alignment: .center) {
                            Image(systemName: "plus.square.fill")
                                .font(.system(size: 96))
                            Text("Tap to add your first section")
                                .font(.title)
                                .bold()
                                .multilineTextAlignment(.center)
                        }
                    }
                    .foregroundStyle(.thickMaterial)
                    .padding(.horizontal, 32)
                    .padding(.top, 120)
                } else if let stubSectionIndex {
                    let start = location.settings.dashboardSettings.displaySections.prefix(upTo: stubSectionIndex)
                    let end = location.settings.dashboardSettings.displaySections.suffix(from: stubSectionIndex)
                    ForEach(start, id: \.self) { before in
                        DashboardSectionView(before, loc: $location)
                    }
                    StubSectionView(location: location) {section in
                        withAnimation {
                            self.stubSectionIndex = nil
                            self.location = location.withUpdatedSettings { settings in
                                settings.dashboardSettings.displaySections.insert(section, at: stubSectionIndex)
                            }
                        }
                    }
                    ForEach(end, id: \.self) { after in
                        DashboardSectionView(after, loc: $location)
                    }
                } else {
                    ForEach(location.settings.dashboardSettings.displaySections, id: \.self) { section in
                        DashboardSectionView(section, loc: $location)
                    }
                    Button("Add Section") {
                        withAnimation {
                            self.stubSectionIndex = location.settings.dashboardSettings.displaySections.count
                        }
                    }
                    .buttonBorderShape(.capsule)
                    .buttonStyle(.borderedProminent)
                    .foregroundStyle(.white)
                    .font(.caption)
                    .padding()
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        DashboardView(location: .constant(Location.sampleData))
    }
}
