//
//  LocationSettings.swift
//  USGS
//
//  Created by Jonathan Melitski on 5/31/25.
//

import Foundation
import SwiftUI

public struct LocationSettings: Codable, Hashable {
    init(defaultSettingsFrom metrics: [LocationDataMetric]) {
        self.displaySettings = .init(series: metrics.count > 0 ? [.init(metric: metrics.first!.descriptor, labelOverride: nil)] : [])
        
        let defaultSeries = metrics.first { metric in
            USGSDataSeries.allCases.contains(where: { series in
                metric.descriptor == series.descriptor
            })
        }
        
        var graphSeries: [WidgetGraphSeries] = []
        if let series = defaultSeries?.descriptor ?? metrics.first?.descriptor {
            graphSeries.append(.init(usgsGraphedElement: series))
        }
        
        // Sensible defaults handled in respective settings initializers
        
        self.graphSettings = .init(series: graphSeries)
        self.widgetSettings = .init()
        self.dashboardSettings = .init()
    }
    
    // Required because firebase/python condenses data when storing
    init(isEmpty empty: Bool) {
        self.graphSettings = .init(series: [])
        self.displaySettings = .init(series: [])
        self.widgetSettings = .init()
        self.dashboardSettings = .init()
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.displaySettings = (try container.decodeIfPresent(WidgetDisplaySettings.self, forKey: .displaySettings)) ?? .init(series: [])
        self.graphSettings = (try container.decodeIfPresent(WidgetGraphSettings.self, forKey: .graphSettings)) ?? .init(series: [])
        self.widgetSettings = (try container.decodeIfPresent(WidgetSettings.self, forKey: .widgetSettings)) ?? .init()
        self.dashboardSettings = (try container.decodeIfPresent(DashboardSettings.self, forKey: .dashboardSettings)) ?? .init()
    }
    
    public var displaySettings: WidgetDisplaySettings
    
    public var graphSettings: WidgetGraphSettings
    
    public var widgetSettings: WidgetSettings
    
    public var dashboardSettings: DashboardSettings
}




