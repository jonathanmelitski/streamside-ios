//
//  ProfileOperations.swift
//  USGS
//
//  Created by Jonathan Melitski on 10/6/25.
//
import Combine

public extension StreamsideFirebase {
    static func getProfile() async throws -> Profile {
        //return .init(id: "asdf", gauges: [], markers: [])
        throw NSError(domain: "Profile", code: -1)
    }

    static private var lastProfileUpdate: Date? = nil
    static private var scheduledUpdateTask: (any Cancellable)? = nil
    
    static let bufferTime: TimeInterval = 5
    
    static func saveProfile(_ profile: Profile) async throws {
        let data = try JSONEncoder().encode(profile)
        SharedViewModel.data?.set(data, forKey: SharedViewModel.profileKey)
        let timeSinceLastUpdate = abs(lastProfileUpdate?.timeIntervalSinceNow ?? .infinity)
        if timeSinceLastUpdate < bufferTime {
            scheduledUpdateTask?.cancel()
            scheduledUpdateTask = DispatchQueue.global(qos: .utility).schedule(after: .init(.now().advanced(by: .milliseconds(Int(Double(1000) * (bufferTime - timeSinceLastUpdate))))), interval: .zero) {
                print("network saved")
                lastProfileUpdate = Date.now
                scheduledUpdateTask?.cancel()
                self.scheduledUpdateTask = nil
            }
        } else {
            print("no buffer needed save")
            lastProfileUpdate = Date.now
        }
    }
}
