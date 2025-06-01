//
//  MicroModels.swift
//  USGS
//
//  Created by Jonathan Melitski on 5/31/25.
//

import Foundation

public struct USGSBoundingBox: Codable {
    let northernLat: Double
    let southernLat: Double
    let easternLong: Double
    let westernLong: Double
    
    public init(northernLat: Double, southernLat: Double, easternLong: Double, westernLong: Double) {
        self.northernLat = northernLat
        self.southernLat = southernLat
        self.easternLong = easternLong
        self.westernLong = westernLong
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

public struct USGSDataSiteCode: Codable {
    let value: String
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
    let siteCode: [USGSDataSiteCode]
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
