//
//  USGSApp.swift
//  USGS
//
//  Created by Jonathan Melitski on 5/26/25.
//

import SwiftUI
import FirebaseCore
import FirebaseFunctions


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct YourApp: App {
  // register app delegate for Firebase setup
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate


  var body: some Scene {
    WindowGroup {
        ContentView()
    }
  }
}
