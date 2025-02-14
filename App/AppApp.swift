//
//  AppApp.swift
//  App
//
//  Created by Şahin Karahan on 28.01.2025.
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
struct AppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var appState = AppState.shared
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .onReceive(NotificationCenter.default.publisher(for: .userLoggedOut)) { _ in
                    withAnimation(.spring(duration: 0.3)) {
                        appState.isAuthenticated = false
                        appState.showOnboarding = true
                    }
                }
        }
    }
}
