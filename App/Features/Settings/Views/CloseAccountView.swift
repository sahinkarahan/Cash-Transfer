import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct CloseAccountView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = CloseAccountViewModel()
    
    var body: some View {
        ZStack {
            // Background
            Color(white: 0.15)
                .ignoresSafeArea()
            
            VStack {
                // Header
                HStack {
                    Spacer()
                    
                    Button(action: dismiss.callAsFunction) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundStyle(Color(white: 0.7))
                    }
                    .padding(20)
                }
                
                Spacer()
                
                // Content
                VStack(spacing: 24) {
                    Spacer()
                        .frame(height: 40)
                    
                    Image(systemName: "exclamationmark")
                        .font(.system(size: 120))
                        .foregroundStyle(.red)
                    
                    Spacer()
                    
                    VStack(spacing: 16) {
                        Text("Do you want to close your Cash account?")
                            .font(.title3.bold())
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                        
                        Text("If you close your account, you won't be able to benefit from many Cash advantages, and you won't be able to use your Cash Cards.")
                            .font(.body)
                            .foregroundStyle(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    
                    Spacer()
                    Spacer()
                    
                    // Bottom Buttons
                    VStack(spacing: 16) {
                        Button("Cancel") {
                            dismiss()
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
                        
                        Button("Delete") {
                            Task {
                                await viewModel.deleteAccount()
                            }
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
        .overlay {
            if viewModel.isLoading {
                LoadingView(
                    title: viewModel.loadingTitle,
                    description: viewModel.loadingDescription
                )
            }
        }
        .onChange(of: viewModel.isCompleted) { newValue in
            if newValue {
                withAnimation(.spring(duration: 0.3)) {
                    appState.isAuthenticated = false
                    appState.showOnboarding = true
                    NotificationCenter.default.post(name: .userLoggedOut, object: nil)
                }
            }
        }
    }
} 
