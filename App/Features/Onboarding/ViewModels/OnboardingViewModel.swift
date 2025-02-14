import Foundation

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var currentPage = 0
    
    let items = [
        OnboardingItem(
            title: "Send money for free at the speed of light.",
            description: "Send money for free 24/7 or request money from anyone you want. Set up instructions for your recurring payments.",
            imageName: "dollarsign.arrow.circlepath"
        ),
        OnboardingItem(
            title: "Earn without going into debt.",
            description: "Spend worldwide and online with Cash Transfer without going into debt. No card or usage fees!",
            imageName: "creditcard.and.123"
        ),
        OnboardingItem(
            title: "Get instant cashback as you spend",
            description: "Earn up to $300 in instant cash every month on purchases from Cashback brands!",
            imageName: "arrow.counterclockwise.circle.fill"
        ),
        OnboardingItem(
            title: "Control your expenses, bills, and everything.",
            description: "Take control of your spending! Make all your payments with Cash Transfer and track them with instant notifications and graphs.",
            imageName: "chart.bar.xaxis.ascending.badge.clock"
        ),
        OnboardingItem(
            title: "Easily receive payments with Cash Transfer.",
            description: "The perfect solution for businesses, sellers, and freelancers! Receive payments via Papara number or QR code.",
            imageName: "qrcode.viewfinder"
        )
    ]
} 
