import SwiftUI

struct TransferOperationsView: View {
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            VStack(spacing: 24) {
                // Buttons Container
                VStack(spacing: 0) {
                    TransferButton(
                        icon: "arrow.up.right",
                        title: "Send Money"
                    ) {
                        withAnimation(.spring(duration: 0.3)) {
                            onDismiss()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                NavigationUtil.navigate(to: SendMoneyView())
                            }
                        }
                    }
                    
                    TransferButton(
                        icon: "arrow.down.left",
                        title: "Request Money"
                    ) {
                        // Para isteme işlemi
                    }
                    
                    TransferButton(
                        icon: "globe",
                        title: "International Money Transfer"
                    ) {
                        // Uluslararası transfer işlemi
                    }
                    
                    TransferButton(
                        icon: "arrow.2.circlepath",
                        title: "Recurring Transfer"
                    ) {
                        // Düzenli transfer işlemi
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
    }
}

struct TransferButton: View {
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
        
        if title != "Recurring Transfer" {
            Divider()
                .background(Color.black.opacity(0.3))
        }
    }
} 