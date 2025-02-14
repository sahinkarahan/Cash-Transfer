import SwiftUI

struct SuccessView: View {
    let title: String
    let description: String
    let buttonTitle: String
    let action: () -> Void
    let isSuccess: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            // Icon
            Circle()
                .fill(isSuccess ? Color.green : Color.red)
                .frame(width: 80, height: 80)
                .overlay {
                    Image(systemName: isSuccess ? "checkmark" : "xmark")
                        .font(.title.bold())
                        .foregroundStyle(.white)
                }
            
            // Text Content
            VStack(spacing: 8) {
                Text(title)
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(Color(white: 0.7))
                    .multilineTextAlignment(.center)
            }
            
            // Action Button
            Button(action: action) {
                Text(buttonTitle)
                    .font(.body.bold())
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color(white: 0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        .padding(24)
        .background(Color(white: 0.2))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .padding(.horizontal, 20)
    }
} 