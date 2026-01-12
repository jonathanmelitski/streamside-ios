//
//  DashboardComponentBlockView.swift
//  USGS
//
//  Created by Jonathan Melitski on 1/12/26.
//

import SwiftUI
import USGSShared

struct DashboardComponentBlockView: View {
    let block: any DashboardComponentBlock
    @Binding var loc: Location
    let metric: LocationDataMetricDescriptor
    
    var body: some View {
        switch block.type {
        case .graph:
            DashboardGraphView(configuration: block.configuration as! DashboardGraphConfiguration, location: loc, metric: metric)
        case .value:
            DashboardValueView(configuration: block.configuration as! DashboardValueConfiguration, location: loc, metric: metric)
        }
    }
}
