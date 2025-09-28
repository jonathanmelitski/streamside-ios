//
//  MappingExtension.swift
//  USGS
//
//  Created by Jonathan Melitski on 9/27/25.
//

import SwiftUI
import CoreLocation

extension SharedViewModel {
    // Should add Firebase DB to this, but will need to handle login in that case? Maybe I don't if I only deal with DB access on a global scope?
    
    
    func saveCoordinates() {
        let enc = JSONEncoder()
        let data = try? enc.encode(self.userSavedCoordinates)
        Self.data?.set(data, forKey: Self.coordinatesStorageKey)
    }
    
    func getCoordinates() -> [UserSavedCoordinate]? {
        guard let data = Self.data?.value(forKey: Self.coordinatesStorageKey) as? Data else {
            return nil
        }
        let dec = JSONDecoder()
        return try? dec.decode([UserSavedCoordinate].self, from: data)
    }
    
    public func addCoordinate(_ coordinate: UserSavedCoordinate) {
        self.userSavedCoordinates.append(coordinate)
        self.saveCoordinates()
    }
    
    public func updateCoordinate(id: UUID, txn: @escaping () -> UserSavedCoordinate) {
        if let idx = self.userSavedCoordinates.firstIndex(where: { $0.id == id }) {
            self.userSavedCoordinates[idx] = txn()
        }
        self.saveCoordinates()
    }
    
    public func deleteCoordinate(coordinate: UserSavedCoordinate) {
        self.userSavedCoordinates.removeAll(where: { $0.id == coordinate.id })
        self.saveCoordinates()
    }
}
