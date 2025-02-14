//
//  ContentView.swift
//  App
//
//  Created by Şahin Karahan on 28.01.2025.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var networkMonitor = NetworkMonitor.shared
    
    var body: some View {
        ZStack {
            Group {
                if appState.showOnboarding {
                    OnboardingView()
                } else {
                    HomeView()
                }
            }
            .animation(.spring(duration: 0.3), value: appState.showOnboarding)
            
            if !networkMonitor.isConnected {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .transition(.opacity)
                
                NetworkErrorView()
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.spring(duration: 0.3), value: networkMonitor.isConnected)
        .onChange(of: networkMonitor.isConnected) { newValue in
            if newValue {
                // Bağlantı geldiğinde UI'ı güncelle
                Task {
                    await appState.refreshData()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
