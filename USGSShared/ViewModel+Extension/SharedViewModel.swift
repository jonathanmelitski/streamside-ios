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
    
    @Published public var awaitingVerificationCodeContinuation: VerificationCodeStatus = .inactive
    
    static let data = UserDefaults(suiteName: "group.com.jmelitski.USGS")
    var profileUpdater: (any Cancellable)? = nil
    
    init() {
        self.resetState {
            self.profileUpdater = self.$currentProfile.sink { newProfile in
                var new = newProfile
                new?.lastUpdated = (newProfile?.isSufficientlyDifferentFrom(otherProfile: self.currentProfile) ?? true) ? Date.now : self.currentProfile?.lastUpdated
                let data = (try? JSONEncoder().encode(new)) ?? Data()
                Self.data?.set(data, forKey: Self.profileKey)
                if let new, new.isSufficientlyDifferentFrom(otherProfile: self.currentProfile) {
                    DispatchQueue.global(qos: .utility).async {
                        Task {
                            try? await StreamsideFirebase.saveProfile(new)
                        }
                    }
                }
                WidgetCenter.shared.reloadTimelines(ofKind: "USGS_Widget")
            }
        }
    }
    
    @MainActor func handleProfile() async {
        let currentProfile = self.currentProfile
        
        guard let id = Bundle.main.bundleIdentifier, !id.hasSuffix("Widget") else { return }
        if let user = Auth.auth().currentUser {
            do {
                let profile = try await StreamsideFirebase.getProfile()
                guard profile.lastUpdated ?? .distantFuture > currentProfile?.lastUpdated ?? .distantPast else {
                    if let currentProfile {
                        try await StreamsideFirebase.saveProfile(currentProfile)
                    }
                    return
                }
                // ^^ weird shit happening with this
                // need to decide who saves what, too many conflictng UserDefaults actions here.
                
                self.currentProfile = profile
            } catch {
                print(error)
            }
        }
    }
    
    public func requestNewSignIn(with phoneNumber: String) async throws {
        let user = try await self.newSignIn(phoneNumber: phoneNumber)
        let profile = try await StreamsideFirebase.getProfile()
        DispatchQueue.main.async {
            self.currentProfile = profile
        }
    }
    
    @MainActor public func logOut() throws {
        // make sure we cancel any update tasks, otherwise we'll write nil to the server and delete someone's profile
        Self.data?.set(nil, forKey: Self.profileKey)
        try Auth.auth().signOut()
        withAnimation {
            self.currentProfile = nil
        }
    }
    
    public func resetState(completion: (() -> ())? = nil) {
        self.widgetPreferredLocation = Self.data?.string(forKey: Self.widgetPreferenceKey)
        self.currentProfile = try? JSONDecoder().decode(Profile.self, from: Self.data?.data(forKey: Self.profileKey) ?? Data())
        
        Task { @MainActor in
            await self.handleProfile()
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
        let locs = (self.currentProfile?.gauges ?? [])
        self.currentProfile?.gauges = await withTaskGroup(of: Location.self, returning: [Location].self) { group in
            locs.forEach { loc in
                group.addTask {
                    return ((try? await self.fetchLocationData(String(loc.id))) ?? loc)
                }
            }
            
            var results: [Location] = []
            for await result in group {
                results.append(result)
            }
            return results
        }
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
        
        var attempt = 1
        while true {
            let code: String = await withCheckedContinuation { continuation in
                DispatchQueue.main.async {
                    self.awaitingVerificationCodeContinuation = .awaiting(continuation: continuation, attempt: attempt)
                }
            }
            let credential = PhoneAuthProvider.provider().credential(withVerificationID: token, verificationCode: code)
            do {
                let user = (try await Auth.auth().signIn(with: credential)).user
                return user
            } catch AuthErrorCode.missingVerificationID {
                attempt += 1
            } catch AuthErrorCode.missingVerificationCode {
                attempt += 1
            } catch AuthErrorCode.invalidVerificationCode {
                attempt += 1
            } catch {
                Task { @MainActor in
                    withAnimation {
                        self.awaitingVerificationCodeContinuation = .error(error: error)
                    }
                }
            }
            
        }
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

public enum VerificationCodeStatus: Equatable {
    public static func == (lhs: VerificationCodeStatus, rhs: VerificationCodeStatus) -> Bool {
        switch lhs {
        case .awaiting(_, let att):
            if case .awaiting(_, let attR) = rhs {
                return att == attR
            }
        case .inactive:
            if case .inactive = rhs {
                return true
            }
        case .error(_):
        if case .error(_) = rhs {
            return true
        }
        }
        return false
    }
    
    case inactive
    case awaiting(continuation: CheckedContinuation<String,Never>, attempt: Int)
    case error(error: any Error)
}
