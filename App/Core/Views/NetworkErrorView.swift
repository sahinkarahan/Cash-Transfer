import SwiftUI
import Combine

struct NetworkErrorView: View {
    @ObservedObject private var networkMonitor = NetworkMonitor.shared
    @State private var showRetryFeedback = false
    @State private var retryFeedbackText = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            Text("No Internet Connection")
                .font(.headline)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 16)
            
            Text("Please check your internet connection and try again")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 16)
            
            Spacer()
                .frame(height: 20)
            
            ZStack {
                Circle()
                    .stroke(Color.red.opacity(0.2), lineWidth: 8)
                    .frame(width: 120, height: 120)
                
                Image(systemName: "wifi.slash")
                    .font(.system(size: 50))
                    .foregroundStyle(.red)
                    .symbolEffect(.bounce, options: .repeating, value: networkMonitor.isReconnecting)
            }
            .frame(height: 160)
            
            if showRetryFeedback {
                Text(retryFeedbackText)
                    .font(.caption)
                    .foregroundStyle(networkMonitor.connectionQuality == .poor ? .yellow : .red)
                    .transition(.scale.combined(with: .opacity))
            }
            
            Button {
                Task {
                    withAnimation {
                        showRetryFeedback = false
                    }
                    
                    if !networkMonitor.hasNetworkPath {
                        withAnimation {
                            showRetryFeedback = true
                            retryFeedbackText = "No internet connection detected. Please check your settings."
                        }
                        return
                    }
                    
                    let hasConnection = await networkMonitor.retryConnection()
                    
                    if hasConnection {
                        dismiss()
                    } else {
                        withAnimation {
                            showRetryFeedback = true
                            retryFeedbackText = networkMonitor.connectionQuality == .poor ? 
                                "Connection is weak. Please try again." :
                                "Still no connection. Please try again later."
                        }
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    if networkMonitor.isReconnecting {
                        ProgressView()
                            .tint(.white)
                    }
                    
                }
                
            }
            .disabled(networkMonitor.isReconnecting)
        }
        .padding(32)
        .frame(width: 320, height: 400)
        .background(Color(white: 0.2))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.2), radius: 8)
        .onReceive(networkMonitor.connectionRestoredPublisher) { _ in
            dismiss()
        }
    }
}

#Preview {
    NetworkErrorView()
} 
