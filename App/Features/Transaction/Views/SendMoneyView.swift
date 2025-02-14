import SwiftUI

struct SendMoneyView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = SendMoneyViewModel()
    @State private var selectedCurrency: Currency = .TL
    @State private var amount: String = ""
    @State private var recipientFullName: String = ""
    @State private var recipientCashID: String = ""
    @State private var recipientPhone: String = ""
    @State private var message: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showResult = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    colors: [Color(white: 0.15), Color(white: 0.12)],
                    startPoint: .top,
                    endPoint: .bottom
                ).ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Recipient Info Section
                        VStack(spacing: 12) {
                            CustomTextField(
                                text: $recipientFullName,
                                placeholder: "Recipient Full Name",
                                description: "Full Name",
                                icon: "person.fill",
                                keyboardType: .default
                            )
                            
                            CustomTextField(
                                text: $recipientCashID,
                                placeholder: "Cash ID",
                                description: "Cash ID",
                                icon: "number",
                                keyboardType: .asciiCapable
                            )
                            
                            CustomTextField(
                                text: $recipientPhone,
                                placeholder: "Phone Number",
                                description: "Phone",
                                icon: "phone.fill",
                                keyboardType: .phonePad
                            )
                            
                            CustomTextField(
                                text: $message,
                                placeholder: "Add a message (optional)",
                                description: "Message",
                                icon: "text.bubble.fill",
                                keyboardType: .default
                            )
                        }
                        
                        // Currency Picker
                        HStack(spacing: 24) {
                            currencyButton(.TL, icon: "turkishlirasign.circle.fill")
                            currencyButton(.USD, icon: "dollarsign.circle.fill")
                        }
                        .padding(.horizontal, 32)
                        
                        // Amount Input
                        VStack(spacing: 12) {
                            Text(selectedCurrency == .TL ? "₺\(amount.isEmpty ? "0,00" : amount)" : 
                                                       "$\(amount.isEmpty ? "0.00" : amount)")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(height: 48)
                                .contentTransition(.numericText())
                            
                            Text("Available Balance: \(selectedCurrency == .TL ? "₺\(formatNumber(viewModel.balanceTL))" : "$\(formatNumber(viewModel.balanceUSD))")")
                                .font(.subheadline)
                                .foregroundStyle(Color(white: 0.7))
                        }
                        
                        // Numpad
                        numpadView
                        
                        // Send Button
                        Button(action: handleSendMoney) {
                            Text("Send Money")
                                .font(.title3.bold())
                                .foregroundStyle(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    LinearGradient(
                                        colors: [.white, .white.opacity(0.9)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                    .padding(20)
                }
                
                if showResult {
                    resultOverlayView
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("SEND MONEY")
                        .font(.headline.bold())
                        .foregroundStyle(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundStyle(Color(white: 0.7))
                    }
                }
            }
            .loading(
                isLoading: viewModel.isLoading,
                title: "Processing",
                description: "Please wait while we process your transaction"
            )
        }
    }
    
    // Diğer view componentleri TransactionView ile aynı
    private var numpadView: some View {
        VStack(spacing: 12) {
            ForEach(0..<4) { row in
                HStack(spacing: 12) {
                    ForEach(0..<3) { col in
                        let digit = getNumpadDigit(row: row, col: col)
                        if digit != "" {
                            numpadButton(digit)
                        } else {
                            Color.clear.frame(width: 72, height: 72)
                        }
                    }
                }
            }
        }
    }
    
    private func currencyButton(_ currency: Currency, icon: String) -> some View {
        Button {
            withAnimation {
                selectedCurrency = currency
                amount = ""
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                Text(currency.rawValue)
                    .font(.body.bold())
            }
            .foregroundStyle(selectedCurrency == currency ? .white : Color(white: 0.7))
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(selectedCurrency == currency ? Color(white: 0.25) : .clear)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(white: 0.3), lineWidth: selectedCurrency == currency ? 0 : 1)
            )
        }
    }
    
    private func numpadButton(_ digit: String) -> some View {
        Button {
            handleNumpadInput(digit)
        } label: {
            Text(digit)
                .font(.title2.bold())
                .foregroundStyle(.white)
                .frame(width: 72, height: 72)
                .background(Color(white: 0.2))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(white: 0.3), lineWidth: 1)
                )
        }
    }
    
    private func handleNumpadInput(_ digit: String) {
        if digit == "⌫" {
            if !amount.isEmpty {
                amount.removeLast()
            }
        } else {
            if digit == "," && amount.contains(",") { return }
            if digit != "," && amount.contains(",") {
                let parts = amount.split(separator: ",")
                if parts.count > 1 && parts[1].count >= 2 { return }
            }
            amount += digit
        }
    }
    
    private func formatNumber(_ number: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.decimalSeparator = ","
        formatter.groupingSeparator = "."
        return formatter.string(from: NSNumber(value: number)) ?? "0,00"
    }
    
    private func getNumpadDigit(row: Int, col: Int) -> String {
        let digits = [
            ["1", "2", "3"],
            ["4", "5", "6"],
            ["7", "8", "9"],
            [",", "0", "⌫"]
        ]
        
        if row < digits.count && col < digits[row].count {
            return digits[row][col]
        }
        return ""
    }
    
    private func handleSendMoney() {
        let amountString = amount.replacingOccurrences(of: ",", with: ".")
        guard let amountValue = Double(amountString) else {
            viewModel.error = "Please enter a valid amount"
            showResult = true
            return
        }
        
        guard !recipientCashID.isEmpty && !recipientFullName.isEmpty && !recipientPhone.isEmpty else {
            viewModel.error = "Please fill in all recipient information"
            showResult = true
            return
        }
        
        Task {
            viewModel.isLoading = true
            if let recipientData = await viewModel.findUserByCashIDAndVerify(
                cashID: recipientCashID,
                fullName: recipientFullName,
                phone: recipientPhone
            ) {
                let success = await viewModel.sendMoney(
                    to: recipientData.id,
                    amount: amountValue,
                    currency: selectedCurrency,
                    message: message.isEmpty ? nil : message
                )
                
                showResult = true
            } else {
                viewModel.error = "Recipient information does not match"
                showResult = true
            }
            viewModel.isLoading = false
        }
    }
    
    private var resultOverlayView: some View {
        ZStack {
            Color.black.opacity(0.8).ignoresSafeArea()
            
            SuccessView(
                title: viewModel.error == nil ? "Transfer Successful" : "Transfer Failed",
                description: viewModel.error ?? "Money transfer completed successfully.",
                buttonTitle: "OK",
                action: {
                    if viewModel.error == nil {
                        NotificationCenter.default.post(name: .refreshHomeData, object: nil)
                    }
                    dismiss()
                },
                isSuccess: viewModel.error == nil
            )
        }
    }
}

struct CustomTextField: View {
    @Binding var text: String
    let placeholder: String
    let description: String
    let icon: String
    let keyboardType: UIKeyboardType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(description)
                .font(.caption)
                .foregroundStyle(Color(white: 0.7))
            
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.body)
                    .foregroundStyle(Color(white: 0.7))
                
                TextField(placeholder, text: $text)
                    .font(.body)
                    .foregroundStyle(.white)
                    .keyboardType(keyboardType)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(keyboardType == .asciiCapable ? .never : .words)
            }
            .padding()
            .background(Color(white: 0.2))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(white: 0.3), lineWidth: 1)
            )
        }
    }
} 
