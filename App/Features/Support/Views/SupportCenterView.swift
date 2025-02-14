import SwiftUI

struct SupportCenterView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Description
                VStack(spacing: 16) {
                    Text("Support Center")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                    
                    Text("If you have any issues or need support, you can reach us via the phone number or email address registered with Cash Transfer.")
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity)
                
                // Support Buttons
                VStack(spacing: 12) {
                    SupportButton(
                        icon: "phone.fill",
                        description: "User Support Center",
                        title: "+90 850 850 8500"
                    )
                    
                    SupportButton(
                        icon: "envelope.fill",
                        description: "Email Address",
                        title: "destek@cash.com"
                    )
                    
                    SupportButton(
                        icon: "person.2.fill",
                        description: "Cash Community",
                        title: "https://topluluk.cash.com"
                    )
                }
                
                Spacer()
            }
            .padding(.top, 20)
            .background(Color(white: 0.15))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                        NotificationCenter.default.post(name: .dismissMenu, object: nil)
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.body.bold())
                            .foregroundStyle(.white)
                    }
                }
            }
        }
    }
}

struct SupportButton: View {
    let icon: String
    let description: String
    let title: String
    
    var body: some View {
        Button(action: {}) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title3)
                    .frame(width: 24, height: 24)
                    .foregroundStyle(.white)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(description)
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.7))
                        .lineLimit(2)
                    
                    Text(title)
                        .font(.body)
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Image(systemName: "chevron.right")
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.7))
            }
            .padding(.horizontal, 20)
            .frame(height: 72)
        }
        .buttonStyle(.plain)
        
        if description != "Cash Community" {
            Divider()
                .background(Color.black.opacity(0.3))
                .padding(.vertical, 4)
        }
    }
} 