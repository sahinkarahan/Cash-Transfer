import SwiftUI

struct LoadingView: View {
    let title: String
    let description: String
    @State private var progress: Double = 0.0
    
    init(
        title: String = "Verifying your information.",
        description: String = "This process may take a few seconds, please wait."
    ) {
        self.title = title
        self.description = description
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 16)
            
            Text(description)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 16)
            
            Spacer()
                .frame(height: 20)
            
            ZStack {
                // Arka plan dairesi
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 8)
                    .frame(width: 120, height: 120)
                
                // İlerleme dairesi
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color.white, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
            }
            .frame(height: 160)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    progress = 1.0
                }
            }
        }
        .padding(32)
        .frame(width: 320, height: 360)
        .background(Color(white: 0.2))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.2), radius: 8)
    }
}

// View modifier for showing loading state
struct LoadingModifier: ViewModifier {
    let isLoading: Bool
    let title: String
    let description: String
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .disabled(isLoading)
            
            if isLoading {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                
                LoadingView(title: title, description: description)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.easeInOut, value: isLoading)
    }
}

// View extension for easier usage
extension View {
    func loading(
        isLoading: Bool,
        title: String = "Verifying your information.",
        description: String = "This process may take a few seconds, please wait."
    ) -> some View {
        modifier(LoadingModifier(
            isLoading: isLoading,
            title: title,
            description: description
        ))
    }
}

#Preview {
    ZStack {
        Color(white: 0.15)
            .ignoresSafeArea()
        
        LoadingView()
    }
} 
