import SwiftUI

struct OnboardingPageView: View {
    let item: OnboardingItem
    
    var body: some View {
        VStack(spacing: 24) {
            Text(item.title)
                .font(.title)
                .bold()
                .multilineTextAlignment(.center)
                .padding(.bottom, 20)
            
            Image(systemName: item.imageName)
                .font(.system(size: 120))
                .foregroundStyle(.tint)
                .padding(.bottom, 20)
            
            Text(item.description)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 32)
        }
    }
} 