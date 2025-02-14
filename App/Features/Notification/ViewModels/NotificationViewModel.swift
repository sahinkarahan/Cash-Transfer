import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class NotificationViewModel: ObservableObject {
    @Published var notifications: [NotificationModel] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var unreadCount: Int = 0
    
    private let db = Firestore.firestore()
    
    private static var shared: NotificationViewModel?
    
    init() {
        Self.shared = self
        Task {
            await fetchNotifications()
            setupNotificationListener()
        }
    }
    
    private func setupNotificationListener() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(userID)
            .collection("notifications")
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    self?.error = error.localizedDescription
                    return
                }
                
                Task {
                    await self?.fetchNotifications()
                }
            }
    }
    
    func fetchNotifications() async {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        isLoading = true
        
        do {
            let snapshot = try await db.collection("users").document(userID)
                .collection("notifications")
                .order(by: "date", descending: true)
                .getDocuments()
            
            self.notifications = snapshot.documents.compactMap { document in
                NotificationModel(dictionary: document.data(), id: document.documentID)
            }
            
            self.unreadCount = notifications.filter { !$0.isRead }.count
            
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func markAllAsRead() async {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        do {
            let batch = db.batch()
            let notificationsRef = db.collection("users").document(userID)
                .collection("notifications")
            
            let unreadDocs = try await notificationsRef
                .whereField("isRead", isEqualTo: false)
                .getDocuments()
            
            for doc in unreadDocs.documents {
                batch.updateData(["isRead": true], forDocument: doc.reference)
            }
            
            try await batch.commit()
            self.unreadCount = 0
            await fetchNotifications()
            
            if let shared = Self.shared, shared !== self {
                shared.unreadCount = 0
                await shared.fetchNotifications()
            }
            
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    func deleteAllNotifications() async {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        do {
            let batch = db.batch()
            let notificationsRef = db.collection("users").document(userID)
                .collection("notifications")
            
            let docs = try await notificationsRef.getDocuments()
            
            for doc in docs.documents {
                batch.deleteDocument(doc.reference)
            }
            
            try await batch.commit()
            self.notifications = []
            self.unreadCount = 0
            
            if let shared = Self.shared, shared !== self {
                shared.unreadCount = 0
                await shared.fetchNotifications()
            }
            
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    var unreadNotifications: [NotificationModel] {
        notifications.filter { !$0.isRead }
    }
    
    var readNotifications: [NotificationModel] {
        notifications.filter { $0.isRead }
    }
} 