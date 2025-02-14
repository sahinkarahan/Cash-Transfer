import SwiftUI

struct QROperationsView: View {
    let onDismiss: () -> Void
    @State private var showReceivePayment = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 24) {
                // Buttons Container
                VStack(spacing: 0) {
                    QRButton(
                        icon: "qrcode.viewfinder",
                        title: "Pay with QR"
                    ) {
                        // QR ile ödeme işlemi
                    }
                    
                    QRButton(
                        icon: "qrcode",
                        title: "Receive Payment with QR"
                    ) {
                        showReceivePayment = true
                    }
                    
                    QRButton(
                        icon: "banknote",
                        title: "Withdraw Money from ATM with QR"
                    ) {
                        // QR ile ATM'den para çekme işlemi
                    }
                }
                .background(Color(white: 0.2))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.bottom, 16)
                
                // Cancel Button
                Button("Cancel") {
                    onDismiss()
                }
                .font(.body.bold())
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .transition(.move(edge: .bottom))
        .fullScreenCover(isPresented: $showReceivePayment) {
            ReceivePaymentView(onDismiss: {
                showReceivePayment = false
                onDismiss()
            })
        }
    }
}

struct QRButton: View {
    let icon: String
    let title: String
    var action: (() -> Void)? = nil
    
    var body: some View {
        Button(action: { action?() }) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title3)
                    .frame(width: 24)
                    .foregroundStyle(.white)
                
                Text(title)
                    .font(.body)
                    .foregroundStyle(.white)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .frame(height: 56)
        }
        .buttonStyle(.plain)
        
        if title != "Withdraw Money from ATM with QR" {
            Divider()
                .background(Color.black.opacity(0.3))
        }
    }
} 
