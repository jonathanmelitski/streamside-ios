//
//  DisplaySettings.swift
//  USGS
//
//  Created by Jonathan Melitski on 1/12/26.
//


public struct WidgetDisplaySettings: Codable, Hashable {
    // how do you define default display settings, probably just the
    public var series: [WidgetDisplaySeries]
}

public struct WidgetDisplaySeries: Codable, Hashable {
    public let metric: LocationDataMetricDescriptor
    public var labelOverride: String?
    
    public init(metric: LocationDataMetricDescriptor, labelOverride: String? = nil) {
        self.metric = metric
        self.labelOverride = labelOverride
    }
}
