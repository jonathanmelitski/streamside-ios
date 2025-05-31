//
//  LocationSettings.swift
//  USGS
//
//  Created by Jonathan Melitski on 5/31/25.
//

import Foundation
import SwiftUI

public struct LocationSettings: Codable {
    public static let defaultSettings: LocationSettings = .init(
        graphSettings: .init(
            series: [
                .init(usgsGraphedElement: .cfs)
            ]
        )
    )
    
    
    public var graphSettings: GraphSettings
}

public struct GraphSettings: Codable {
    public var series: [GraphSeries]
}

public struct GraphSeries: Codable, Identifiable {
    public var id = UUID()
    public let usgsGraphedElement: USGSDataSeries
    public let graphForegroundColor: GraphColor
    public let graphPeakValues: Bool
    
    init(usgsGraphedElement: USGSDataSeries,
         graphForegroundColor: GraphColor = Color.blue.cgColor?.graphColor ?? GraphColor(red: 0.02, green: 0.49, blue: 1.0, alpha: 1.0),
         graphPeakValues: Bool = false) {
        self.usgsGraphedElement = usgsGraphedElement
        self.graphForegroundColor = graphForegroundColor
        self.graphPeakValues = graphPeakValues
    }
}

public struct GraphColor: Codable {
    public let red: CGFloat
    public let green: CGFloat
    public let blue: CGFloat
    public let alpha: CGFloat
    
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
