import SwiftUI

struct MenuOperationsView: View {
    let onDismiss: () -> Void
    @State private var showSupportCenter = false
    @StateObject private var notificationViewModel = NotificationViewModel()
    
    var body: some View {
        ZStack {
            VStack(spacing: 24) {
                // Buttons Container
                VStack(spacing: 0) {
                    MenuButton(
                        icon: "bell",
                        title: "Notifications"
                    ) {
                        withAnimation(.spring(duration: 0.3)) {
                            onDismiss()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                Task {
                                    NavigationUtil.navigate(to: NotificationView())
                                }
                            }
                        }
                    }
                    .overlay(alignment: .trailing) {
                        if notificationViewModel.unreadCount > 0 {
                            Text("\(notificationViewModel.unreadCount)")
                                .font(.caption2.bold())
                                .foregroundStyle(.white)
                                .frame(width: 20, height: 20)
                                .background(.red)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                                .offset(x: -12)
                        }
                    }
                    
                    MenuButton(
                        icon: "arrow.right.arrow.left",
                        title: "Withdraw / Deposit Money"
                    ) {
                        withAnimation(.spring(duration: 0.3)) {
                            onDismiss()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                Task {
                                    NavigationUtil.navigate(to: TransactionView())
                                }
                            }
                        }
                    }
                    
                    MenuButton(
                        icon: "questionmark.circle",
                        title: "Support Center"
                    ) {
                        showSupportCenter = true
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
        .fullScreenCover(isPresented: $showSupportCenter) {
            SupportCenterView()
        }
    }
}

struct MenuButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .frame(width: 32)
                
                Text(title)
                    .font(.body)
                
                Spacer()
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }
} 
