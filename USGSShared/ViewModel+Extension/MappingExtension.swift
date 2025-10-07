//
//  MappingExtension.swift
//  USGS
//
//  Created by Jonathan Melitski on 9/27/25.
//

import SwiftUI
import CoreLocation

extension SharedViewModel {
    public func addCoordinate(_ coordinate: UserSavedCoordinate) {
        self.currentProfile?.markers.append(coordinate)
    }
    
    public func updateCoordinate(id: UUID, txn: @escaping () -> UserSavedCoordinate) {
        if let idx = (self.currentProfile?.markers ?? []).firstIndex(where: { $0.id == id }) {
            self.currentProfile!.markers[idx] = txn()
        }
    }
    
    public func deleteCoordinate(coordinate: UserSavedCoordinate) {
        self.currentProfile?.markers.removeAll(where: { $0.id == coordinate.id })
    }
}
