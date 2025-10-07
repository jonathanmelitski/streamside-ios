//
//  Profile.swift
//  USGS
//
//  Created by Jonathan Melitski on 10/6/25.
//

public struct Profile: Identifiable, Codable {
    public let id: String
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
}
