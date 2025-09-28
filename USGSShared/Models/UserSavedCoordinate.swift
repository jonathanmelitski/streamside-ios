
//
//  UserSavedCoordinate.swift
//  USGS
//
//  Created by Jonathan Melitski on 9/27/25.
//

import CoreLocation
import Foundation
import SwiftUI

public struct UserSavedCoordinate: Codable, Identifiable, Equatable, Hashable {
    public static func == (lhs: UserSavedCoordinate, rhs: UserSavedCoordinate) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    public internal(set) var id: UUID
    public var location: CLLocationCoordinate2D
    public var name: String
    public var color: CodableColor
    public var iconString: String
    public var associatedGuageId: String?
    
    public init(location: CLLocationCoordinate2D, name: String, associatedGuageId: String? = nil, iconString: String = "fish", color: Color = .red) {
        self.id = UUID()
        self.location = location
        self.name = name
        self.associatedGuageId = associatedGuageId
        self.iconString = iconString
        self.color = .init(from: color)
    }
}

extension CLLocationCoordinate2D: @retroactive Codable, @retroactive Equatable, @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.latitude)
        hasher.combine(self.longitude)
    }
    
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try container.decode(CLLocationDegrees.self, forKey: .latitude)
        let longitude = try container.decode(CLLocationDegrees.self, forKey: .longitude)
        self.init(latitude: latitude, longitude: longitude)
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.latitude, forKey: .latitude)
        try container.encode(self.longitude, forKey: .longitude)
    }
    
    enum CodingKeys: String, CodingKey {
        case latitude = "latitude"
        case longitude = "longitude"
    }
    
    
    
    
}
