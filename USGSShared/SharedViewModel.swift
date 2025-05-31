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
    @Published public private(set) var usgsData: [String : USGSData?] = [:]
    @Published public var selectedTab: SharedViewModel.Tab = .conditions
    @Published public var selectedLocation: String? = nil
    
    
    init() {
        let locs = (UserDefaults.standard.array(forKey: Self.favoritesKey) as? [String]) ?? []
        self.favoriteLocations = locs
        
        if let first = self.favoriteLocations.first {
            selectedTab = .locations
        }
    }
    
    public func addFavoriteLocation(_ id: String) {
        self.favoriteLocations.append(id)
        UserDefaults.standard.set(favoriteLocations, forKey: Self.favoritesKey)
        Task { @MainActor in
            let data = try? await NetworkManager.shared.getUSGSData(for: id)
            usgsData.updateValue(data, forKey: id)
            self.saveDict()
        }
        
        
    }
    
    public func removeFavoriteLocation(_ id: String) {
        self.favoriteLocations.removeAll(where: { $0 == id })
        self.usgsData.removeValue(forKey: id)
        self.saveDict()
        UserDefaults.standard.set(favoriteLocations, forKey: Self.favoritesKey)
    }
    
    public enum Tab {
        case conditions, settings, locations
    }
    
    @MainActor public func refreshData() async {
        let dict = (self.getDict() ?? [:]).filter({ el in
            self.favoriteLocations.contains(where: { $0 == el.key })
        })
        self.usgsData = dict
        self.saveDict()
        let keys = self.usgsData.keys
        self.usgsData = await withTaskGroup(of: (String, USGSData?).self, returning: [String : USGSData?].self) { group in
            keys.forEach { key in
                group.addTask {
                    return (key, try? await NetworkManager.shared.getUSGSData(for: key))
                }
            }
            
            var finalDict: [String: USGSData?] = [:]
            for await result in group {
                finalDict.updateValue(result.1, forKey: result.0)
            }
            return finalDict
        }
    }
    
    @discardableResult
    @MainActor public func fetchLocationData(_ id: String) async throws -> USGSData {
        guard self.favoriteLocations.contains(where: { $0 == id }) else {
            throw USGSDataError.notInLocations
        }
        
        let data = try await NetworkManager.shared.getUSGSData(for: id)
        self.usgsData.updateValue(data, forKey: id)
        self.saveDict()
        return data
        
    }
    
    enum USGSDataError: String, LocalizedError {
        case notInLocations = "ILLEGAL STATE: You cannot request data for a location not in favorites (for now)"
        
        var errorDescription: String? {
            return self.rawValue
        }
    }
    
    func saveDict() {
        let enc = JSONEncoder()
        let data = try? enc.encode(self.usgsData)
        UserDefaults.standard.set(data, forKey: Self.cacheKey)
        UserDefaults.standard.synchronize()
    }
    
    func getDict() -> [String: USGSData?]? {
        guard let data = UserDefaults.standard.value(forKey: Self.cacheKey) as? Data else {
            return nil
        }
        let dec = JSONDecoder()
        return try? dec.decode([String: USGSData?].self, from: data)
    }
    
}
