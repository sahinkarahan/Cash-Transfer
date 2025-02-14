import Foundation
import RegexBuilder
import Combine
import SwiftUI

@MainActor
final class RegistrationViewModel: ObservableObject {
    @Published var phoneNumber = ""
    @Published var fullName = ""
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    
    @Published private(set) var validationStates = [false, false, false, false, false]
    @Published private(set) var validationMessages = [
        "Phone number must start with 0 and be 11 digits",
        "Full name must contain at least two words with minimum 2 letters each",
        "Please enter a valid email address (e.g., name@gmail.com)",
        "Password must be at least 8 characters and include uppercase, lowercase, number, and symbol",
        "Passwords must match"
    ]
    
    @Published private(set) var validationProgress: Int = 0
    
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var isRegistered = false
    @Published var isLoading = false
    @Published var showErrorOverlay = false
    
    private var cancellables = Set<AnyCancellable>()
    
    private let authService: AuthenticationServiceProtocol
    
    init(authService: AuthenticationServiceProtocol = AuthenticationService()) {
        self.authService = authService
        setupValidation()
    }
    
    var isFormValid: Bool {
        validationStates.allSatisfy { $0 }
    }
    
    private func updateValidationProgress() {
        validationProgress = validationStates.filter { $0 }.count
    }
    
    private func setupValidation() {
        // Phone Number Validation
        $phoneNumber
            .map { phone -> Bool in
                phone.count == 11 && phone.hasPrefix("0") && phone.allSatisfy { $0.isNumber }
            }
            .sink { [weak self] isValid in
                self?.validationStates[0] = isValid
                self?.updateValidationProgress()
            }
            .store(in: &cancellables)
        
        // Full Name Validation
        $fullName
            .map { name -> Bool in
                let components = name.trimmingCharacters(in: .whitespaces)
                    .components(separatedBy: .whitespaces)
                    .filter { !$0.isEmpty }
                
                // En az 2 kelime olmalı
                guard components.count >= 2 else { return false }
                
                // Her kelime en az 2 harf içermeli
                return components.allSatisfy { word in
                    let letters = word.filter { $0.isLetter }
                    return letters.count >= 2
                }
            }
            .sink { [weak self] isValid in
                self?.validationStates[1] = isValid
                self?.updateValidationProgress()
            }
            .store(in: &cancellables)
        
        // Email Validation
        $email
            .map { email -> Bool in
                // 1. Genel email formatı kontrolü
                let emailRegex = /^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/
                guard email.matches(of: emailRegex).count == 1 else { return false }
                
                // 2. Domain kontrolü
                let validDomains = ["gmail.com", "hotmail.com", "yahoo.com", "outlook.com", "icloud.com"]
                let domain = email.split(separator: "@").last?.lowercased() ?? ""
                guard validDomains.contains(String(domain)) else { return false }
                
                // 3. Ek kontroller
                let localPart = email.split(separator: "@").first ?? ""
                
                // Local part en az 3 karakter olmalı
                guard localPart.count >= 3 else { return false }
                
                // Ardışık nokta olmamalı
                guard !email.contains("..") else { return false }
                
                // Başında veya sonunda nokta olmamalı
                guard !localPart.hasPrefix(".") && !localPart.hasSuffix(".") else { return false }
                
                return true
            }
            .sink { [weak self] isValid in
                self?.validationStates[2] = isValid
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
                let isValid = password.count >= 8 && hasUppercase && hasLowercase && hasNumber && hasSymbol
                return isValid
            }
            .sink { [weak self] isValid in
                self?.validationStates[3] = isValid
                self?.updateValidationProgress()
            }
            .store(in: &cancellables)
        
        // Confirm Password Validation
        Publishers.CombineLatest($password, $confirmPassword)
            .map { password, confirmPassword -> Bool in
                // Şifre boş olmamalı ve şifreler eşleşmeli
                let passwordsMatch = !password.isEmpty && password == confirmPassword
                
                // Ana şifre validasyonları
                let hasUppercase = password.contains(where: { $0.isUppercase })
                let hasLowercase = password.contains(where: { $0.isLowercase })
                let hasNumber = password.contains(where: { $0.isNumber })
                let hasSymbol = password.contains(where: { "!@#$%^&*(),.?\":{}|<>".contains($0) })
                let isPasswordValid = password.count >= 8 && hasUppercase && hasLowercase && hasNumber && hasSymbol
                
                // Her iki koşul da sağlanmalı
                return passwordsMatch && isPasswordValid
            }
            .sink { [weak self] isValid in
                self?.validationStates[4] = isValid
                self?.updateValidationProgress()
            }
            .store(in: &cancellables)
    }
    
    func register() {
        Task {
            isLoading = true
            do {
                let result = try await authService.createUser(email: email, password: password)
                try await (authService as? AuthenticationService)?.saveUserData(
                    userId: result.user.uid,
                    phoneNumber: phoneNumber,
                    fullName: fullName,
                    email: email
                )
                isRegistered = true
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
