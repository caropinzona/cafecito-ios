//
//  cafecito_iOSApp.swift
//  cafecito-iOS
//
//  Created by Caro Pinzon on 11/24/25.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    // Check if GoogleService-Info.plist exists to avoid crash during development if missing
    if Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil {
        FirebaseApp.configure()
    } else {
        print("⚠️ Warning: GoogleService-Info.plist not found. Firebase not configured.")
    }
    return true
  }
}

@main
struct cafecito_iOSApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
