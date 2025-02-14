import SwiftUI
import FirebaseAuth

struct LogoutConfirmationView: View {
    @EnvironmentObject private var appState: AppState
    let onCancel: () -> Void
    let onLogout: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            // Title and Description
            VStack(spacing: 12) {
                Text("Log Out")
                    .font(.title3.bold())
                    .foregroundStyle(.white)
                
                Text("Are you sure you want to log out?")
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            
            // Buttons
            VStack(spacing: 12) {
                Button("Cancel") {
                    onCancel()
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
                
                Button("Yes") {
                    do {
                        try Auth.auth().signOut()
                        onLogout()
                        appState.navigateToOnboarding()
                    } catch {
                        print("Error signing out: \(error.localizedDescription)")
                    }
                }
                .font(.body.bold())
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(24)
        .background(Color(white: 0.2))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .frame(width: UIScreen.main.bounds.width * 0.85)
    }
} 