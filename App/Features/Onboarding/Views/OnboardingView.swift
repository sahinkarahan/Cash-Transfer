import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @State private var showRegistration = false
    @State private var showLogin = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                // Page Control
                PageControl(numberOfPages: viewModel.items.count, currentPage: $viewModel.currentPage)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                
                // Logo
                Image("logocash")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 420, height: 120)
                    .padding(.top, 10)
                
                // Page Content
                TabView(selection: $viewModel.currentPage) {
                    ForEach(Array(viewModel.items.enumerated()), id: \.element.id) { index, item in
                        VStack(spacing: 32) {
                            Text(item.title)
                                .font(.title)
                                .foregroundStyle(.white)
                                .bold()
                                .multilineTextAlignment(.center)
                                .animation(.easeInOut, value: viewModel.currentPage)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 32)
                            
                            Image(systemName: item.imageName)
                                .font(.system(size: 120))
                                .foregroundStyle(.white)
                                .frame(height: 120)
                            
                            Text(item.description)
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.white.opacity(0.8))
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 32)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                Spacer()
                
                // Buttons
                VStack(spacing: 16) {
                    Button("Log In") {
                        showLogin = true
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    
                    Button("Create Account") {
                        showRegistration = true
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .background(Color(white: 0.15)) // Koyu gri arka plan
            .navigationDestination(isPresented: $showRegistration) {
                RegistrationView()
            }
            .navigationDestination(isPresented: $showLogin) {
                LoginView()
            }
        }
    }
}

#Preview {
    OnboardingView()
} 
