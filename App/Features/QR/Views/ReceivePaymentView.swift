import SwiftUI

struct ReceivePaymentView: View {
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            // Background
            Color(white: 0.15)
                .ignoresSafeArea()
            
            VStack {
                // Header
                HStack {
                    Spacer()
                    
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundStyle(Color(white: 0.7))
                    }
                    .padding(20)
                }
                
                // Title & Description
                VStack(spacing: 16) {
                    Text("Receive Payment with QR")
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                    
                    Text("By displaying the QR code, you can receive payments or money transfers from Cash users and other bank accounts.")
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                
                Spacer()
                
                // QR Code View (placeholder for now)
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(white: 0.3), lineWidth: 1)
                    .frame(width: 250, height: 250)
                    .overlay {
                        Image(systemName: "qrcode")
                            .font(.system(size: 100))
                            .foregroundStyle(.white)
                    }
                
                Spacer()
                
                // Bottom Buttons
                VStack(spacing: 16) {
                    Button("Share QR") {
                        // Share QR action
                    }
                    .font(.body.bold())
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(white: 0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(white: 0.3), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    Button("Generate QR with Amount") {
                        // Generate QR with amount action
                    }
                    .font(.body.bold())
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
    }
} 