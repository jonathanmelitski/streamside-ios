//
//  LocationManager.swift
//  USGS
//
//  Created by Jonathan Melitski on 1/10/26.
//

import CoreLocation
import SwiftUI

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    let manager: CLLocationManager
    
    @Published var location: CLLocationCoordinate2D?
    @Published var locationStatus: CLAuthorizationStatus = .notDetermined
    
    override init() {
        self.manager = CLLocationManager()
        super.init()
        self.manager.delegate = self
        self.locationStatus = self.manager.authorizationStatus
        self.manager.requestWhenInUseAuthorization()
        if case .authorized = locationStatus {
            self.manager.startUpdatingLocation()
        }
    }
    
    deinit {
        self.manager.stopUpdatingLocation()
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let first = locations.first else { return }
        Task { @MainActor in
            self.location = first.coordinate
        }
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: any Error
    ) {
        Task { @MainActor in
            self.location = nil
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            self.locationStatus = manager.authorizationStatus
            if case .authorized = manager.authorizationStatus {
                manager.startUpdatingLocation()
            } else {
                manager.stopUpdatingLocation()
            }
        }
    }
}
