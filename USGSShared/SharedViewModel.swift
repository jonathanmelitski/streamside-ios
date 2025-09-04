//
//  SharedViewModel.swift
//  USGS
//
//  Created by Jonathan Melitski on 5/27/25.
//

import Foundation
import Combine

public class SharedViewModel: ObservableObject {
    public static var shared = SharedViewModel()
    
    static let favoritesKey = "USGSApp-Favorites"
    static let cacheKey = "USGSApp-Data"
    
    @Published public private(set) var favoriteLocations: [String] = []
    @Published public private(set) var locationData: [String : Location] = [:]
    @Published public var selectedTab: SharedViewModel.Tab = .conditions
    @Published public var selectedLocation: String? = nil
    
    static let data = UserDefaults(suiteName: "group.com.jmelitski.USGS")
    
    
    init() {
        let locs = self.getLocs() ?? []
        let dict = self.getDict() ?? [:]
        self.favoriteLocations = locs
        self.locationData = dict
        
        if let first = self.favoriteLocations.first {
            selectedTab = .locations
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
    
    public enum Tab {
        case conditions, settings, locations
    }
    
    @MainActor public func refreshData() async {
        let dict = (self.getDict() ?? [:]).filter({ el in
            self.favoriteLocations.contains(where: { $0 == el.key })
        })
        self.locationData = dict
        self.saveDict()
        let keys = self.locationData.keys
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
    }
    
    @discardableResult
    @MainActor public func fetchLocationData(_ id: String) async throws -> Location {
        guard self.favoriteLocations.contains(where: { $0 == id }) else {
            throw USGSDataError.notInLocations
        }
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
        Self.data?.synchronize()
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
        Self.data?.synchronize()
    }
    
    func getDict() -> [String: Location]? {
        guard let data = Self.data?.value(forKey: Self.cacheKey) as? Data else {
            return nil
        }
        let dec = JSONDecoder()
        return try? dec.decode([String: Location].self, from: data)
    }
    
}
