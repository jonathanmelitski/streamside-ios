//
//  Location.swift
//  USGS
//
//  Created by Jonathan Melitski on 5/31/25.
//

import Foundation
import UIKit

public struct Location: Codable, Hashable, Equatable, Identifiable {
    public static func == (lhs: Location, rhs: Location) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    public let name: String
    public let id: String
    public let location: LocationGeog
    public let metrics: [LocationDataMetric]
    
    public var tupledName: (String, String, String?)? {
        if let match = name.wholeMatch(of: /^(?<river>.+?) AT (?<location>.+) (?<state>[A-Z]{2})$/) {
            let river = String(match.river)
            let location = String(match.location)
            let state = String(match.state)
            return (river, location, state)
        } else if let match = name.wholeMatch(of: /^(?<river>.+?) AT (?<location>.+)$/) {
            let river = String(match.river)
            let location = String(match.location)
            return (river, location, nil)
        }
        return nil
    }
    
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
    
    public init(name: String, id: String, location: LocationGeog, metrics: [LocationDataMetric]) {
        self.name = name
        self.id = id
        self.location = location
        self.metrics = metrics
        
        if let prevLoc = SharedViewModel.shared.locationData[id] {
            self.settings = prevLoc.settings
        } else {
            self.settings = LocationSettings(defaultSettingsFrom: metrics)
        }
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
    
    public func withUpdatedSettings(_ modification: (inout LocationSettings) -> Void) -> Location {
        var new = self
        modification(&new.settings)
        return new
    }
}

public enum USGSDataSeries: Codable, CaseIterable {
    case cfs
    case temp
    
    public var descriptor: LocationDataMetricDescriptor {
        switch self {
        case .cfs:
            return .init(name: nil, description: nil, code: "00060")
        case .temp:
            return .init(name: nil, description: nil, code: "00010")
        }
    }
    
    public var conversion: ((LocationDataMetricValue) -> LocationDataMetricValue)? {
        switch self {
        case .temp:
            return Self.CtoFconversion
        default:
            return nil
        }
    }
    
    public var stringSuffix: String {
        switch self {
        case .temp:
            return "°"
        default:
            return ""
        }
    }
    
    public var labelShort: String {
        switch self {
        case .temp:
            return "TEMP"
        case .cfs:
            return "CFS"
        }
    }
    
    
    public static func CtoFconversion(data: LocationDataMetricValue) -> LocationDataMetricValue {
        let temp = data.value
        
        // I hope this doesn't bite me in the butt.
        let numTemp = Double(temp)!
        
        let fahrConv = (numTemp * 9/5) + 32
        let fahrString = String(format: "%.1f", fahrConv)
        
        return .init(value: fahrString, date: data.date)
    }
    
    
}

public struct LocationDataMetric: Codable, Hashable, Equatable {
    public let descriptor: LocationDataMetricDescriptor
    public let value: [LocationDataMetricValue]
    
    var descriptorSpecificConversion: ((LocationDataMetricValue) -> LocationDataMetricValue)? {
        return USGSDataSeries.allCases.map { el in
            return (el.descriptor, el.conversion)
        }.first(where: { $0.0 == descriptor })?.1
    }
    
    public var descriptorSpecificValues: [LocationDataMetricValue] {
        // perform a desired operation on certain descriptors (based on settings?)
        return self.value.map { el in
            if let conversion = self.descriptorSpecificConversion {
                return conversion(el)
            } else {
                return el
            }
        }
    }
    
    public var descriptorSpecificCurrentValue: Double? {
        guard let latest = self.value.sorted(by: { $0.date > $1.date }).first else { return nil }
        if let conversion = self.descriptorSpecificConversion {
            return Double(conversion(latest).value)
        }
        return Double(latest.value)
    }
    
    public var descriptorSpecificCurrentValueString: String? {
        guard let value = self.descriptorSpecificCurrentValue else { return nil }
        if let predefinedSeries = USGSDataSeries.allCases.first(where: { $0.descriptor == self.descriptor }) {
            return "\(value)\(predefinedSeries.stringSuffix)"
        }
        return "\(value)"
    }
    
    public var descriptorSpecificLabelShort: String {
        if let predefinedSeries = USGSDataSeries.allCases.first(where: { $0.descriptor == self.descriptor }) {
            return predefinedSeries.labelShort
        }
        return self.descriptor.name!
    }
    
}

public struct LocationDataMetricDescriptor: Codable, Equatable, Hashable {
    public static func == (lhs: LocationDataMetricDescriptor, rhs: LocationDataMetricDescriptor) -> Bool {
        return lhs.code == rhs.code
    }
    
    public let name: String?
    public let description: String?
    public let code: String
    
    public var parsedLabel: String? {
        
        if let match = self.name?.split(separator: ",").first {
            return String(match).trimmingCharacters(in: .whitespaces)
        }
        return nil
    }
}

public struct LocationDataMetricValue: Codable, Identifiable, Hashable {
    public var id = UUID()
    public let value: String
    public let date: Date
}

public struct LocationGeog: Codable, Hashable {
    public let latitude: Double
    public let longitude: Double
}
