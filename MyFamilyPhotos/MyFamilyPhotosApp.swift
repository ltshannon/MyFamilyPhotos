//
//  MyFamilyPhotosApp.swift
//  MyFamilyPhotos
//
//  Created by Larry Shannon on 3/13/25.
//

import SwiftUI

@main
struct MyFamilyPhotosApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .configureFirebaseSignInWithAppleWith(firestoreUserCollectionPath: Path.Firestore.profiles)
        }
    }
}
