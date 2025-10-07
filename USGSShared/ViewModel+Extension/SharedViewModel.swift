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
internal import FirebaseDatabase
internal import FirebaseAuth

public class SharedViewModel: ObservableObject {
    public static var shared = SharedViewModel()
    
    static let favoritesKey = "USGSApp-Favorites"
    static let widgetPreferenceKey = "USGSApp-WidgetPreference"
    static let cacheKey = "USGSApp-Data"
    static let coordinatesStorageKey = "USGSApp-Coordinates"
    static let authenticationCredentialKey = "USGSApp-AuthenticationCredential"
    static let profileKey = "USGSApp-Profile"

    @Published public var selectedTab: SharedViewModel.Tab = .conditions
    @Published public var nav: NavigationPath = .init()
    @Published public var allLocations: [BasicLocation] = []
    @Published public var widgetPreferredLocation: String?
    
    @Published public var currentProfile: Profile? = nil
    
    @Published public var awaitingVerificationCodeContinuation: (CheckedContinuation<String, Never>)? = nil
    
    static let data = UserDefaults(suiteName: "group.com.jmelitski.USGS")
    var profileUpdater: (any Cancellable)? = nil
    
    init() {
        resetState()
        handleProfile()
        profileUpdater = $currentProfile.sink { newProfile in
            let data = (try? JSONEncoder().encode(newProfile)) ?? Data()
            Self.data?.set(data, forKey: Self.profileKey)
            if let newProfile, newProfile.isSufficientlyDifferentFrom(otherProfile: self.currentProfile) {
                DispatchQueue.global(qos: .utility).async {
                    Task {
                        try? await StreamsideFirebase.saveProfile(newProfile)
                    }
                }
            }
            WidgetCenter.shared.reloadTimelines(ofKind: "USGS_Widget")
        }
    }
    
    func handleProfile() {
        self.currentProfile = try? JSONDecoder().decode(Profile.self, from: Self.data?.data(forKey: Self.profileKey) ?? Data())
        
        guard let id = Bundle.main.bundleIdentifier, !id.hasSuffix("Widget") else { return }
        if let user = Auth.auth().currentUser {
            Task {
                // not sure if I want silently fail here
                if let profile = try? await StreamsideFirebase.getProfile() {
                    DispatchQueue.main.sync {
                        self.currentProfile = profile
                    }
                }
            }
        }
    }
    
    public func requestNewSignIn(with phoneNumber: String) async throws {
        let user = try await self.newSignIn(phoneNumber: phoneNumber)
        let profile = try await StreamsideFirebase.getProfile()
        DispatchQueue.main.sync {
            self.currentProfile = profile
        }
    }
    
    public func resetState(completion: (() -> ())? = nil) {
        self.handleProfile()
        self.widgetPreferredLocation = Self.data?.string(forKey: Self.widgetPreferenceKey)
        
        Task { @MainActor in
            await self.refreshData()
            completion?()
        }
    }
    
    public func addFavoriteLocation(_ location: Location) {
        self.currentProfile?.gauges.append(location)
    }
    
    public func removeFavoriteLocation(_ id: String) {
        self.currentProfile?.gauges.removeAll(where: { $0.id == id })
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
    
    public enum Tab {
        case conditions, maps, fish, trips
    }
    
    @MainActor public func refreshData() async {
        let keys = (self.currentProfile?.gauges ?? []).flatMap({ $0.id })
        
//        self.locationData = await withTaskGroup(of: (String, Location?).self, returning: [String : Location].self) { group in
//            keys.forEach { key in
//                group.addTask {
//                    return (key, try? await self.fetchLocationData(key))
//                }
//            }
//            
//            var finalDict: [String: Location] = [:]
//            for await result in group {
//                if let loc = result.1 {
//                    finalDict.updateValue(loc, forKey: result.0)
//                }
//            }
//            return finalDict
//        }
//        self.saveDict()
    }
    
    @discardableResult
    @MainActor public func fetchLocationData(_ id: String) async throws -> Location {
        let data = try await NetworkManager.shared.getUSGSData(for: id)
        let locations = Location.getArray(from: data)
        guard let location = locations.first(where: { $0.id == id }) else { throw USGSDataError.locationNotFound }
        return location
        
    }
    
    func newSignIn(phoneNumber: String) async throws -> User {
        Auth.auth().settings?.isAppVerificationDisabledForTesting = true
        let token: String = try await withCheckedThrowingContinuation { continuation in
            PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber) { vID, err in
                if let err {
                    continuation.resume(throwing: err)
                    return
                }
                
                guard let vID else {
                    continuation.resume(throwing: AuthError.unableToFetchVID)
                    return
                }
                continuation.resume(returning: vID)
            }
        }
        
        let code: String = await withCheckedContinuation { continuation in
            DispatchQueue.main.sync {
                self.awaitingVerificationCodeContinuation = continuation
            }
        }
        DispatchQueue.main.sync {
            self.awaitingVerificationCodeContinuation = nil
        }
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: token, verificationCode: code)
        return (try await Auth.auth().signIn(with: credential)).user
    }
    
    enum AuthError: Error {
        case unableToFetchVID
    }
    
    enum USGSDataError: String, LocalizedError {
        case notInLocations = "ILLEGAL STATE: You cannot request data for a location not in favorites (for now)"
        case locationNotFound = "The specified location was not found in the returned data"
        
        var errorDescription: String? {
            return self.rawValue
        }
    }
    
}
