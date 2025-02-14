import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class SendMoneyViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var error: String?
    @Published private(set) var balanceTL: Double = 0.0
    @Published private(set) var balanceUSD: Double = 0.0
    
    private let db = Firestore.firestore()
    
    init() {
        Task {
            await fetchBalances()
        }
    }
    
    func fetchBalances() async {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        do {
            let doc = try await db.collection("users").document(userID).getDocument()
            if let data = doc.data(),
               let bankAccount = data["bankAccount"] as? [String: Any] {
                balanceTL = bankAccount["balanceTL"] as? Double ?? 0.0
                balanceUSD = bankAccount["balanceUSD"] as? Double ?? 0.0
            }
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    func sendMoney(to recipientID: String, amount: Double, currency: Currency, message: String? = nil) async -> Bool {
        guard let senderID = Auth.auth().currentUser?.uid else { return false }
        isLoading = true
        
        defer {
            isLoading = false
        }
        
        do {
            let batch = db.batch()
            let senderRef = db.collection("users").document(senderID)
            let recipientRef = db.collection("users").document(recipientID)
            
            // Sender'ın bakiyesini kontrol et ve güncelle
            let senderDoc = try await senderRef.getDocument()
            guard let senderData = senderDoc.data(),
                  let senderBankAccount = senderData["bankAccount"] as? [String: Any],
                  var senderBalance = senderBankAccount[currency == .TL ? "balanceTL" : "balanceUSD"] as? Double else {
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid sender account"])
            }
            
            if amount > senderBalance {
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Insufficient funds"])
            }
            
            // Recipient'ın bakiyesini güncelle
            let recipientDoc = try await recipientRef.getDocument()
            guard let recipientData = recipientDoc.data(),
                  let recipientBankAccount = recipientData["bankAccount"] as? [String: Any],
                  var recipientBalance = recipientBankAccount[currency == .TL ? "balanceTL" : "balanceUSD"] as? Double else {
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid recipient account"])
            }
            
            senderBalance -= amount
            recipientBalance += amount
            
            let transaction = Transaction(
                id: UUID().uuidString,
                type: .send,
                amount: amount,
                currency: currency,
                date: Date(),
                senderID: senderID,
                receiverID: recipientID,
                status: .completed,
                message: message
            )
            
            // Batch update
            batch.updateData([
                "bankAccount.\(currency == .TL ? "balanceTL" : "balanceUSD")": senderBalance,
                "bankAccount.transactions": FieldValue.arrayUnion([try transaction.asDictionary()])
            ], forDocument: senderRef)
            
            let receiveTransaction = Transaction(
                id: UUID().uuidString,
                type: .receive,
                amount: amount,
                currency: currency,
                date: Date(),
                senderID: senderID,
                receiverID: recipientID,
                status: .completed,
                message: message
            )
            
            batch.updateData([
                "bankAccount.\(currency == .TL ? "balanceTL" : "balanceUSD")": recipientBalance,
                "bankAccount.transactions": FieldValue.arrayUnion([try receiveTransaction.asDictionary()])
            ], forDocument: recipientRef)
            
            try await batch.commit()
            
            if currency == .TL {
                balanceTL = senderBalance
            } else {
                balanceUSD = senderBalance
            }
            
            await createNotification(for: recipientID, amount: amount, currency: currency)
            
            return true
        } catch {
            self.error = error.localizedDescription
            return false
        }
    }
    
    private func createNotification(for recipientID: String, amount: Double, currency: Currency) async {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        do {
            // Gönderen kullanıcının bilgilerini al
            let senderDoc = try await db.collection("users").document(currentUser.uid).getDocument()
            guard let senderData = senderDoc.data(),
                  let senderName = senderData["fullName"] as? String else {
                print("Error: Sender data not found")
                return
            }
            
            let notification = NotificationModel(
                title: "Money Received",
                message: "You have received \(currency == .TL ? "₺" : "$")\(String(format: "%.2f", amount))",
                date: Date(),
                isRead: false,
                senderName: senderName
            )
            
            try await db.collection("users")
                .document(recipientID)
                .collection("notifications")
                .document(notification.id)
                .setData(notification.dictionary)
        } catch {
            print("Error creating notification: \(error.localizedDescription)")
        }
    }
    
    struct RecipientData {
        let id: String
        let fullName: String
        let phone: String
    }
    
    func findUserByCashIDAndVerify(cashID: String, fullName: String, phone: String) async -> RecipientData? {
        do {
            let snapshot = try await db.collection("users")
                .whereField("idCash", isEqualTo: cashID)
                .getDocuments()
            
            guard let document = snapshot.documents.first,
                  let data = document.data() as [String: Any]?,
                  let docFullName = data["fullName"] as? String,
                  let docPhone = data["phoneNumber"] as? String else {
                self.error = "Recipient not found"
                return nil
            }
            
            // Tam eşleşme kontrolü
            if docFullName.lowercased() == fullName.lowercased() && 
               docPhone == phone {
                return RecipientData(id: document.documentID, fullName: docFullName, phone: docPhone)
            }
            
            self.error = "Recipient information does not match"
            return nil
        } catch {
            self.error = error.localizedDescription
            return nil
        }
    }
} 