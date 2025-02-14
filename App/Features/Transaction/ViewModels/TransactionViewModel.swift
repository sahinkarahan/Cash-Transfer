import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class TransactionViewModel: ObservableObject {
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
    
    func withdraw(amount: Double, currency: Currency) async {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        isLoading = true
        
        do {
            let currentBalance = currency == .TL ? balanceTL : balanceUSD
            if amount > currentBalance {
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Insufficient funds"])
            }
            
            let newBalance = currentBalance - amount
            let transaction = Transaction(
                id: UUID().uuidString,
                type: .withdraw,
                amount: amount,
                currency: currency,
                date: Date(),
                senderID: userID,
                receiverID: nil,
                status: .completed,
                message: nil
            )
            
            try await db.collection("users").document(userID).updateData([
                "bankAccount.\(currency == .TL ? "balanceTL" : "balanceUSD")": newBalance,
                "bankAccount.transactions": FieldValue.arrayUnion([try transaction.asDictionary()])
            ])
            
            if currency == .TL {
                balanceTL = newBalance
            } else {
                balanceUSD = newBalance
            }
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func deposit(amount: Double, currency: Currency) async {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        isLoading = true
        
        do {
            let currentBalance = currency == .TL ? balanceTL : balanceUSD
            let newBalance = currentBalance + amount
            let transaction = Transaction(
                id: UUID().uuidString,
                type: .deposit,
                amount: amount,
                currency: currency,
                date: Date(),
                senderID: nil,
                receiverID: userID,
                status: .completed,
                message: nil
            )
            
            try await db.collection("users").document(userID).updateData([
                "bankAccount.\(currency == .TL ? "balanceTL" : "balanceUSD")": newBalance,
                "bankAccount.transactions": FieldValue.arrayUnion([try transaction.asDictionary()])
            ])
            
            if currency == .TL {
                balanceTL = newBalance
            } else {
                balanceUSD = newBalance
            }
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
}

extension Encodable {
    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode"])
        }
        return dictionary
    }
} 