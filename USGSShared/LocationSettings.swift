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
        self.displaySettings = .init(valuesToShow: metrics.count > 0 ? [metrics.first!.descriptor] : [])
        
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
    
    public var displaySettings: DisplaySettings
    
    public var graphSettings: GraphSettings
}

public struct DisplaySettings: Codable, Hashable {
    // how do you define default display settings, probably just the
    public var valuesToShow: [LocationDataMetricDescriptor]
}

public struct GraphSettings: Codable, Hashable {
    public var series: [GraphSeries]
}

public struct GraphSeries: Codable, Identifiable, Hashable {
    public var id = UUID()
    public let usgsGraphedElement: LocationDataMetricDescriptor
    public var graphForegroundColor: GraphColor
    public var graphPeakValues: Bool
    
    public init(usgsGraphedElement: LocationDataMetricDescriptor,
         graphForegroundColor: GraphColor = Color.blue.cgColor?.graphColor ?? GraphColor(red: 0.02, green: 0.49, blue: 1.0, alpha: 1.0),
         graphPeakValues: Bool = false) {
        self.usgsGraphedElement = usgsGraphedElement
        self.graphForegroundColor = graphForegroundColor
        self.graphPeakValues = graphPeakValues
    }
}

public struct GraphColor: Codable, Hashable {
    public let red: CGFloat
    public let green: CGFloat
    public let blue: CGFloat
    public let alpha: CGFloat
    
    public init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
    
    public init(from color: Color) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 1
        if UIColor(color).getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            self.red = red
            self.green = green
            self.blue = blue
            self.alpha = alpha
        } else {
            self.red = 0
            self.green = 0
            self.blue = 0
            self.alpha = 1
        }
    }
    
    public var toSwiftUIColor: Color {
        return Color(red: self.red, green: self.green, blue: self.blue, opacity: self.alpha)
    }
}

public extension CGColor {
    var graphColor: GraphColor {
        // Unwrap is okay because I'm defining all color values, so I am certain that four components exist
        return GraphColor(red: self.components![0], green: self.components![1], blue: self.components![2], alpha: self.components![3])
    }
}
