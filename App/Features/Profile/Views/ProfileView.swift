import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = HomeViewModel()
    @State private var showPhotoOptions = false
    let onDismiss: () -> Void
    let onPhotoOptionsTap: () -> Void
    @State private var showLogoutConfirmation = false
    let onLogout: () -> Void
    @State private var showSettings = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 24) {
                // Buttons Container
                VStack(spacing: 0) {
                    ProfileButton(icon: "photo", title: "Choose Profile Photo") {
                        onDismiss()
                        onPhotoOptionsTap()
                    }
                    ProfileButton(icon: "person", title: "Account Details")
                    ProfileButton(icon: "clock", title: "Account Transactions") {
                        withAnimation(.spring(duration: 0.3)) {
                            onDismiss()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                let transactionListView = TransactionListView()
                                    .onAppear {
                                        UITabBar.appearance().isHidden = true
                                    }
                                NavigationUtil.navigate(to: transactionListView)
                            }
                        }
                    }
                    ProfileButton(icon: "gearshape", title: "Settings") {
                        withAnimation(.spring(duration: 0.3)) {
                            onDismiss()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                NotificationCenter.default.post(name: .showSettings, object: nil)
                            }
                        }
                    }
                    ProfileButton(icon: "arrow.right.square", title: "Secure Logout") {
                        onLogout()
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
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .transition(.move(edge: .bottom))
            
            if showLogoutConfirmation {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showLogoutConfirmation = false
                    }
                
                LogoutConfirmationView(
                    onCancel: {
                        showLogoutConfirmation = false
                    },
                    onLogout: onLogout
                )
                .environmentObject(AppState.shared)
                .transition(.scale.combined(with: .opacity))
            }
        }
    }
}

struct ProfileButton: View {
    let icon: String
    let title: String
    var isDisabled: Bool = false
    var action: (() -> Void)? = nil
    
    var body: some View {
        Button(action: { action?() }) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title3)
                    .frame(width: 24)
                    .foregroundStyle(isDisabled ? .gray : .white)
                
                Text(title)
                    .font(.body)
                    .foregroundStyle(isDisabled ? .gray : .white)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .frame(height: 56)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        
        if title != "Secure Logout" {
            Divider()
                .background(Color.black.opacity(0.3))
        }
    }
} 
