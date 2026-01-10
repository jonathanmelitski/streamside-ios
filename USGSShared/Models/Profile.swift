//
//  Profile.swift
//  USGS
//
//  Created by Jonathan Melitski on 10/6/25.
//

internal import FirebaseDatabase

public struct Profile: Identifiable, Codable, EncodableWithConfiguration, Sendable {
    public let id: String
    public var lastUpdated: Date?
    public var firstName: String?
    public var lastName: String?
    public var gauges: [Location]
    public var markers: [UserSavedCoordinate]
    //public var fish: [Any] = []
    
    func isSufficientlyDifferentFrom(otherProfile: Profile?) -> Bool {
        guard let otherProfile else { return true }
        if self.id != otherProfile.id { return true }
        if self.firstName != otherProfile.firstName { return true }
        if self.lastName != otherProfile.lastName { return true }
        if self.gauges.count != otherProfile.gauges.count { return true }
        if self.markers.count != otherProfile.markers.count { return true }
        for gauge in gauges {
            guard let gaugeInOtherProfile = otherProfile.gauges.first(where: { $0.id == gauge.id }) else { return true }
            if gauge.settings != gaugeInOtherProfile.settings { return true }
        }
        for marker in markers {
            guard let markerInOtherProfile = otherProfile.markers.first(where: { $0.id == marker.id }) else { return true }
            if marker.hashValue != markerInOtherProfile.hashValue { return true }
        }
        
        return false
    }
    
    public func encode(to encoder: any Encoder, configuration: ProfileEncodingConfiguration) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        if let timestampD = self.lastUpdated?.timeIntervalSince1970 {
            let timestamp = Int(timestampD)
            try container.encode(timestamp, forKey: .lastUpdated)
        }
        try container.encodeIfPresent(firstName, forKey: .firstName)
        try container.encodeIfPresent(lastName, forKey: .lastName)
        try container.encode(gauges, forKey: .gauges, configuration: configuration)
        try container.encode(markers, forKey: .markers)
    }
    
    public func encode(to encoder: any Encoder) throws {
        try encode(to: encoder, configuration: .init(firebase: false))
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.firstName = try container.decodeIfPresent(String.self, forKey: .firstName)
        self.lastName = try container.decodeIfPresent(String.self, forKey: .lastName)
        self.gauges = (try container.decodeIfPresent([Location].self, forKey: .gauges)) ?? []
        self.markers = (try container.decodeIfPresent([UserSavedCoordinate].self, forKey: .markers)) ?? []
        if let timestamp = try container.decodeIfPresent(TimeInterval.self, forKey: .lastUpdated) {
            self.lastUpdated = Date(timeIntervalSince1970: timestamp)
        } else {
            self.lastUpdated = nil
        }
    }
    
    init(from snapshot: DataSnapshot) throws {
        guard let id = snapshot.childSnapshot(forPath: "uid").value as? String else {
            // This will also enforce that the record exists, since
            // the snapshot doesn't actually enforce that
            throw ProfileError.invalidData
        }
        self.id = id
        self.firstName = snapshot.childSnapshot(forPath: "first_name").value as? String
        self.lastName = snapshot.childSnapshot(forPath: "last_name").value as? String
        if let timestamp = snapshot.childSnapshot(forPath: "last_updated").value as? Int {
            self.lastUpdated = Date(timeIntervalSince1970: TimeInterval(timestamp))
        }
        self.gauges = (try? snapshot.childSnapshot(forPath: "gauges").data(as: [Location].self)) ?? []
        self.markers = (try? snapshot.childSnapshot(forPath: "markers").data(as: [UserSavedCoordinate].self)) ?? []
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "uid"
        case firstName = "firstName"
        case lastName = "lastName"
        case gauges = "gauges"
        case markers = "markers"
        case lastUpdated = "lastUpdated"
    }
}

enum ProfileError: Error {
    case invalidData
}
