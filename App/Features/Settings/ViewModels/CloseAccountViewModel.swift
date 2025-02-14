import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

@MainActor
final class CloseAccountViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var isCompleted = false
    
    var loadingTitle = "Deleting account"
    var loadingDescription = "Please wait while we process your request"
    
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    func deleteAccount() async {
        guard let user = auth.currentUser else { return }
        
        isLoading = true
        
        do {
            // 1. Delete profile photo from storage if exists
            let storageRef = storage.reference().child("profile_photos/\(user.uid).jpg")
            try? await storageRef.delete()
            
            // 2. Delete user data from Firestore
            try await db.collection("users").document(user.uid).delete()
            
            // 3. Delete Firebase Auth account
            try await user.delete()
            
            isCompleted = true
        } catch {
            print("Error: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
} 