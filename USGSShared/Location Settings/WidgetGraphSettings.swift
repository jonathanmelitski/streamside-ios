//
//  GraphSettings.swift
//  USGS
//
//  Created by Jonathan Melitski on 1/12/26.
//

import SwiftUI

public struct WidgetGraphSettings: Codable, Hashable {
    public var series: [WidgetGraphSeries] = []
    public var domainDays: Int = 7
    
    init(series: [WidgetGraphSeries] = [], domainDays: Int = 7) {
        self.series = series
        self.domainDays = domainDays
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.series = (try? container.decode([WidgetGraphSeries].self, forKey: .series)) ?? []
        self.domainDays = (try? container.decodeIfPresent(Int.self, forKey: .domainDays)) ?? 7
    }
}

public struct WidgetGraphSeries: Codable, Identifiable, Hashable {
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
