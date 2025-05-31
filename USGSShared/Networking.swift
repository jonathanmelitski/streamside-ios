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
    
    public func getUSGSLocations(in region: USGSBoundingBox) async throws -> USGSData {
        let locationString = "\(String(format: "%.6f", region.westernLong)),\(String(format: "%.6f", region.southernLat)),\(String(format: "%.6f", region.easternLong)),\(String(format: "%.6f", region.northernLat))"
        let url: URL = URL(string: "\(baseUrl)?bBox=\(locationString)&format=json&siteStatus=all&siteType=ST")!
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        dateFormatter.timeZone = TimeZone(identifier: "America/New_York")
        let dec = JSONDecoder()
        
        dec.dateDecodingStrategy = .formatted(dateFormatter)
        
        return try dec.decode(USGSData.self, from: data)
    }
}
