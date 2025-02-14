import SwiftUI

struct AccountSummaryCard: View {
    let iban: String
    @State private var showTransaction = false
    @State private var showSendMoney = false
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(spacing: 8) {
                // Turkish Flag - boyutu küçültüldü
                Image("turkey")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18) // 24'ten 18'e düşürüldü
                
                Text("Turkish Lira Account")
                    .font(.callout) // .body'den .callout'a değiştirildi
                    .foregroundStyle(.white)
            }
            
            Divider()
                .background(Color(white: 0.3))
                .padding(.vertical, 4)
            
            // Balance and Action Buttons Container
            VStack(alignment: .leading, spacing: 20) {
                // Balance ve IBAN Container
                VStack(alignment: .leading, spacing: 4) {
                    // Balance
                    HStack(spacing: 8) {
                        Text("₺\(formatNumber(viewModel.userData?.bankAccount.balanceTL ?? 0.0))")
                            .font(.title.bold())
                            .foregroundStyle(.white)
                            .contentTransition(.numericText())
                    
                        Image(systemName: "info.circle")
                            .font(.body)
                            .foregroundStyle(Color(white: 0.7))
                    }
                    
                    // IBAN
                    HStack(spacing: 4) {
                        Text("Your IBAN:")
                            .font(.footnote)
                            .foregroundStyle(Color(white: 0.7))
                        
                        Text(iban)
                            .font(.footnote)
                            .foregroundStyle(.white)
                            .underline()
                    }
                }
                .padding(.bottom, 8) // Alt butonlarla mesafeyi ayarlamak için
                
                // Action Buttons
                HStack(spacing: 16) {
                    // Deposit/Withdraw Button
                    Button {
                        showTransaction = true
                    } label: {
                        HStack {
                            Text("Deposit / Withdraw")
                                .font(.subheadline)
                                .foregroundStyle(.white)
                                .fixedSize(horizontal: false, vertical: true)
                                .multilineTextAlignment(.leading)
                            
                            Spacer()
                            
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.white)
                                .frame(width: 32, height: 32)
                                .overlay {
                                    Image(systemName: "arrow.right.arrow.left")
                                        .font(.body)
                                        .foregroundStyle(.black)
                                }
                        }
                        .frame(height: 48)
                        .padding(.horizontal, 16)
                        .frame(maxWidth: .infinity)
                        .background(Color(white: 0.25))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    // Send Button
                    Button {
                        showSendMoney = true
                    } label: {
                        HStack {
                            Text("Send Money")
                                .font(.subheadline)
                                .foregroundStyle(.white)
                            
                            Spacer()
                            
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.white)
                                .frame(width: 32, height: 32)
                                .overlay {
                                    Image(systemName: "paperplane.fill")
                                        .font(.body)
                                        .foregroundStyle(.black)
                                }
                        }
                        .frame(height: 48)
                        .padding(.horizontal, 16)
                        .frame(maxWidth: .infinity)
                        .background(Color(white: 0.25))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
        }
        .padding(20)
        .background(Color(white: 0.2))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(white: 0.3), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .fullScreenCover(isPresented: $showTransaction) {
            TransactionView()
        }
        .fullScreenCover(isPresented: $showSendMoney) {
            SendMoneyView()
        }
        .onReceive(NotificationCenter.default.publisher(for: .refreshHomeData)) { _ in
            Task {
                await viewModel.fetchUserData()
            }
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
} 
