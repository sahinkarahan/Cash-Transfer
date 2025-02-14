import Foundation
import Combine
import SwiftUI

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published private(set) var isFormValid = false
    @Published private(set) var validationStates = [false, false]
    @Published private(set) var validationMessages = [
        "Please enter a valid email address (e.g., name@gmail.com)",
        "Password must be at least 8 characters and include uppercase, lowercase, number, and symbol"
    ]
    @Published private(set) var validationProgress: Int = 0
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var isLoggedIn = false
    @Published var isLoading = false
    @Published var showErrorOverlay = false
    
    private var cancellables = Set<AnyCancellable>()
    
    private let authService: AuthenticationServiceProtocol
    
    init(authService: AuthenticationServiceProtocol = AuthenticationService()) {
        self.authService = authService
        setupValidation()
    }
    
    private func updateValidationProgress() {
        validationProgress = validationStates.filter { $0 }.count
    }
    
    private func setupValidation() {
        // Email Validation
        $email
            .map { email -> Bool in
                let emailRegex = /^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/
                guard email.matches(of: emailRegex).count == 1 else { return false }
                
                let validDomains = ["gmail.com", "hotmail.com", "yahoo.com", "outlook.com", "icloud.com"]
                let domain = email.split(separator: "@").last?.lowercased() ?? ""
                return validDomains.contains(String(domain))
            }
            .sink { [weak self] isValid in
                self?.validationStates[0] = isValid
                self?.updateValidationProgress()
            }
            .store(in: &cancellables)
        
        // Password Validation
        $password
            .map { password -> Bool in
                let hasUppercase = password.contains(where: { $0.isUppercase })
                let hasLowercase = password.contains(where: { $0.isLowercase })
                let hasNumber = password.contains(where: { $0.isNumber })
                let hasSymbol = password.contains(where: { "!@#$%^&*(),.?\":{}|<>".contains($0) })
                return password.count >= 8 && hasUppercase && hasLowercase && hasNumber && hasSymbol
            }
            .sink { [weak self] isValid in
                self?.validationStates[1] = isValid
                self?.updateValidationProgress()
                self?.isFormValid = self?.validationStates.allSatisfy { $0 } ?? false
            }
            .store(in: &cancellables)
    }
    
    func login() {
        Task {
            isLoading = true
            do {
                _ = try await authService.signIn(email: email, password: password)
                isLoading = false
                isLoggedIn = true
                AppState.shared.navigateToHome()
            } catch {
                isLoading = false
                errorMessage = error.localizedDescription
                showErrorOverlay = true
                
                // 3 saniye sonra error overlay'i kaldır
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation(.spring(duration: 0.3)) {
                        self.showErrorOverlay = false
                    }
                }
            }
        }
    }
} 