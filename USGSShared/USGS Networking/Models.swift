//
//  Models.swift
//  USGS
//
//  Created by Jonathan Melitski on 5/31/25.
//

import UIKit
import Foundation

public struct USGSData: Codable {
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
    }
}
