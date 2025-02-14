import SwiftUI

struct LoginView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = LoginViewModel()
    @FocusState private var focusedField: Field?
    
    enum Field: Int {
        case email, password
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 24) {
                // Back Button
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundStyle(.white)
                    }
                    .padding(.top, 20)
                    Spacer()
                }
                
                // Title and Description
                VStack(spacing: 12) {
                    Text("Log In")
                        .font(.title)
                        .bold()
                        .foregroundStyle(.white)
                    
                    Text("Log in by entering your email address and password.")
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 24)
                
                // Form Fields
                VStack(spacing: 16) {
                    TextField("Email Address", text: $viewModel.email)
                        .textFieldStyle(CustomTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .focused($focusedField, equals: .email)
                        .submitLabel(.next)
                    
                    SecureField("Password", text: $viewModel.password)
                        .textFieldStyle(CustomTextFieldStyle())
                        .focused($focusedField, equals: .password)
                        .submitLabel(.done)
                        .textContentType(.none)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .keyboardType(.default)
                }
                .padding(.top, 32)
                
                // Validation Indicators
                VStack(alignment: .leading, spacing: 12) {
                    // Segmented Progress Bar
                    HStack(spacing: 4) {
                        ForEach(0..<2, id: \.self) { index in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(index < viewModel.validationProgress ? Color.white : Color.gray.opacity(0.3))
                                .frame(maxWidth: .infinity)
                                .frame(height: 4)
                                .animation(.easeInOut, value: viewModel.validationProgress)
                        }
                    }
                    
                    // Validation Messages
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(viewModel.validationMessages.indices, id: \.self) { index in
                            Text(viewModel.validationMessages[index])
                                .font(.caption)
                                .foregroundStyle(viewModel.validationStates[index] ? .white : Color(white: 0.4))
                        }
                    }
                }
                
                Spacer()
                
                // Continue Button
                Button("Continue") {
                    viewModel.login()
                }
                .buttonStyle(PrimaryButtonStyle(isEnabled: viewModel.isFormValid))
                .disabled(!viewModel.isFormValid)
                .padding(.bottom, 32)
            }
            
            if viewModel.isLoading {
                LoadingView()
            }
            
            if viewModel.showErrorOverlay {
                VStack(spacing: 24) {
                    Text("Login Failed")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 16)
                    
                    Text(viewModel.errorMessage)
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
                        
                        Image(systemName: "exclamationmark.circle")
                            .font(.system(size: 50))
                            .foregroundStyle(.red)
                    }
                    .frame(height: 160)
                }
                .padding(32)
                .frame(width: 320, height: 360)
                .background(Color(white: 0.2))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.2), radius: 8)
                .transition(.opacity)
            }
        }
        .padding(.horizontal, 20)
        .background(Color(white: 0.15))
        .navigationBarBackButtonHidden()
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onSubmit {
            switch focusedField {
            case .email:
                focusedField = .password
            case .password:
                focusedField = nil
            case .none:
                break
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
        .onChange(of: viewModel.isLoggedIn) { isLoggedIn in
            if isLoggedIn {
                dismiss()
            }
        }
        .animation(.spring(duration: 0.3), value: viewModel.showErrorOverlay)
    }
}

#Preview {
    LoginView()
} 
