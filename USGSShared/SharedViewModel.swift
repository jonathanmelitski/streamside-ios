//
//  SharedViewModel.swift
//  USGS
//
//  Created by Jonathan Melitski on 5/27/25.
//

import Foundation
import Combine
import SwiftUI
import WidgetKit
import FirebaseDatabase

public class SharedViewModel: ObservableObject {
    public static var shared = SharedViewModel()
    
    static let favoritesKey = "USGSApp-Favorites"
    static let widgetPreferenceKey = "USGSApp-WidgetPreference"
    static let cacheKey = "USGSApp-Data"
    
    @Published public private(set) var favoriteLocations: [String] = []
    @Published public private(set) var locationData: [String : Location] = [:]
    @Published public var selectedTab: SharedViewModel.Tab = .locations
    @Published public var nav: NavigationPath = .init()
    @Published public var allLocations: [BasicLocation] = []
    @Published public var widgetPreferredLocation: String?
    
    static let data = UserDefaults(suiteName: "group.com.jmelitski.USGS")
    
    
    init() {
        resetState()
    }
    
    public func resetState(completion: (() -> ())? = nil) {
        let locs = self.getLocs() ?? []
        let dict = self.getDict() ?? [:]
        
        self.favoriteLocations = locs
        self.locationData = dict
        self.widgetPreferredLocation = Self.data?.string(forKey: Self.widgetPreferenceKey)
        
        if let first = self.favoriteLocations.first {
            selectedTab = .conditions
        }
        
        Task { @MainActor in
            await self.refreshData()
            completion?()
        }
    }
    
    public func addFavoriteLocation(_ id: String) {
        self.favoriteLocations.append(id)
        self.saveLocs()
        Task { @MainActor in
            if let data = try? await self.fetchLocationData(id) {
                self.locationData.updateValue(data, forKey: id)
                self.saveDict()
            }
        }
    }
    
    public func removeFavoriteLocation(_ id: String) {
        self.favoriteLocations.removeAll(where: { $0 == id })
        self.locationData.removeValue(forKey: id)
        self.saveDict()
        self.saveLocs()
    }
    
    public func setPreferredWidgetLocation(_ id: String?) {
        self.widgetPreferredLocation = id
        Self.data?.set(id, forKey: Self.widgetPreferenceKey)
        WidgetCenter.shared.reloadTimelines(ofKind: "USGS_Widget")
    }
    
    public func loadAllLocationsFromFirebase() {
        let db = Database.database(url: "https://streamside-2b8f1-default-rtdb.firebaseio.com/")
        db.isPersistenceEnabled = true
        let reference = db.reference(withPath: "/all_usgs_locations")
        reference.observe(.value) { snapshot in
            var locs: [BasicLocation] = []
            for child in snapshot.children {
                if let childSnap = child as? DataSnapshot,
                   let name = childSnap.childSnapshot(forPath: "name").value as? String,
                   let id = childSnap.childSnapshot(forPath: "id").value as? String,
                   let state = childSnap.childSnapshot(forPath: "state").value as? String,
                   let lat = childSnap.childSnapshot(forPath: "geo").childSnapshot(forPath: "latitude").value as? Double,
                   let long = childSnap.childSnapshot(forPath: "geo").childSnapshot(forPath: "longitude").value as? Double {
                    locs.append(.init(id: id, name: name, state: state, geo: BasicLocationGeo(latitude: lat, longitude: long)))
                } else {
                     print("Brokey!")
                }
            }
            
            self.allLocations = locs
        }
    }
    
    public func saveLocationData(_ data: Location, for id: String) {
        self.locationData.updateValue(data, forKey: id)
        self.saveDict()
    }
    
    public enum Tab {
        case conditions, settings, locations
    }
    
    @MainActor public func refreshData() async {
        let keys = self.favoriteLocations
        self.locationData = await withTaskGroup(of: (String, Location?).self, returning: [String : Location].self) { group in
            keys.forEach { key in
                group.addTask {
                    return (key, try? await self.fetchLocationData(key))
                }
            }
            
            var finalDict: [String: Location] = [:]
            for await result in group {
                if let loc = result.1 {
                    finalDict.updateValue(loc, forKey: result.0)
                }
            }
            return finalDict
        }
        self.saveDict()
    }
    
    @discardableResult
    @MainActor public func fetchLocationData(_ id: String) async throws -> Location {
        let data = try await NetworkManager.shared.getUSGSData(for: id)
        let locations = Location.getArray(from: data)
        guard let location = locations.first(where: { $0.id == id }) else { throw USGSDataError.locationNotFound }
        return location
        
    }
    
    enum USGSDataError: String, LocalizedError {
        case notInLocations = "ILLEGAL STATE: You cannot request data for a location not in favorites (for now)"
        case locationNotFound = "The specified location was not found in the returned data"
        
        var errorDescription: String? {
            return self.rawValue
        }
    }
    
    func saveLocs() {
        let enc = JSONEncoder()
        let data = try? enc.encode(self.favoriteLocations)
        Self.data?.set(data, forKey: Self.favoritesKey)
    }
    
    func getLocs() -> [String]? {
        guard let data = Self.data?.value(forKey: Self.favoritesKey) as? Data else {
            return nil
        }
        let dec = JSONDecoder()
        return try? dec.decode([String].self, from: data)
    }
    
    func saveDict() {
        let enc = JSONEncoder()
        let data = try? enc.encode(self.locationData)
        Self.data?.set(data, forKey: Self.cacheKey)
        
        WidgetCenter.shared.reloadTimelines(ofKind: "USGS_Widget")
    }
    
    func getDict() -> [String: Location]? {
        guard let data = Self.data?.value(forKey: Self.cacheKey) as? Data else {
            return nil
        }
        let dec = JSONDecoder()
        return try? dec.decode([String: Location].self, from: data)
    }
    
}
