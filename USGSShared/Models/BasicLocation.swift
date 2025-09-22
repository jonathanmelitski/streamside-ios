//
//  BasicLocation.swift
//  USGS
//
//  Created by Jonathan Melitski on 9/22/25.
//

public struct BasicLocation: Identifiable, Hashable {
    public let id: String
    public let name: String
    public let geo: BasicLocationGeo
}

public struct BasicLocationGeo: Hashable {
    public let latitude: Double
    public let longitude: Double
}
