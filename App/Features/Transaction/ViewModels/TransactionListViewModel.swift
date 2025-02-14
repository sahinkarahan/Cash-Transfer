import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class TransactionListViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private let db = Firestore.firestore()
    
    init() {
        Task {
            await fetchTransactions()
        }
    }
    
    func fetchTransactions() async {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        isLoading = true
        
        do {
            let doc = try await db.collection("users").document(userID).getDocument()
            
            guard let data = doc.data(),
                  let bankAccount = data["bankAccount"] as? [String: Any],
                  let transactionsData = bankAccount["transactions"] as? [[String: Any]] else {
                self.error = "No transactions found"
                isLoading = false
                return
            }
            
            self.transactions = transactionsData.compactMap { transactionData in
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
            
            if transactions.isEmpty {
                self.error = "No transactions found"
            }
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
} 