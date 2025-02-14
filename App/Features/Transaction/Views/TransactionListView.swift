import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct TransactionListView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) private var presentationMode
    @StateObject private var viewModel = TransactionListViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    colors: [Color(white: 0.15), Color(white: 0.12)],
                    startPoint: .top,
                    endPoint: .bottom
                ).ignoresSafeArea()
                
                if viewModel.isLoading {
                    LoadingView()
                } else if viewModel.transactions.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "list.bullet.rectangle.portrait")
                            .font(.system(size: 48))
                            .foregroundStyle(Color(white: 0.7))
                        
                        Text(viewModel.error ?? "No transactions found")
                            .font(.body)
                            .foregroundStyle(Color(white: 0.7))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 20)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 24) {
                            ForEach(groupedTransactions.keys.sorted(by: >), id: \.self) { date in
                                VStack(alignment: .leading, spacing: 12) {
                                    // Date Header
                                    Text(formatDate(date))
                                        .font(.subheadline.bold())
                                        .foregroundStyle(Color(white: 0.7))
                                        .padding(.horizontal, 20)
                                    
                                    // Transactions for this date
                                    VStack(spacing: 1) {
                                        ForEach(groupedTransactions[date] ?? [], id: \.id) { transaction in
                                            NavigationLink {
                                                TransactionDetailView(transaction: transaction)
                                                    .navigationBarBackButtonHidden()
                                                    .transaction { transaction in
                                                        transaction.animation = nil
                                                    }
                                            } label: {
                                                TransactionRow(transaction: transaction)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 20)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        UITabBar.appearance().isHidden = false
                        if presentationMode.wrappedValue.isPresented {
                            presentationMode.wrappedValue.dismiss()
                        } else {
                            NavigationUtil.dismiss()
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.body.bold())
                            .foregroundStyle(.white)
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("TRANSACTIONS")
                        .font(.headline.bold())
                        .foregroundStyle(.white)
                }
            }
        }
        .task {
            await viewModel.fetchTransactions()
        }
    }
    
    private var groupedTransactions: [Date: [Transaction]] {
        Dictionary(grouping: viewModel.transactions) { transaction in
            Calendar.current.startOfDay(for: transaction.date)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "dd MMMM yyyy"
        return formatter.string(from: date)
    }
}

struct TransactionRow: View {
    let transaction: Transaction
    @State private var senderName: String = ""
    @State private var receiverName: String = ""
    @State private var currentUserName: String = ""
    
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
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 16) {
                // Initials Circle
                Circle()
                    .fill(Color(white: 0.3))
                    .frame(width: 48, height: 48)
                    .overlay {
                        Text(getInitials())
                            .font(.title3.bold())
                            .foregroundStyle(.white)
                            .textCase(.uppercase)
                    }
                
                // Details
                VStack(alignment: .leading, spacing: 4) {
                    Text(displayName)
                        .font(.body)
                        .foregroundStyle(.white)
                    
                    Text(title)
                        .font(.subheadline)
                        .foregroundStyle(Color(white: 0.7))
                    
                    if let message = transaction.message {
                        HStack(spacing: 4) {
                            Image(systemName: "message.fill")
                                .font(.caption2)
                            Text(message)
                                .font(.caption)
                        }
                        .foregroundStyle(Color(white: 0.6))
                    }
                }
                
                Spacer()
                
                // Amount and Date
                VStack(alignment: .trailing, spacing: 4) {
                    Text(formattedAmount)
                        .font(.body.bold())
                        .foregroundStyle(amountColor)
                    
                    Text(formattedDateTime)
                        .font(.caption)
                        .foregroundStyle(Color(white: 0.6))
                }
            }
            .padding()
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .task {
            await fetchNames()
        }
    }
    
    private func getInitials() -> String {
        switch transaction.type {
        case .deposit, .withdraw:
            let components = currentUserName.components(separatedBy: " ")
            let initials = components.compactMap { String($0.prefix(1)) }.prefix(2)
            return initials.joined()
        case .send:
            let components = receiverName.components(separatedBy: " ")
            let initials = components.compactMap { String($0.prefix(1)) }.prefix(2)
            return initials.joined()
        case .receive:
            let components = senderName.components(separatedBy: " ")
            let initials = components.compactMap { String($0.prefix(1)) }.prefix(2)
            return initials.joined()
        }
    }
    
    private func fetchNames() async {
        guard let db = try? Firestore.firestore() else { return }
        
        // Mevcut kullanıcının adını al
        if let currentUserID = Auth.auth().currentUser?.uid {
            let currentUserDoc = try? await db.collection("users").document(currentUserID).getDocument()
            currentUserName = currentUserDoc?.data()?["fullName"] as? String ?? "Unknown"
        }
        
        // Gönderen ve alıcı adlarını al
        if let senderID = transaction.senderID {
            let doc = try? await db.collection("users").document(senderID).getDocument()
            senderName = doc?.data()?["fullName"] as? String ?? "Unknown"
        }
        
        if let receiverID = transaction.receiverID {
            let doc = try? await db.collection("users").document(receiverID).getDocument()
            receiverName = doc?.data()?["fullName"] as? String ?? "Unknown"
        }
    }
    
    private var title: String {
        switch transaction.type {
        case .deposit: return "Money Deposit"
        case .withdraw: return "Money Withdrawal"
        case .send: return "Sent to"
        case .receive: return "Received from"
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
} 
