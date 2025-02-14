import SwiftUI

struct PageControl: View {
    let numberOfPages: Int
    @Binding var currentPage: Int
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<numberOfPages, id: \.self) { page in
                RoundedRectangle(cornerRadius: 2)
                    .fill(page == currentPage ? Color.white : Color.gray.opacity(0.3))
                    .frame(maxWidth: .infinity)
                    .frame(height: 4)
                    .animation(.easeInOut, value: currentPage)
            }
        }
    }
} 