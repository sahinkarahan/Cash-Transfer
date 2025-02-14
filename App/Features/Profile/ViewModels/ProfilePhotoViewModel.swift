import SwiftUI
import PhotosUI
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth

@MainActor
final class ProfilePhotoViewModel: ObservableObject {
    @Published var showImagePicker = false
    @Published var imageSelection: PhotosPickerItem? {
        didSet { handleImageSelection() }
    }
    @Published var isLoading = false
    @Published var isCompleted = false
    @Published var userData: UserData?
    
    var loadingTitle = "Updating profile photo"
    var loadingDescription = "Please wait while we process your request"
    
    private let storage = Storage.storage()
    private let db = Firestore.firestore()
    
    init() {
        Task {
            await fetchUserData()
        }
    }
    
    private func handleImageSelection() {
        guard let imageSelection else { return }
        
        Task {
            do {
                guard let imageData = try await imageSelection.loadTransferable(type: Data.self),
                      let userId = Auth.auth().currentUser?.uid else { return }
                
                // Sıkıştırma işlemini önce yapalım
                let maxSize: Int64 = 500 * 1024 // 500KB
                let compressedData = await compressImageIfNeeded(imageData, maxSize: maxSize)
                
                // Şimdi yükleme başlıyor
                isLoading = true
                loadingTitle = "Uploading photo"
                loadingDescription = "Please wait while we upload your photo"
                
                // Base64'e çevir
                let base64String = compressedData.base64EncodedString()
                
                // Firestore'a kaydet
                try await db.collection("users").document(userId).updateData([
                    "profilePhotoData": base64String,
                    "lastPhotoUpdate": FieldValue.serverTimestamp()
                ])
                
                // Cache'i temizle ve userData'yı güncelle
                URLCache.shared.removeAllCachedResponses()
                await fetchUserData()
                
                isCompleted = true
                NotificationCenter.default.post(name: .profilePhotoUpdated, object: nil)
                
            } catch {
                print("Error: \(error.localizedDescription)")
            }
            
            isLoading = false
        }
    }
    
    // Görüntü sıkıştırma fonksiyonunu ekleyelim
    private func compressImageIfNeeded(_ data: Data, maxSize: Int64) async -> Data {
        guard data.count > maxSize else { return data }
        
        var compression: CGFloat = 0.8
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
            // Delete from Storage
            let storageRef = storage.reference().child("profile_photos/\(userId).jpg")
            try await storageRef.delete()
            
            // Update Firestore
            try await db.collection("users").document(userId).updateData([
                "profilePhotoURL": FieldValue.delete()
            ])
            
            isCompleted = true
        } catch {
            print("Error: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    func fetchUserData() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        do {
            let document = try await db.collection("users").document(userId).getDocument()
            guard let data = document.data() else { return }
            
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
        } catch {
            print("Error fetching user data: \(error.localizedDescription)")
        }
    }
} 
