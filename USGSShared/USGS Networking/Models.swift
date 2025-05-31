//
//  Models.swift
//  USGS
//
//  Created by Jonathan Melitski on 5/31/25.
//

import UIKit
import Foundation

public struct USGSData: Codable {
    public static var sampleData: USGSData {
        let asset = NSDataAsset(name: "SampleUSGSData")!
        let data = asset.data
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        dateFormatter.timeZone = TimeZone(identifier: "America/New_York")
        let dec = JSONDecoder()
        
        dec.dateDecodingStrategy = .formatted(dateFormatter)
        return try! dec.decode(USGSData.self, from: data)
    }
    
    public var settings: LocationSettings
    
    public let innerData: USGSInnerDataTimeSeries
    
    public var locationName: String? {
        var value: String? = nil
        self.innerData.sources.forEach { el in
            // not sure if all values return a location
            value = el.sourceInfo.siteName
        }
        return value
    }
    
    enum CodingKeys: String, CodingKey {
        case innerData = "value"
        case settings = "settings"
    }
    
    public init(from decoder: any Decoder) throws {
        var container = try decoder.container(keyedBy: CodingKeys.self)
        self.innerData = try container.decode(USGSInnerDataTimeSeries.self, forKey: .innerData)
        
        // If pulling from cache, we will find the data, else (pulling from API) set the settings to default
        self.settings = (try? container.decode(LocationSettings.self, forKey: .settings)) ?? LocationSettings.defaultSettings
    }
}

public enum USGSDataSeries: String, Codable {
    case cfs = "00060"
    case temp = "00010"
    
    public static func CtoFconversion(data: USGSDataSourceValueActuallyWhy) -> String? {
        let temp = data.value
        guard let numTemp = Double(temp) else {
            return nil
        }
        
        let fahrConv = (numTemp * 9/5) + 32
        let fahrString = String(format: "%.1f", fahrConv)
        return String("\(fahrString)°")
    }
    
    public func getAllValues(from data: USGSData) -> [USGSDataSourceValueActuallyWhy]? {
        data.innerData.sources.first(where: { $0.variable.code.contains(where: { $0.value == self.rawValue })})?.values[0].value
    }
    
    public func getCurrentValue(from data: USGSData) -> USGSDataSourceValueActuallyWhy?  {
        guard let vals = self.getAllValues(from: data) else { return nil }
        
        let sorted = vals.sorted(by: { $0.date > $1.date })
        
        return sorted.first
    }
    
    public func getCurrentValueString(from data: USGSData, modifier: ((USGSDataSourceValueActuallyWhy) -> String?)? = nil) -> String? {
        guard let value = self.getCurrentValue(from: data) else { return nil }
        
        if let modifier {
            return modifier(value)
        }
        
        return value.value
    }
    
    public func getCurrentValueDate(from data: USGSData) -> Date? {
        guard let value = self.getCurrentValue(from: data) else { return nil }
        return value.date
    }
    
    public func getCurrentValueDateString(from data: USGSData) -> String? {
        guard let value = self.getCurrentValue(from: data) else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm" // 'H' = 24-hour format, no leading zero
        formatter.timeZone = TimeZone.current // or set your preferred zone
        
        return formatter.string(from: value.date)
    }
}
