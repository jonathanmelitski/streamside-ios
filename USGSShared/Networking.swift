//
//  Networking.swift
//  USGS
//
//  Created by Jonathan Melitski on 5/26/25.
//
import Foundation
import UIKit

public class NetworkManager {
    public static let shared = NetworkManager()
    
    public var baseUrl = "https://waterservices.usgs.gov/nwis/iv/"

    public func getUSGSData(for locationId: String) async throws -> USGSData {
        let url: URL = URL(string: "\(baseUrl)?sites=\(locationId)&format=json&period=P7D")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        dateFormatter.timeZone = TimeZone(identifier: "America/New_York")
        let dec = JSONDecoder()
        
        dec.dateDecodingStrategy = .formatted(dateFormatter)
        
        return try dec.decode(USGSData.self, from: data)
    }
}

// MARK: Data Structures + Decoding

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
    
    
    public static let cfsVariableCode = "00060"
    public static let tempVariableCode = "00010"
    
    
    public let innerData: USGSInnerDataTimeSeries
    
    public var cfsAllValues: [USGSDataSourceValueActuallyWhy] {
        return (self.innerData.sources.first(where: { $0.variable.code.contains(where: { $0.value == Self.cfsVariableCode })})?.values[0].value) ?? []
    }
    
    public var locationName: String? {
        var value: String? = nil
        self.innerData.sources.forEach { el in
            // not sure if all values return a location
            value = el.sourceInfo.siteName
        }
        return value
    }
    
    public var tempAllValues: [USGSDataSourceValueActuallyWhy] {
        return (self.innerData.sources.first(where: { $0.variable.code.contains(where: { $0.value == Self.tempVariableCode })})?.values[0].value) ?? []
    }
    
    public var cfsCurrentValue: USGSDataSourceValueActuallyWhy? {
        guard !self.cfsAllValues.isEmpty else { return nil }
        return self.cfsAllValues.sorted(by: { $0.date > $1.date }).first!
    }
    
    public var cfs: String? {
        return self.cfsCurrentValue?.value
    }
    
    public var cfsDate: Date? {
        return self.cfsCurrentValue?.date
    }
    
    public var cfsDateStr: String? {
        guard let date = cfsDate else { return nil }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm" // 'H' = 24-hour format, no leading zero
        formatter.timeZone = TimeZone.current // or set your preferred zone

        return formatter.string(from: date)
    }
    
    public var tempCurrentValue: USGSDataSourceValueActuallyWhy? {
        guard !self.tempAllValues.isEmpty else { return nil }
        
        return self.tempAllValues.sorted(by: { $0.date > $1.date }).first!
    }
    
    public var tempC: String? {
        return self.tempCurrentValue?.value
    }
    
    public var tempDate: Date? {
        return self.tempCurrentValue?.date
    }
    
    public var tempDateStr: String? {
        guard let date = tempDate else { return nil }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm" // 'H' = 24-hour format, no leading zero
        formatter.timeZone = TimeZone.current // or set your preferred zone

        return formatter.string(from: date)
    }
    
    public var tempF: String? {
        guard let temp = tempC, let numTemp = Double(temp) else {
            return nil
        }
        
        let fahrConv = (numTemp * 9/5) + 32
        let fahrString = String(format: "%.1f", fahrConv)
        return String("\(fahrString)°")
    }
    
    enum CodingKeys: String, CodingKey {
        case innerData = "value"
    }
}

public struct USGSInnerDataTimeSeries: Codable {
    let sources: [USGSDataSourceValue]
    
    enum CodingKeys: String, CodingKey {
        case sources = "timeSeries"
    }
}

public struct USGSDataSourceValue: Codable {
    let sourceInfo: USGSDataSourceInfo
    let variable: USGSDataSourceVariable
    let values: [USGSDataSourceValueWhy]
}

public struct USGSDataSourceVariable: Codable {
    let name: String
    let description: String
    let code: [USGSVariableCode]
    
    enum CodingKeys: String, CodingKey {
        case name = "variableName"
        case code = "variableCode"
        case description = "variableDescription"
    }
}

public struct USGSDataSourceInfo: Codable {
    let siteName: String
    let geoLocation: USGSGeoLocation
}

public struct USGSGeoLocation: Codable {
    let geogLocation: USGSGeographicLocation
}

public struct USGSGeographicLocation: Codable {
    let latitude: Double
    let longitude: Double
}

public struct USGSVariableCode: Codable {
    let value: String
    let variableID: Int
}

public struct USGSDataSourceValueWhy: Codable {
    let value: [USGSDataSourceValueActuallyWhy]
}

public struct USGSDataSourceValueActuallyWhy: Codable, Identifiable {
    public let id = UUID()
    public let value: String
    public let date: Date
    
    enum CodingKeys: String, CodingKey {
        case value
        case date = "dateTime"
    }
}




