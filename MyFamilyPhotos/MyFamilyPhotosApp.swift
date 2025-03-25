//
//  MyFamilyPhotosApp.swift
//  MyFamilyPhotos
//
//  Created by Larry Shannon on 3/13/25.
//

import SwiftUI

@main
struct MyFamilyPhotosApp: App {
    @StateObject var appNavigationState = AppNavigationState()
    @StateObject var firebaseService = FirebaseService.shared
    @StateObject var settingsService = SettingsService.shared
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appNavigationState)
                .environmentObject(firebaseService)
                .environmentObject(settingsService)
                .configureFirebaseSignInWithAppleWith(firestoreUserCollectionPath: Path.Firestore.profiles)
        }
    }
}
