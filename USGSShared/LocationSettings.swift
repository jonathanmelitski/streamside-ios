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
        
        var graphSeries: [GraphSeries] = []
        if let series = defaultSeries?.descriptor ?? metrics.first?.descriptor {
            graphSeries.append(.init(usgsGraphedElement: series))
        }
        
        self.graphSettings = .init(series: graphSeries)
    }
    
    // Required because firebase/python condenses data when storing
    init(isEmpty empty: Bool) {
        self.graphSettings = .init(series: [])
        self.displaySettings = .init(series: [])
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.displaySettings = (try container.decodeIfPresent(DisplaySettings.self, forKey: .displaySettings)) ?? .init(series: [])
        self.graphSettings = (try container.decodeIfPresent(GraphSettings.self, forKey: .graphSettings)) ?? .init(series: [])
    }
    
    public var displaySettings: DisplaySettings
    
    public var graphSettings: GraphSettings
}

public struct DisplaySettings: Codable, Hashable {
    // how do you define default display settings, probably just the
    public var series: [DisplaySeries]
}

public struct DisplaySeries: Codable, Hashable {
    public let metric: LocationDataMetricDescriptor
    public var labelOverride: String?
    
    public init(metric: LocationDataMetricDescriptor, labelOverride: String? = nil) {
        self.metric = metric
        self.labelOverride = labelOverride
    }
}

public struct GraphSettings: Codable, Hashable {
    public var series: [GraphSeries]
}

public struct GraphSeries: Codable, Identifiable, Hashable {
    public var id = UUID()
    public let usgsGraphedElement: LocationDataMetricDescriptor
    public var graphForegroundColor: CodableColor
    public var graphPeakValues: Bool
    
    public init(usgsGraphedElement: LocationDataMetricDescriptor,
         graphForegroundColor: CodableColor = Color.blue.cgColor?.graphColor ?? CodableColor(red: 0.02, green: 0.49, blue: 1.0, alpha: 1.0),
         graphPeakValues: Bool = false) {
        self.usgsGraphedElement = usgsGraphedElement
        self.graphForegroundColor = graphForegroundColor
        self.graphPeakValues = graphPeakValues
    }
}



public extension CGColor {
    var graphColor: CodableColor {
        // Unwrap is okay because I'm defining all color values, so I am certain that four components exist
        return CodableColor(red: self.components![0], green: self.components![1], blue: self.components![2], alpha: self.components![3])
    }
}
