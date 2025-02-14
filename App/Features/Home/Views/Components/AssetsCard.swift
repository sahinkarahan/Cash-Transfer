import SwiftUI

struct AssetsCard: View {
    @State private var showUSD = false
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header & Total Balance
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 8) {
                        // Logo Container
                        Circle()
                            .fill(.white)
                            .frame(width: 18, height: 18)
                            .overlay {
                                Text("C")
                                    .font(.caption2.bold())
                                    .foregroundStyle(.black)
                            }
                        
                        Text("All My Assets")
                            .font(.body)
                            .foregroundStyle(.white)
                    }
                    
                    Text(showUSD ? "$\(formatNumber(viewModel.userData?.bankAccount.balanceUSD ?? 0.0))" : 
                                 "₺\(formatNumber(viewModel.userData?.bankAccount.balanceTL ?? 0.0))")
                        .font(.title.bold())
                        .foregroundStyle(.white)
                        .contentTransition(.numericText())
                }
                
                Spacer()
                
                // Custom Currency Toggle
                Button {
                    withAnimation {
                        showUSD.toggle()
                    }
                } label: {
                    ZStack {
                        // Background Track
                        Capsule()
                            .fill(.white)
                            .frame(width: 51, height: 31)
                        
                        // Currency Symbols
                        HStack(spacing: 12) {
                            Text("₺")
                                .font(.footnote.bold())
                                .foregroundStyle(showUSD ? .white.opacity(0.5) : .white)
                                .frame(width: 20)
                            
                            Text("$")
                                .font(.footnote.bold())
                                .foregroundStyle(showUSD ? .white : .white.opacity(0.5))
                                .frame(width: 20)
                        }
                        .padding(.horizontal, 4)
                        
                        // Thumb
                        Circle()
                            .fill(.black)
                            .frame(width: 27, height: 27)
                            .overlay {
                                Text(showUSD ? "$" : "₺")
                                    .font(.caption2.bold())
                                    .foregroundStyle(.white)
                            }
                            .offset(x: showUSD ? 10 : -10)
                    }
                    .frame(width: 51, height: 31)
                }
            }
            
            // Asset List Container
            VStack(alignment: .leading, spacing: 16) {
                Spacer()
                
                // Asset List
                VStack(spacing: 12) {
                    // Turkish Lira Account
                    if !showUSD {
                        AssetRow(
                            icon: "turkey",
                            iconBackgroundColor: .clear,
                            title: "Turkish Lira",
                            value: "₺\(formatNumber(viewModel.userData?.bankAccount.balanceTL ?? 0.0))",
                            isImage: true,
                            useNumericTransition: true
                        )
                        .transition(.opacity.combined(with: .move(edge: .leading)))
                    } else {
                        AssetRow(
                            icon: "dollarsign",
                            iconBackgroundColor: .green,
                            title: "US Dollar",
                            value: "$\(formatNumber(viewModel.userData?.bankAccount.balanceUSD ?? 0.0))",
                            useNumericTransition: true
                        )
                        .transition(.opacity.combined(with: .move(edge: .trailing)))
                    }
                    
                    // Precious Metals
                    AssetRow(
                        icon: "chart.line.uptrend.xyaxis",
                        iconBackgroundColor: .yellow,
                        title: "Precious Metals",
                        value: "—"
                    )
                    
                    // Investment Account
                    AssetRow(
                        icon: "chart.pie.fill",
                        iconBackgroundColor: .blue,
                        title: "Investment Account",
                        value: "—"
                    )
                    
                    // Savings Account
                    AssetRow(
                        icon: "banknote",
                        iconBackgroundColor: .purple,
                        title: "Savings Account",
                        value: "—"
                    )
                }
            }
        }
        .padding(14)
        .background(Color(white: 0.2))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(white: 0.3), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .animation(.spring(duration: 0.3), value: showUSD)
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

struct AssetRow: View {
    let icon: String
    let iconBackgroundColor: Color
    let title: String
    let value: String
    var isImage: Bool = false
    var useNumericTransition: Bool = false
    
    var body: some View {
        HStack {
            // Icon
            if isImage {
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
            } else {
                Circle()
                    .fill(iconBackgroundColor)
                    .frame(width: 18, height: 18)
                    .overlay {
                        Image(systemName: icon)
                            .font(.caption2)
                            .foregroundStyle(.white)
                    }
            }
            
            // Title
            Text(title)
                .font(.caption)
                .foregroundStyle(.white)
            
            Spacer()
            
            // Value
            Text(value)
                .font(.caption)
                .foregroundStyle(.white)
                .contentTransition(.numericText())
                .transaction { transaction in
                    transaction.animation = .spring(duration: 0.3)
                }
        }
    }
}
