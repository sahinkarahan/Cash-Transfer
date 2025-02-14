import SwiftUI
import Photos
import PhotosUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    @State private var showProfile = false
    @State private var showLogoutConfirmation = false
    @State private var showPhotoOptions = false
    @State private var showImagePicker = false
    @State private var imageSelection: PhotosPickerItem?
    @State private var showQROperations = false
    @State private var previousTab = 0
    @State private var showSettings = false
    @State private var showTransferOperations = false
    @State private var showMenu = false
    @State private var selectedCardID: Int? = 0
    @State private var selectedCard = 0
    @StateObject private var notificationViewModel = NotificationViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                TabView(selection: $selectedTab) {
                    VStack(spacing: 0) {
                        topBar
                        mainView
                    }
                    .tabItem {
                        VStack {
                            Image(systemName: "house.fill")
                            Text("Home")
                        }
                    }
                    .tag(0)
                    
                    Color(white: 0.15)
                        .ignoresSafeArea()
                        .tabItem {
                            VStack {
                                Image(systemName: "qrcode")
                                Text("QR")
                            }
                        }
                        .tag(1)
                    
                    Color(white: 0.15)
                        .ignoresSafeArea()
                        .tabItem {
                            VStack {
                                Image(systemName: "arrow.left.arrow.right")
                                Text("Transfer")
                            }
                        }
                        .tag(2)
                        .onTapGesture {
                            withAnimation(.spring(duration: 0.3)) {
                                showTransferOperations = true
                            }
                        }
                    
                    TransactionListView()
                        .tabItem {
                            VStack {
                                Image(systemName: "list.clipboard")
                                Text("Payments")
                            }
                        }
                        .tag(3)
                        .onTapGesture {
                            withAnimation(.spring(duration: 0.3)) {
                                selectedTab = previousTab
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    NavigationUtil.navigate(to: TransactionListView())
                                }
                            }
                        }
                    
                    Text("Cash Card")
                        .tabItem {
                            VStack {
                                Image(systemName: "creditcard")
                                Text("Cash Card")
                            }
                        }
                        .tag(4)
                }
                .tint(.white)
                
                // QR Operations View
                if showQROperations {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring(duration: 0.3)) {
                                showQROperations = false
                            }
                        }
                    
                    VStack {
                        Spacer()
                        QROperationsView(
                            onDismiss: {
                                withAnimation(.spring(duration: 0.3)) {
                                    showQROperations = false
                                }
                            }
                        )
                    }
                    .transition(.move(edge: .bottom))
                }
                
                if showProfile {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring(duration: 0.3)) {
                                showProfile = false
                            }
                        }
                    
                    VStack {
                        Spacer()
                        
                        ProfileView(
                            onDismiss: {
                                withAnimation(.spring(duration: 0.3)) {
                                    showProfile = false
                                }
                            },
                            onPhotoOptionsTap: {
                                showPhotoOptions = true
                            },
                            onLogout: {
                                withAnimation(.spring(duration: 0.3)) {
                                    showProfile = false
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        withAnimation(.spring(duration: 0.3)) {
                                            showLogoutConfirmation = true
                                        }
                                    }
                                }
                            }
                        )
                    }
                    .transition(.move(edge: .bottom))
                }
                
                if showPhotoOptions {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring(duration: 0.3)) {
                                showPhotoOptions = false
                            }
                        }
                    
                    VStack {
                        Spacer()
                        
                        ProfilePhotoView(
                            onDismiss: {
                                withAnimation(.spring(duration: 0.3)) {
                                    showPhotoOptions = false
                                }
                            },
                            currentPhotoData: viewModel.userData?.profilePhotoData,
                            onChooseFromGallery: {
                                showImagePicker = true
                            },
                            onRemovePhoto: {
                                Task {
                                    await viewModel.removeProfilePhoto()
                                }
                            }
                        )
                    }
                    .transition(.move(edge: .bottom))
                }
                
                if showLogoutConfirmation {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showLogoutConfirmation = false
                        }
                    
                    LogoutConfirmationView(
                        onCancel: {
                            showLogoutConfirmation = false
                        },
                        onLogout: {
                            withAnimation(.spring(duration: 0.3)) {
                                showLogoutConfirmation = false
                                showProfile = false
                            }
                        }
                    )
                    .environmentObject(AppState.shared)
                    .transition(.scale.combined(with: .opacity))
                }
                
                // Transfer Operations View
                if showTransferOperations {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring(duration: 0.3)) {
                                showTransferOperations = false
                            }
                        }
                    
                    VStack {
                        Spacer()
                        TransferOperationsView(
                            onDismiss: {
                                withAnimation(.spring(duration: 0.3)) {
                                    showTransferOperations = false
                                }
                            }
                        )
                    }
                    .transition(.move(edge: .bottom))
                }
                
                if showMenu {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring(duration: 0.3)) {
                                showMenu = false
                            }
                        }
                    
                    VStack {
                        Spacer()
                        MenuOperationsView(
                            onDismiss: {
                                withAnimation(.spring(duration: 0.3)) {
                                    showMenu = false
                                }
                            }
                        )
                    }
                    .transition(.move(edge: .bottom))
                }
            }
            .animation(.spring(duration: 0.3), value: showProfile)
            .animation(.spring(duration: 0.3), value: showPhotoOptions)
            .animation(.spring(duration: 0.3), value: showLogoutConfirmation)
            .photosPicker(isPresented: $showImagePicker, selection: $imageSelection)
            .onChange(of: imageSelection) { _ in
                handleImageSelection()
            }
            .onChange(of: selectedTab) { newValue in
                if newValue == 1 {
                    withAnimation(.spring(duration: 0.3)) {
                        showQROperations = true
                        selectedTab = selectedTab == 1 ? previousTab : selectedTab // Eğer QR sekmesindeyse önceki sekmeye dön
                    }
                } else if newValue == 2 {
                    withAnimation(.spring(duration: 0.3)) {
                        showTransferOperations = true
                        selectedTab = previousTab // Transfer sekmesinde kalmasını önle
                    }
                } else {
                    previousTab = newValue // Önceki sekmeyi kaydet
                }
            }
            .overlay {
                if viewModel.isLoading {
                    LoadingView(
                        title: viewModel.loadingTitle,
                        description: viewModel.loadingDescription
                    )
                }
            }
            .onAppear {
                // TabBar görünümünü özelleştir
                let appearance = UITabBarAppearance()
                appearance.stackedLayoutAppearance.normal.iconColor = .white.withAlphaComponent(0.7)
                appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white.withAlphaComponent(0.7)]
                appearance.stackedLayoutAppearance.selected.iconColor = .white
                appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.white]
                appearance.backgroundColor = UIColor(white: 0.15, alpha: 1.0)
                appearance.shadowColor = .clear // TabBar üstündeki çizgiyi kaldır
                
                UITabBar.appearance().standardAppearance = appearance
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
            .onReceive(NotificationCenter.default.publisher(for: .showSettings)) { _ in
                withAnimation(.spring(duration: 0.3)) {
                    showSettings = true
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .dismissMenu)) { _ in
                withAnimation(.spring(duration: 0.3)) {
                    showMenu = false
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .refreshHomeData)) { _ in
                Task {
                    await viewModel.fetchUserData()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .profilePhotoUpdated)) { _ in
                Task {
                    await viewModel.fetchUserData()
                }
            }
            .fullScreenCover(isPresented: $showSettings) {
                SettingsView()
            }
        }
    }
    
    private var mainView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Quick Actions Menu
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(alignment: .top, spacing: 16) {
                        QuickActionButton(icon: "megaphone.fill", title: "Announcements")
                        QuickActionButton(icon: "arrow.left.arrow.right", title: "CashBack")
                        QuickActionButton(icon: "globe", title: "International\nMoney\nTransfer")
                        QuickActionButton(icon: "bubble.fill", title: "Chat")
                        QuickActionButton(icon: "airplane", title: "Travel\nPrivileges")
                        QuickActionButton(icon: "chart.line.uptrend.xyaxis", title: "Precious\nMetals")
                        QuickActionButton(icon: "creditcard.fill", title: "Design Your Card")
                        QuickActionButton(icon: "calendar", title: "Monthly Summary")
                        QuickActionButton(icon: "person.2.fill", title: "Invite &\nEarn")
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
                
                // Cards Section
                VStack(spacing: 8) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 8) {
                            AccountSummaryCard(iban: viewModel.userData?.iban ?? "TR49 0000 0000 0000 0000 0000 99")
                                .frame(width: UIScreen.main.bounds.width - 40)
                                .id(0)
                            
                            AssetsCard()
                                .frame(width: UIScreen.main.bounds.width - 40)
                                .id(1)
                        }
                    }
                    .scrollClipDisabled()
                    .scrollTargetLayout()
                    .scrollTargetBehavior(.viewAligned)
                    .scrollPosition(id: $selectedCardID)
                    .onChange(of: selectedCardID) { oldValue, newValue in
                        withAnimation(.easeInOut(duration: 0.3)) {
                            selectedCard = newValue ?? 0
                        }
                    }
                    
                    Spacer()
                        .frame(height: 8)
                    
                    // Page Indicator
                    HStack(spacing: 8) {
                        ForEach(0..<2, id: \.self) { index in
                            Circle()
                                .fill(selectedCard == index ? .white : Color(white: 0.3))
                                .frame(width: 6, height: 6)
                        }
                    }
                    .padding(.top, 4)
                }
                .padding(.horizontal, 20)
                
                // Yeni Experience Section
                VStack(spacing: 12) {
                    // Header
                    HStack {
                        HStack(spacing: 8) {
                            Text("BETTER CASH EXPERIENCE")
                                .font(.caption)
                                .foregroundStyle(Color(white: 0.7))
                            
                            Image(systemName: "arrow.right")
                                .font(.caption)
                                .foregroundStyle(Color(white: 0.7))
                        }
                        
                        Spacer()
                        
                        Text("0 / 5")
                            .font(.caption.bold())
                            .foregroundStyle(Color.yellow)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, -4)
                    
                    // Scrollable Tasks
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 12) {
                            ExperienceTask(
                                icon: "checkmark.seal",
                                title: "Verify Your Account"
                            )
                            
                            ExperienceTask(
                                icon: "creditcard",
                                title: "Request Cash Card"
                            )
                            
                            ExperienceTask(
                                icon: "arrow.down.circle",
                                title: "Deposit Money into Account"
                            )
                            
                            ExperienceTask(
                                icon: "mappin.circle",
                                title: "Add Address"
                            )
                            
                            ExperienceTask(
                                icon: "person.crop.circle",
                                title: "Add Profile Picture"
                            )
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 4) // Bottom shadow için extra padding
                    }
                    .scrollClipDisabled()
                }
                .padding(.vertical, -4)
                
                // İşlemler Başlığı ve Liste
                VStack(spacing: 8) {
                    NavigationLink {
                        TransactionListView()
                            .navigationBarBackButtonHidden(true)
                    } label: {
                        HStack {
                            Text("ACCOUNT TRANSACTIONS")
                                .font(.caption)
                                .foregroundStyle(Color(white: 0.7))
                            
                            Image(systemName: "arrow.right")
                                .font(.caption)
                                .foregroundStyle(Color(white: 0.7))
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Son 5 İşlem
                    VStack(spacing: 1) {
                        ForEach(viewModel.lastTransactions.prefix(5), id: \.id) { transaction in
                            NavigationLink {
                                TransactionDetailView(transaction: transaction)
                                    .navigationBarBackButtonHidden()
                                    .transaction { transaction in
                                        transaction.animation = nil
                                    }
                            } label: {
                                TransactionRow(transaction: transaction)
                            }
                        }
                    }
                    .padding(.vertical, -12)
                }
                .padding(.vertical, -4)
            }
        }
        .background(Color(white: 0.15))
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
    
    private var topBar: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 16) {
                // Left Side
                HStack(spacing: 12) {
                    // Menu Button
                    Button {
                        withAnimation(.spring(duration: 0.3)) {
                            showMenu = true
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal")
                            .font(.title3)
                            .foregroundStyle(.white)
                            .frame(width: 48, height: 48)
                            .background(Color(white: 0.2))
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(white: 0.3), lineWidth: 1)
                    )
                    .overlay(alignment: .topTrailing) {
                        if notificationViewModel.unreadCount > 0 {
                            Text("\(notificationViewModel.unreadCount)")
                                .font(.caption2.bold())
                                .foregroundStyle(.white)
                                .frame(width: 20, height: 20)
                                .background(.red)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                                .offset(x: 8, y: -8)
                        }
                    }
                    
                    // Chat Button
                    Button(action: {
                        // Chat action
                    }) {
                        Image(systemName: "bubble")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .frame(width: 48, height: 48)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(white: 0.3), lineWidth: 1)
                            )
                    }
                }
                
                Spacer()
                
                // Right Side
                HStack(spacing: 12) {
                    // User Info
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(viewModel.userData?.fullName ?? "")
                            .font(.subheadline)
                            .foregroundStyle(Color(white: 0.7))
                        
                        HStack(spacing: 4) {
                            Text("Cash No:")
                                .font(.caption)
                                .foregroundStyle(Color(white: 0.7))
                            
                            Text(viewModel.userData?.idCash ?? "")
                                .font(.caption)
                                .foregroundStyle(.white)
                                .underline()
                        }
                    }
                    
                    // Profile Button
                    Button(action: {
                        showProfile = true
                    }) {
                        if let photoData = viewModel.userData?.profilePhotoData,
                           let imageData = Data(base64Encoded: photoData),
                           let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 48, height: 48)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(white: 0.3), lineWidth: 1)
                                )
                        } else {
                            Image(systemName: "person")
                                .font(.title2)
                                .foregroundStyle(.white)
                                .frame(width: 48, height: 48)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(white: 0.3), lineWidth: 1)
                                )
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 16)
            .background(Color(white: 0.15))
        }
    }
    
    private func handleImageSelection() {
        guard let imageSelection else { return }
        
        Task {
            await viewModel.updateProfilePhoto(with: imageSelection)
        }
    }
}

// Yeni Experience Task Component
struct ExperienceTask: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon Container
            Circle()
                .fill(.white)
                .frame(width: 32, height: 32)
                .overlay {
                    Image(systemName: icon)
                        .font(.body)
                        .foregroundStyle(.black)
                }
            
            // Title
            Text(title)
                .font(.callout)
                .foregroundStyle(.white)
                .lineLimit(2)
                .frame(width: 120, alignment: .leading)
        }
        .padding(.horizontal, 16)
        .frame(height: 64)
        .background(Color(white: 0.2))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(white: 0.3), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
} 
