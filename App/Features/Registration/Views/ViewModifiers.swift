import SwiftUI

struct PlaceholderModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundStyle(.white.opacity(0.6))
    }
}

extension View {
    func whitePlaceholder() -> some View {
        modifier(PlaceholderModifier())
    }
} 