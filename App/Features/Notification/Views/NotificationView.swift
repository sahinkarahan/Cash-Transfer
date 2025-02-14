import SwiftUI

struct NotificationView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = NotificationViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    colors: [Color(white: 0.15), Color(white: 0.12)],
                    startPoint: .top,
                    endPoint: .bottom
                ).ignoresSafeArea()
                
                if viewModel.isLoading {
                    LoadingView()
                } else if viewModel.notifications.isEmpty {
                    // Boş durum görünümü
                    VStack(spacing: 16) {
                        Image(systemName: "bell.badge")
                            .font(.system(size: 50))
                            .foregroundStyle(Color(white: 0.6))
                        
                        Text("No notifications yet")
                            .font(.title3)
                            .foregroundStyle(Color(white: 0.6))
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Action Buttons
                            HStack {
                                Button {
                                    Task {
                                        await viewModel.markAllAsRead()
                                    }
                                } label: {
                                    Text("Mark All as Read")
                                        .font(.subheadline)
                                        .foregroundStyle(Color(white: 0.7))
                                }
                                
                                Spacer()
                                
                                Button {
                                    Task {
                                        await viewModel.deleteAllNotifications()
                                    }
                                } label: {
                                    Text("Delete All")
                                        .font(.subheadline)
                                        .foregroundStyle(Color(white: 0.7))
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            Divider()
                                .background(Color(white: 0.3))
                                .padding(.horizontal, 20)
                            
                            // Okunmamış Bildirimler
                            if !viewModel.unreadNotifications.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("UNREAD NOTIFICATIONS")
                                        .font(.caption.bold())
                                        .foregroundStyle(Color(white: 0.6))
                                        .padding(.horizontal, 20)
                                    
                                    LazyVStack(spacing: 1) {
                                        ForEach(viewModel.unreadNotifications) { notification in
                                            NotificationRow(notification: notification)
                                        }
                                    }
                                }
                            }
                            
                            // Okunmuş Bildirimler
                            if !viewModel.readNotifications.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("READ NOTIFICATIONS")
                                        .font(.caption.bold())
                                        .foregroundStyle(Color(white: 0.6))
                                        .padding(.horizontal, 20)
                                    
                                    LazyVStack(spacing: 1) {
                                        ForEach(viewModel.readNotifications) { notification in
                                            NotificationRow(notification: notification)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 16)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        NavigationUtil.dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.body.bold())
                            .foregroundStyle(.white)
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("NOTIFICATIONS")
                        .font(.headline.bold())
                        .foregroundStyle(.white)
                }
            }
        }
    }
}

struct NotificationRow: View {
    let notification: NotificationModel
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Sender Initials Circle - Sol tarafa konumlandırıldı
            Circle()
                .fill(Color(white: 0.3))
                .frame(width: 40, height: 40)
                .overlay {
                    Text(notification.senderInitials)
                        .font(.body.bold())
                        .foregroundStyle(.white)
                }
            
            VStack(alignment: .leading, spacing: 4) {
                // Date and Time
                Text(notification.formattedDate)
                    .font(.caption)
                    .foregroundStyle(Color(white: 0.6))
                
                // Sender Name
                if !notification.senderName.isEmpty {
                    Text(notification.senderName)
                        .font(.body.bold())
                        .foregroundStyle(.white)
                }
                
                // Amount
                Text(notification.message)
                    .font(.subheadline)
                    .foregroundStyle(Color(white: 0.7))
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
        .padding()
        .opacity(notification.isRead ? 0.3 : 1.0) // Okunmuş bildirimleri soluk göster
    }
} 
