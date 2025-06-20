//
//  BabyBrunchApp.swift
//  BabyBrunch
//
//  Created by Kseniia on 2025-05-14.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        return true
    }
}

@main
struct BabyBrunchApp: App {
    @StateObject var authViewModel = AuthViewModel()
    @AppStorage("isDarkMode") private var isDarkMode = false
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var isActive = false
    @StateObject var soundVM = SoundViewModel()
    
    var body: some Scene {
        WindowGroup {
            if authViewModel.isLoggedIn {
                MainTabView()
                    .environmentObject(authViewModel)
                    .preferredColorScheme(isDarkMode ? .dark : .light)
                    .environmentObject(soundVM)
            } else {
                if authViewModel.isActive {
                    LoginView()
                        .environmentObject(soundVM)
                        .environmentObject(authViewModel)
                        .preferredColorScheme(isDarkMode ? .dark : .light)
                } else {
                    //I don't get why it needs vm here but not in AddReviewView, Guess I should check that later
                    SplashScreen(isActive: $authViewModel.isActive)
                        .environmentObject(soundVM)
                        .environmentObject(authViewModel)
                }
            }
        }
    }
}
