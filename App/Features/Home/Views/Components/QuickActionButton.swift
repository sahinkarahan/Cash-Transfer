import SwiftUI

struct QuickActionButton: View {
    let icon: String
    let title: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            // Icon Container
            ZStack {
                Circle()
                    .fill(Color(white: 0.15))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Circle()
                            .stroke(.white, lineWidth: 2)
                    )
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(.white)
            }
            
            // Title
            Text(title)
                .font(.caption)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
                .frame(width: 80)
                .frame(minHeight: 36)
        }
        .frame(width: 80, height: 108)
    }
} 