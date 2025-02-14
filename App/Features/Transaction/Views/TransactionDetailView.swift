import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct TransactionDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let transaction: Transaction
    @State private var senderName: String = ""
    @State private var receiverName: String = ""
    @State private var currentUserName: String = ""
    @State private var senderCashID: String = ""
    @State private var receiverCashID: String = ""
    @State private var postTransactionBalance: Double = 0.0
    @State private var isLoading = true
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    colors: [Color(white: 0.15), Color(white: 0.12)],
                    startPoint: .top,
                    endPoint: .bottom
                ).ignoresSafeArea()
                
                if isLoading {
                    LoadingView()
                } else {
                    // Content
                    ScrollView {
                        VStack(spacing: 24) {
                                
                            // Date
                            Text(formattedDateTime)
                                .font(.subheadline)
                                .foregroundStyle(Color(white: 0.7))
                            
                            // Avatar Circle
                            Circle()
                                .fill(Color(white: 0.3))
                                .frame(width: 64, height: 64)
                                .overlay {
                                    Text(getInitials())
                                        .font(.title2.bold())
                                        .foregroundStyle(.white)
                                }
                            
                            // Name
                            Text(displayName)
                                .font(.title3.bold())
                                .foregroundStyle(.white)
                            
                            // Amount
                            Text(formattedAmount)
                                .font(.title.bold())
                                .foregroundStyle(amountColor)
                            
                            // Message (if exists)
                            if let message = transaction.message {
                                HStack(spacing: 4) {
                                    Image(systemName: "message.fill")
                                        .font(.caption2)
                                    Text(message)
                                        .font(.caption)
                                }
                                .foregroundStyle(Color(white: 0.6))
                            }
                            
                            // Action Buttons
                            HStack {
                                ForEach(actionButtons, id: \.self) { title in
                                    Spacer()
                                    VStack(spacing: 8) {
                                        Circle()
                                            .fill(.white)
                                            .frame(width: 48, height: 48)
                                            .overlay {
                                                Image(systemName: iconName(for: title))
                                                    .font(.title3)
                                                    .foregroundStyle(Color(white: 0.2))
                                            }
                                        Text(title)
                                            .font(.caption)
                                            .foregroundStyle(Color(white: 0.7))
                                            .fixedSize()
                                    }
                                    .frame(maxWidth: UIScreen.main.bounds.width / CGFloat(actionButtons.count) - 20)
                                    Spacer()
                                }
                            }
                            .padding(.horizontal, 8)
                            .padding(.top, 16)
                            
                            // Transaction Details
                            VStack(spacing: 16) {
                                if transaction.type == .send || transaction.type == .receive {
                                    DetailRow(
                                        title: transaction.type == .send ? "Recipient Cash No" : "Sender Cash No",
                                        value: transaction.type == .send ? receiverCashID : senderCashID
                                    )
                                }
                                
                                DetailRow(title: "Transaction No", value: formattedTransactionNo)
                                DetailRow(title: "Transaction Fee", value: "Free")
                                DetailRow(
                                    title: "Post-Transaction Balance",
                                    value: formattedBalance
                                )
                            }
                            .padding(.top, 32)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                    }
                }
            }
            .navigationBarBackButtonHidden()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundStyle(Color(white: 0.7))
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text(title)
                        .font(.title.bold())
                        .foregroundStyle(.white)
                }
            }
            .task {
                isLoading = true
                await fetchNames()
                await fetchAdditionalInfo()
                isLoading = false
            }
        }
    }
    
    private var title: String {
        switch transaction.type {
        case .deposit: return "Money Deposit"
        case .withdraw: return "Money Withdrawal"
        case .send: return "Money Sent"
        case .receive: return "Money Received"
        }
    }
    
    private var transactionIcon: String {
        switch transaction.type {
        case .deposit: return "arrow.down.circle.fill"
        case .withdraw: return "arrow.up.circle.fill"
        case .send: return "arrow.up.circle.fill"
        case .receive: return "arrow.down.circle.fill"
        }
    }
    
    private var transactionDescription: String {
        switch transaction.type {
        case .deposit: return "Money deposited to your account"
        case .withdraw: return "Money withdrawn from your account"
        case .send: return "Money sent to recipient"
        case .receive: return "Money received from sender"
        }
    }
    
    private var displayName: String {
        switch transaction.type {
        case .deposit, .withdraw:
            return currentUserName
        case .send:
            return receiverName
        case .receive:
            return senderName
        }
    }
    
    private func getInitials() -> String {
        let name = displayName
        let components = name.components(separatedBy: " ")
        let initials = components.compactMap { String($0.prefix(1)) }.prefix(2)
        return initials.joined()
    }
    
    private func fetchNames() async {
        guard let db = try? Firestore.firestore() else { return }
        
        if let currentUserID = Auth.auth().currentUser?.uid {
            let currentUserDoc = try? await db.collection("users").document(currentUserID).getDocument()
            currentUserName = currentUserDoc?.data()?["fullName"] as? String ?? "Unknown"
        }
        
        if let senderID = transaction.senderID {
            let doc = try? await db.collection("users").document(senderID).getDocument()
            senderName = doc?.data()?["fullName"] as? String ?? "Unknown"
        }
        
        if let receiverID = transaction.receiverID {
            let doc = try? await db.collection("users").document(receiverID).getDocument()
            receiverName = doc?.data()?["fullName"] as? String ?? "Unknown"
        }
    }
    
    private var formattedDateTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy HH:mm"
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale(identifier: "en_US")
        return dateFormatter.string(from: transaction.date)
    }
    
    private var amountColor: Color {
        switch transaction.type {
        case .deposit, .receive: return .green
        case .withdraw, .send: return .red
        }
    }
    
    private var formattedAmount: String {
        let prefix = transaction.type == .withdraw || transaction.type == .send ? "-" : "+"
        let symbol = transaction.currency == .TL ? "₺" : "$"
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        let amount = formatter.string(from: NSNumber(value: transaction.amount)) ?? "0.00"
        return "\(prefix)\(symbol)\(amount)"
    }
    
    private var actionButtons: [String] {
        switch transaction.type {
        case .deposit, .withdraw:
            return ["Receipt", "Share in Chat"]
        case .receive:
            return ["Receipt", "Send Back", "Request Money", "Share in Chat"]
        case .send:
            return ["Receipt", "Repeat", "Request Money", "Share in Chat"]
        }
    }
    
    private func iconName(for title: String) -> String {
        switch title {
        case "Receipt": return "doc.text.fill"
        case "Repeat": return "arrow.clockwise"
        case "Send Back": return "arrow.uturn.backward"
        case "Request Money": return "arrow.left.arrow.right"
        case "Share in Chat": return "bubble.right.fill"
        default: return ""
        }
    }
    
    private var formattedBalance: String {
        let symbol = transaction.currency == .TL ? "₺" : "$"
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        let amount = formatter.string(from: NSNumber(value: postTransactionBalance)) ?? "0.00"
        return "\(symbol)\(amount)"
    }
    
    private var formattedTransactionNo: String {
        let cleanId = transaction.id.replacingOccurrences(of: "-", with: "")
        let endIndex = cleanId.index(cleanId.startIndex, offsetBy: min(10, cleanId.count))
        return String(cleanId[..<endIndex])
    }
    
    private func fetchAdditionalInfo() async {
        guard let db = try? Firestore.firestore() else { return }
        
        if let senderID = transaction.senderID {
            let doc = try? await db.collection("users").document(senderID).getDocument()
            senderCashID = doc?.data()?["idCash"] as? String ?? "Unknown"
        }
        
        if let receiverID = transaction.receiverID {
            let doc = try? await db.collection("users").document(receiverID).getDocument()
            receiverCashID = doc?.data()?["idCash"] as? String ?? "Unknown"
        }
        
        // Post-transaction balance'ı hesapla
        if let currentUserID = Auth.auth().currentUser?.uid {
            let doc = try? await db.collection("users").document(currentUserID).getDocument()
            if let data = doc?.data(),
               let bankAccount = data["bankAccount"] as? [String: Any],
               let transactions = bankAccount["transactions"] as? [[String: Any]] {
                
                // İşlem tarihine kadar olan bakiyeyi hesapla
                var balance: Double = 0.0
                
                for transactionData in transactions {
                    guard let type = transactionData["type"] as? String,
                          let amount = transactionData["amount"] as? Double,
                          let currency = transactionData["currency"] as? String,
                          let timestamp = transactionData["date"] as? TimeInterval,
                          let id = transactionData["id"] as? String else { continue }
                    
                    let transactionDate = Date(timeIntervalSince1970: timestamp)
                    
                    // Sadece aynı para birimindeki işlemleri hesaba kat
                    if currency == (transaction.currency == .TL ? "TL" : "USD") {
                        // İşlem tarihine kadar olan işlemleri topla
                        if transactionDate <= transaction.date {
                            switch type {
                            case "deposit", "receive":
                                balance += amount
                            case "withdraw", "send":
                                balance -= amount
                            default:
                                break
                            }
                            
                            // Mevcut işleme geldiğimizde dur
                            if id == transaction.id {
                                break
                            }
                        }
                    }
                }
                
                postTransactionBalance = balance
            }
        }
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(Color(white: 0.7))
            Spacer()
            Text(value)
                .font(.subheadline)
                .foregroundStyle(Color(white: 0.7))
        }
        .padding(.horizontal, 10)
    }
} 
