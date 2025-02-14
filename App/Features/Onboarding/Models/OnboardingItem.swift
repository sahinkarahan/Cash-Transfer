import SwiftUI

struct OnboardingItem: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let description: String
    let imageName: String
} 
