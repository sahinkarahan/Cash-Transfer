import Foundation
import SwiftUI
import FirebaseAuth
import Combine
import FirebaseFirestore

@MainActor
final class AppState: ObservableObject {
    @Published var isAuthenticated = false {
        didSet {
            UserDefaults.standard.set(isAuthenticated, forKey: "isAuthenticated")
        }
    }
    @Published var showOnboarding = false
    @Published var isConnected = true
    
    static let shared = AppState()
    private var cancellables = Set<AnyCancellable>()
    private let networkMonitor = NetworkMonitor.shared
    
    init() {
        setupNetworkMonitoring()
        checkAuthenticationState()
    }
    
    private func setupNetworkMonitoring() {
        // NetworkMonitor'u main thread'de dinle
        Task { @MainActor in
            networkMonitor.$isConnected
                .receive(on: DispatchQueue.main)
                .sink { [weak self] isConnected in
                    self?.handleConnectionChange(isConnected)
                }
                .store(in: &cancellables)
        }
    }
    
    private func handleConnectionChange(_ isConnected: Bool) {
        // Bağlantı değişikliklerini burada yönet
        if !isConnected {
            // Bağlantı koptuğunda yapılacak işlemler
            NotificationCenter.default.post(name: .networkStatusChanged, object: nil, userInfo: ["isConnected": false])
        } else {
            // Bağlantı geldiğinde yapılacak işlemler
            NotificationCenter.default.post(name: .networkStatusChanged, object: nil, userInfo: ["isConnected": true])
        }
    }
    
    private func checkAuthenticationState() {
        if Auth.auth().currentUser == nil {
            showOnboarding = true
        }
    }
    
    func navigateToHome() {
        showOnboarding = false
        isAuthenticated = true
    }
    
    func navigateToOnboarding() {
        showOnboarding = true
        isAuthenticated = false
    }
    
    func logout() {
        showOnboarding = true
        isAuthenticated = false
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            showOnboarding = true
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
    func refreshData() async {
        // Bağlantı geri geldiğinde yapılacak veri yenileme işlemleri
        if let userId = Auth.auth().currentUser?.uid {
            do {
                let document = try await Firestore.firestore().collection("users").document(userId).getDocument()
                if document.exists {
                    isAuthenticated = true
                    showOnboarding = false
                } else {
                    isAuthenticated = false
                    showOnboarding = true
                }
            } catch {
                print("Error refreshing data: \(error.localizedDescription)")
            }
        }
    }
}

// Notification isimlerini extension olarak tanımla
extension Notification.Name {
    static let networkStatusChanged = Notification.Name("networkStatusChanged")
} 