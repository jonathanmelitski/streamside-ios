//
//  Location.swift
//  USGS
//
//  Created by Jonathan Melitski on 5/31/25.
//

import Foundation

public struct Location: Codable {
    public let name: String
    public let location: LocationGeog
    public let metrics: [LocationDataMetric]
    
    public static func getArray(from data: USGSData) -> [Location] {
        var res: [Location] = []
        var sorted = data.innerData.sources.sorted(by: { $0.sourceInfo.siteName < $1.sourceInfo.siteName })
        guard let first = sorted.first else { return [] }
        var metricsInLoc: [LocationDataMetric] = [.init(descriptor: .init(name: first.variable.name, description: first.variable.description, code: first.variable.code[0].value), value: first.values[0].value.map({ el in
            LocationDataMetricValue(value: el.value, date: el.date)
        }))]
        var loc: USGSDataSourceInfo = first.sourceInfo
        while !sorted.isEmpty {
            sorted.removeFirst()
            guard let after = sorted.first else {
                res.append(.init(name: loc.siteName, location: .init(latitude: loc.geoLocation.geogLocation.latitude, longitude: loc.geoLocation.geogLocation.longitude), metrics: metricsInLoc))
                return res
            }
            let metric: LocationDataMetric = .init(descriptor: .init(name: after.variable.name, description: after.variable.description, code: after.variable.code[0].value), value: after.values[0].value.map({ el in
                LocationDataMetricValue(value: el.value, date: el.date)
            }))
            if loc.siteName == after.sourceInfo.siteName {
                // after belongs to the current location
                metricsInLoc.append(metric)
            } else {
                res.append(.init(name: loc.siteName, location: .init(latitude: loc.geoLocation.geogLocation.latitude, longitude: loc.geoLocation.geogLocation.longitude), metrics: metricsInLoc))
                metricsInLoc = [metric]
                loc = after.sourceInfo
            }
        }
        
        return res
    }
}

public struct LocationDataMetric: Codable {
    public let descriptor: LocationDataMetricDescriptor
    public let value: [LocationDataMetricValue]
}

public struct LocationDataMetricDescriptor: Codable {
    public let name: String
    public let description: String
    public let code: String
}

public struct LocationDataMetricValue: Codable, Identifiable {
    public var id = UUID()
    public let value: String
    public let date: Date
}

public struct LocationGeog: Codable {
    public let latitude: Double
    public let longitude: Double
}
