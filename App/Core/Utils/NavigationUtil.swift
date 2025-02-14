import SwiftUI

enum NavigationUtil {
    static func navigate<T: View>(to view: T) {
        let keyWindow = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
        
        if let rootViewController = keyWindow?.rootViewController {
            UITabBar.appearance().isHidden = true
            let hostingController = UIHostingController(rootView: view)
            hostingController.modalPresentationStyle = .fullScreen
            rootViewController.present(hostingController, animated: true)
        }
    }
    
    static func dismiss() {
        let keyWindow = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
        
        if let rootViewController = keyWindow?.rootViewController {
            UITabBar.appearance().isHidden = false
            rootViewController.dismiss(animated: true)
        }
    }
} 