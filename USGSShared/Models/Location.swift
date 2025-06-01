//
//  Location.swift
//  USGS
//
//  Created by Jonathan Melitski on 5/31/25.
//

import Foundation
import UIKit

public struct Location: Codable {
    public let name: String
    public let id: String
    public let location: LocationGeog
    public let metrics: [LocationDataMetric]
    
    public var settings: LocationSettings
    
    public static func getArray(from data: USGSData) -> [Location] {
        var res: [Location] = []
        var sorted = data.innerData.sources.sorted(by: { $0.sourceInfo.siteName < $1.sourceInfo.siteName })
        guard let first = sorted.first else { return [] }
        var metricsInLoc: [LocationDataMetric] = [.init(descriptor: .init(name: first.variable.name, description: first.variable.description, code: first.variable.code[0].value), value: first.values[0].value.map({ el in
            LocationDataMetricValue(value: el.value, date: el.date)
        }))]
        var loc: USGSDataSourceValue = first
        while !sorted.isEmpty {
            sorted.removeFirst()
            guard let after = sorted.first else {
                res.append(.init(name: loc.sourceInfo.siteName, id: loc.sourceInfo.siteCode[0].value, location: .init(latitude: loc.sourceInfo.geoLocation.geogLocation.latitude, longitude: loc.sourceInfo.geoLocation.geogLocation.longitude), metrics: metricsInLoc))
                return res
            }
            let metric: LocationDataMetric = .init(descriptor: .init(name: after.variable.name, description: after.variable.description, code: after.variable.code[0].value), value: after.values[0].value.map({ el in
                LocationDataMetricValue(value: el.value, date: el.date)
            }))
            if loc.sourceInfo.siteName == after.sourceInfo.siteName {
                // after belongs to the current location
                metricsInLoc.append(metric)
            } else {
                res.append(.init(name: loc.sourceInfo.siteName, id: loc.sourceInfo.siteCode[0].value, location: .init(latitude: loc.sourceInfo.geoLocation.geogLocation.latitude, longitude: loc.sourceInfo.geoLocation.geogLocation.longitude), metrics: metricsInLoc))
                metricsInLoc = [metric]
                loc = after
            }
        }
        
        return res
    }
    
    public init(name: String, id: String, location: LocationGeog, metrics: [LocationDataMetric], settings: LocationSettings = .defaultSettings) {
        self.name = name
        self.id = id
        self.location = location
        self.metrics = metrics
        self.settings = settings
    }
    
    public static var sampleData: Location {
        let asset = NSDataAsset(name: "SampleUSGSData")!
        let data = asset.data
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        dateFormatter.timeZone = TimeZone(identifier: "America/New_York")
        let dec = JSONDecoder()
        
        dec.dateDecodingStrategy = .formatted(dateFormatter)
        let usgsData = try! dec.decode(USGSData.self, from: data)
        return Location.getArray(from: usgsData)[0]
    }
}

public enum USGSDataSeries: String, Codable {
    case cfs = "00060"
    case temp = "00010"
    
    public static func CtoFconversion(data: LocationDataMetricValue) -> String? {
        let temp = data.value
        guard let numTemp = Double(temp) else {
            return nil
        }
        
        let fahrConv = (numTemp * 9/5) + 32
        let fahrString = String(format: "%.1f", fahrConv)
        return String("\(fahrString)°")
    }
    
    public func getAllValues(from data: Location) -> [LocationDataMetricValue]? {
        let vals = data.metrics.first(where: { $0.descriptor.code == self.rawValue })
        return vals?.value
    }
    
    public func getCurrentValue(from data: Location) -> LocationDataMetricValue?  {
        guard let vals = self.getAllValues(from: data) else { return nil }
        
        let sorted = vals.sorted(by: { $0.date > $1.date })
        
        return sorted.first
    }
    
    public func getCurrentValueString(from data: Location, modifier: ((LocationDataMetricValue) -> String?)? = nil) -> String? {
        guard let value = self.getCurrentValue(from: data) else { return nil }
        
        if let modifier {
            return modifier(value)
        }
        
        return value.value
    }
    
    public func getCurrentValueDate(from data: Location) -> Date? {
        guard let value = self.getCurrentValue(from: data) else { return nil }
        return value.date
    }
    
    public func getCurrentValueDateString(from data: Location) -> String? {
        guard let value = self.getCurrentValue(from: data) else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm" // 'H' = 24-hour format, no leading zero
        formatter.timeZone = TimeZone.current // or set your preferred zone
        
        return formatter.string(from: value.date)
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
