import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import Photos
import PhotosUI
import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var userData: UserData?
    @Published var isLoading = false
    @Published var lastTransactions: [Transaction] = []
    
    var loadingTitle = "Loading"
    var loadingDescription = "Please wait..."
    
    private let authService: AuthenticationServiceProtocol
    private let storage = Storage.storage()
    private let db = Firestore.firestore()
    
    init(authService: AuthenticationServiceProtocol = AuthenticationService()) {
        self.authService = authService
        Task {
            await fetchUserData()
        }
    }
    
    func signOut() async {
        do {
            try authService.signOut()
        } catch {
            showError = true
            errorMessage = error.localizedDescription
        }
    }
    
    func fetchUserData() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        isLoading = true
        
        do {
            let document = try await db.collection("users").document(userId).getDocument()
            
            guard let data = document.data() else {
                showError = true
                errorMessage = "User data not found"
                return
            }
            
            let timestamp = data["createdAt"] as? Timestamp ?? Timestamp()
            
            let bankAccountData = data["bankAccount"] as? [String: Any] ?? [:]
            let bankAccount = BankAccount(
                balanceTL: bankAccountData["balanceTL"] as? Double ?? 0.0,
                balanceUSD: bankAccountData["balanceUSD"] as? Double ?? 0.0,
                transactions: []
            )
            
            userData = UserData(
                fullName: data["fullName"] as? String ?? "",
                email: data["email"] as? String ?? "",
                phoneNumber: data["phoneNumber"] as? String ?? "",
                idCash: data["idCash"] as? String ?? "",
                iban: data["iban"] as? String ?? "",
                profilePhotoData: data["profilePhotoData"] as? String,
                createdAt: timestamp.dateValue(),
                bankAccount: bankAccount
            )
            
            if let transactionsData = bankAccountData["transactions"] as? [[String: Any]] {
                self.lastTransactions = transactionsData.compactMap { transactionData in
                    guard let id = transactionData["id"] as? String,
                          let type = transactionData["type"] as? String,
                          let amount = transactionData["amount"] as? Double,
                          let currency = transactionData["currency"] as? String,
                          let timestamp = transactionData["date"] as? TimeInterval,
                          let status = transactionData["status"] as? String else {
                        return nil
                    }
                    
                    let currentDate = Date(timeIntervalSince1970: timestamp)
                    let calendar = Calendar.current
                    var dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: currentDate)
                    dateComponents.year = 2025
                    let adjustedDate = calendar.date(from: dateComponents) ?? currentDate
                    
                    return Transaction(
                        id: id,
                        type: TransactionType(rawValue: type) ?? .send,
                        amount: amount,
                        currency: Currency(rawValue: currency) ?? .TL,
                        date: adjustedDate,
                        senderID: transactionData["senderID"] as? String,
                        receiverID: transactionData["receiverID"] as? String,
                        status: TransactionStatus(rawValue: status) ?? .completed,
                        message: transactionData["message"] as? String
                    )
                }
                .sorted { $0.date > $1.date }
            }
        } catch {
            showError = true
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func updateProfilePhoto(with item: PhotosPickerItem) async {
        guard NetworkMonitor.shared.isConnected else {
            showError = true
            errorMessage = "No internet connection. Please check your connection and try again."
            return
        }
        
        do {
            guard let imageData = try await item.loadTransferable(type: Data.self),
                  let userId = Auth.auth().currentUser?.uid else {
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to load image data"])
            }
            
            let maxSize: Int64 = 500 * 1024 // 500KB
            let compressedData = await compressImageIfNeeded(imageData, maxSize: maxSize)
            
            isLoading = true
            loadingTitle = "Uploading photo"
            loadingDescription = "Please wait while we upload your photo"
            
            let base64String = compressedData.base64EncodedString()
            
            try await db.collection("users").document(userId).updateData([
                "profilePhotoData": base64String,
                "lastPhotoUpdate": FieldValue.serverTimestamp()
            ])
            
            URLCache.shared.removeAllCachedResponses()
            
            await fetchUserData()
            NotificationCenter.default.post(name: .profilePhotoUpdated, object: nil)
            
        } catch {
            showError = true
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    private func compressImageIfNeeded(_ data: Data, maxSize: Int64) async -> Data {
        guard data.count > maxSize else { return data }
        
        var compression: CGFloat = 0.8 // Başlangıç compression değeri düşürüldü
        var compressedData = data
        
        while compressedData.count > maxSize && compression > 0.1 {
            compression -= 0.1
            if let image = UIImage(data: data),
               let newData = await image.jpegData(compressionQuality: compression) {
                compressedData = newData
            }
        }
        
        return compressedData
    }
    
    func removeProfilePhoto() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        isLoading = true
        loadingTitle = "Removing photo"
        loadingDescription = "Please wait while we remove your photo"
        
        do {
            try await db.collection("users").document(userId).updateData([
                "profilePhotoData": FieldValue.delete()
            ])
            
            await fetchUserData()
            NotificationCenter.default.post(name: .profilePhotoUpdated, object: nil)
        } catch {
            showError = true
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
} 
