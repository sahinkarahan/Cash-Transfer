import SwiftUI

struct TransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = TransactionViewModel()
    @State private var selectedTab = 0
    @State private var selectedCurrency: Currency = .TL
    @State private var amount: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showResult = false
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundView
                
                VStack(spacing: 32) {
                    tabPickerView
                    transactionFormView
                }
                .padding(.horizontal, 20)
                
                if showResult {
                    resultOverlayView
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("WITHDRAW / DEPOSIT MONEY")
                        .font(.headline.bold())
                        .foregroundStyle(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        NavigationUtil.dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundStyle(Color(white: 0.7))
                    }
                }
            }
        }
    }
    
    private var backgroundView: some View {
        LinearGradient(
            colors: [Color(white: 0.15), Color(white: 0.12)],
            startPoint: .top,
            endPoint: .bottom
        ).ignoresSafeArea()
    }
    
    private var tabPickerView: some View {
        HStack(spacing: 0) {
            ForEach(["Withdraw", "Deposit"].indices, id: \.self) { index in
                tabButton(index: index)
            }
        }
        .padding(4)
        .background(Color(white: 0.2))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.top, 16)
    }
    
    private func tabButton(index: Int) -> some View {
        Button {
            withAnimation(.spring(duration: 0.3)) {
                selectedTab = index
                amount = ""
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: index == 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                    .font(.title2)
                Text(["Withdraw", "Deposit"][index])
                    .font(.body.bold())
            }
            .foregroundStyle(selectedTab == index ? .white : Color(white: 0.7))
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(selectedTab == index ? Color(white: 0.25) : .clear)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
    
    private var transactionFormView: some View {
        VStack(spacing: 40) {
            currencyPickerView
            amountInputView
            numpadView
            actionButtonView
        }
    }
    
    private var currencyPickerView: some View {
        HStack(spacing: 24) {
            currencyButton(.TL, icon: "turkishlirasign.circle.fill")
            currencyButton(.USD, icon: "dollarsign.circle.fill")
        }
        .padding(.horizontal, 40)
    }
    
    private var amountInputView: some View {
        VStack(spacing: 16) {
            Text(selectedCurrency == .TL ? "₺\(amount.isEmpty ? "0,00" : amount)" : 
                                         "$\(amount.isEmpty ? "0.00" : amount)")
                .font(.system(size: 48, weight: .bold))
                .foregroundStyle(.white)
                .frame(height: 60)
                .contentTransition(.numericText())
            
            Text("Available Balance: \(selectedCurrency == .TL ? "₺\(formatNumber(viewModel.balanceTL))" : "$\(formatNumber(viewModel.balanceUSD))")")
                .font(.subheadline)
                .foregroundStyle(Color(white: 0.7))
        }
    }
    
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
    
    private var actionButtonView: some View {
        Button(action: handleTransaction) {
            Text(selectedTab == 0 ? "Withdraw" : "Deposit")
                .font(.title3.bold())
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
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
    
    private var resultOverlayView: some View {
        ZStack {
            Color.black.opacity(0.8).ignoresSafeArea()
            
            SuccessView(
                title: viewModel.error == nil ? "Transaction Successful" : "Transaction Failed",
                description: viewModel.error ?? "Your transaction has been completed successfully.",
                buttonTitle: "OK",
                action: {
                    if viewModel.error == nil {
                        NotificationCenter.default.post(name: .refreshHomeData, object: nil)
                    }
                    presentationMode.wrappedValue.dismiss()
                    NotificationCenter.default.post(name: .dismissMenu, object: nil)
                },
                isSuccess: viewModel.error == nil
            )
        }
    }
    
    private func currencyButton(_ currency: Currency, icon: String) -> some View {
        Button {
            withAnimation {
                selectedCurrency = currency
                amount = "" // Reset amount on currency change
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
            // Virgül kontrolü
            if digit == "," && amount.contains(",") { return }
            // Maksimum 2 ondalık basamak kontrolü
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
    
    private func handleTransaction() {
        let amountString = amount.replacingOccurrences(of: ",", with: ".")
        guard let amountValue = Double(amountString) else {
            alertMessage = "Please enter a valid amount"
            showAlert = true
            return
        }
        
        Task {
            if selectedTab == 0 {
                await viewModel.withdraw(amount: amountValue, currency: selectedCurrency)
            } else {
                await viewModel.deposit(amount: amountValue, currency: selectedCurrency)
            }
            
            showResult = true
        }
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
} 
