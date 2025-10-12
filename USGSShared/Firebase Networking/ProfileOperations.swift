//
//  ProfileOperations.swift
//  USGS
//
//  Created by Jonathan Melitski on 10/6/25.
//
import Combine
import FirebaseFunctions

public extension StreamsideFirebase {
    static func getProfile() async throws -> Profile {
        let res = try await functions.httpsCallable("get_or_create_profile").call()
        
        guard let dict = res.data as? [String: Any?] else { throw FirebaseError.noData }
        let data = try JSONSerialization.data(withJSONObject: dict)
        
        let dec = JSONDecoder()
        dec.keyDecodingStrategy = .convertFromSnakeCase
        
        return try dec.decode(Profile.self, from: data)
    }

    static private var lastProfileUpdate: Date? = nil
    static private var scheduledUpdateTask: (any Cancellable)? = nil
    
    static let bufferTime: TimeInterval = 5
    
    static var functions = Functions.functions()
    
    static func saveProfile(_ profile: Profile) async throws {
        let timeSinceLastUpdate = abs(lastProfileUpdate?.timeIntervalSinceNow ?? .infinity)
        if timeSinceLastUpdate < bufferTime {
            print("hit buffer")
            scheduledUpdateTask?.cancel()
            scheduledUpdateTask = DispatchQueue.global(qos: .utility).schedule(after: .init(.now().advanced(by: .milliseconds(Int(Double(1000) * (bufferTime - timeSinceLastUpdate))))), interval: .zero) {
                print("network saved")
                lastProfileUpdate = Date.now
                scheduledUpdateTask?.cancel()
                self.scheduledUpdateTask = nil
                Task {
                    try await updateProfile(profile)
                }
            }
        } else {
            print("no buffer needed save")
            lastProfileUpdate = Date.now
            Task {
                try await updateProfile(profile)
            }
        }
    }
    
    private static func updateProfile(_ profile: Profile) async throws {
        guard let dict = profile.dictionary else { return }
        let res = try await functions.httpsCallable("update_profile").call(dict)
        print("Updated Firebase")
    }
}
