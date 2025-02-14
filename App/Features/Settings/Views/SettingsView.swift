import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showCloseAccount = false
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Account Settings Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Account Settings")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.7))
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 12) {
                            SettingsButton(
                                icon: "lock",
                                title: "Change Password",
                                description: "You can change the password of your Cash account"
                            )
                            
                            SettingsButton(
                                icon: "creditcard",
                                title: "Cash Card Settings",
                                description: "You can change your Cash Card password and preferences"
                            )
                            
                            SettingsButton(
                                icon: "phone",
                                title: "Change Phone Number",
                                description: "You can change your registered phone number"
                            )
                            
                            SettingsButton(
                                icon: "envelope",
                                title: "Change Email",
                                description: "You can change your registered email address"
                            )
                            
                            SettingsButton(
                                icon: "mappin.and.ellipse",
                                title: "Manage Address Information",
                                description: "You can add or modify your address"
                            )
                            
                            SettingsButton(
                                icon: "hand.raised",
                                title: "Privacy Settings",
                                description: "You can change your privacy preferences"
                            )
                            
                            SettingsButton(
                                icon: "message",
                                title: "Chat Settings",
                                description: "You can change your chat preferences"
                            )
                            
                            SettingsButton(
                                icon: "bell.badge",
                                title: "Low Balance Notification",
                                description: "You can receive notifications when your balance is low"
                            )
                            
                            SettingsButton(
                                icon: "iphone.gen3",
                                title: "Active Devices",
                                description: "You can view your active devices"
                            )
                            
                            SettingsButton(
                                icon: "link",
                                title: "Login Options",
                                description: "You can link your social media accounts"
                            )
                            
                            SettingsButton(
                                icon: "bell.and.waves.left.and.right",
                                title: "Contact Settings",
                                description: "You can choose the channels for campaign notifications"
                            )
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // App Settings Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("App Settings")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.7))
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 12) {
                            SettingsButton(
                                icon: "paintbrush",
                                title: "Appearance",
                                description: "You can change the color theme and app icon"
                            )
                            
                            SettingsButton(
                                icon: "eye.slash",
                                title: "Incognito Mode",
                                description: "You can hide your balance and transaction amounts"
                            )
                            
                            SettingsButton(
                                icon: "globe",
                                title: "App Language",
                                description: "You can change the language of the app"
                            )
                            
                            SettingsButton(
                                icon: "xmark.circle",
                                title: "Close Account",
                                description: "You can close your Cash Card account"
                            ) {
                                showCloseAccount = true
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.vertical, 20)
            }
            .background(Color(white: 0.15))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Settings")
                        .font(.headline)
                        .foregroundStyle(.white)
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.headline)
                            .foregroundStyle(.white)
                    }
                }
            }
            .toolbarBackground(Color(white: 0.15), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .fullScreenCover(isPresented: $showCloseAccount) {
                CloseAccountView()
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct SettingsButton: View {
    let icon: String
    let title: String
    let description: String
    var isDestructive: Bool = false
    var action: (() -> Void)? = nil
    
    var body: some View {
        Button(action: { action?() }) {
            HStack(alignment: .center, spacing: 16) {
                Image(systemName: icon)
                    .font(.title3)
                    .frame(width: 24, height: 24)
                    .foregroundStyle(isDestructive ? .red : .white)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.body)
                        .foregroundStyle(isDestructive ? .red : .white)
                    
                    Text(description)
                        .font(.footnote)
                        .foregroundStyle(isDestructive ? .red.opacity(0.7) : .white.opacity(0.7))
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 20)
            .frame(height: 72)
        }
        .buttonStyle(.plain)
        
        if title != "Close Account" {
            Divider()
                .background(Color.black.opacity(0.3))
                .padding(.vertical, 4)
        }
    }
} 
