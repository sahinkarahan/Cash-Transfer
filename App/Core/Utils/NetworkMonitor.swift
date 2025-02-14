import Network
import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Combine

@MainActor
final class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor", qos: .utility)
    private let db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    
    @Published private(set) var isConnected = true {
        didSet {
            if isConnected {
                connectionRestoredSubject.send()
            } else {
                resetMonitoring()
            }
        }
    }
    @Published private(set) var isReconnecting = false
    @Published private(set) var connectionQuality: ConnectionQuality = .unknown
    @Published private(set) var hasNetworkPath = true
    
    private let connectionRestoredSubject = PassthroughSubject<Void, Never>()
    var connectionRestoredPublisher: AnyPublisher<Void, Never> {
        connectionRestoredSubject.eraseToAnyPublisher()
    }
    
    private var lastKnownPathStatus: NWPath.Status?
    private var connectionCheckTask: Task<Void, Never>?
    private var periodicCheckTask: Task<Void, Never>?
    private var reachabilityTimer: Timer?
    private var lastConnectionAttempt = Date.distantPast
    
    enum ConnectionQuality: String {
        case unknown, poor, good
        
        var description: String {
            switch self {
            case .unknown: return "Bilinmiyor"
            case .poor: return "Zayıf"
            case .good: return "İyi"
            }
        }
    }
    
    private init() {
        setupMonitoring()
        startPeriodicCheck()
        setupReachabilityTimer()
    }
    
    private func resetMonitoring() {
        connectionCheckTask?.cancel()
        periodicCheckTask?.cancel()
        reachabilityTimer?.invalidate()
        lastKnownPathStatus = nil
        lastConnectionAttempt = Date.distantPast
        
        startPeriodicCheck()
        setupReachabilityTimer()
    }
    
    private func setupMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                
                let newStatus = path.status
                let previousStatus = self.lastKnownPathStatus
                self.lastKnownPathStatus = newStatus
                
                self.connectionCheckTask?.cancel()
                self.hasNetworkPath = newStatus == .satisfied
                
                if newStatus == .satisfied {
                    if previousStatus == .unsatisfied {
                        self.resetMonitoring()
                    }
                    self.connectionCheckTask = Task {
                        await self.handlePathUpdate(path)
                    }
                } else {
                    withAnimation(.spring(duration: 0.3)) {
                        self.isConnected = false
                        self.connectionQuality = .unknown
                    }
                }
            }
        }
        monitor.start(queue: queue)
    }
    
    private func setupReachabilityTimer() {
        reachabilityTimer?.invalidate()
        reachabilityTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self = self,
                      !self.isConnected,
                      Date().timeIntervalSince(self.lastConnectionAttempt) > 3.0 else { return }
                
                await self.checkFirebaseConnection()
            }
        }
    }
    
    private func startPeriodicCheck() {
        periodicCheckTask?.cancel()
        periodicCheckTask = Task {
            while !Task.isCancelled {
                if hasNetworkPath && !isConnected {
                    await checkFirebaseConnection()
                }
                try? await Task.sleep(nanoseconds: 3_000_000_000) // 3 saniye
            }
        }
    }
    
    private func handlePathUpdate(_ path: NWPath) async {
        guard path.status == .satisfied else {
            withAnimation(.spring(duration: 0.3)) {
                self.isConnected = false
                self.connectionQuality = .unknown
            }
            return
        }
        
        await checkFirebaseConnection()
    }
    
    private func checkFirebaseConnection() async {
        guard !Task.isCancelled else { return }
        lastConnectionAttempt = Date()
        
        guard Auth.auth().currentUser != nil else {
            withAnimation(.spring(duration: 0.3)) {
                isConnected = hasNetworkPath
                connectionQuality = hasNetworkPath ? .good : .unknown
            }
            return
        }
        
        let startTime = Date()
        
        do {
            let document = try await db.collection("system").document("status").getDocument()
            let responseTime = Date().timeIntervalSince(startTime)
            let quality: ConnectionQuality = responseTime < 1.0 ? .good : .poor
            
            if !Task.isCancelled {
                withAnimation(.spring(duration: 0.3)) {
                    isConnected = true
                    connectionQuality = quality
                }
            }
        } catch {
            if !Task.isCancelled {
                withAnimation(.spring(duration: 0.3)) {
                    isConnected = false
                    connectionQuality = .unknown
                }
            }
        }
    }
    
    func retryConnection() async -> Bool {
        guard !isReconnecting else { return false }
        isReconnecting = true
        
        defer { isReconnecting = false }
        
        guard hasNetworkPath else { return false }
        
        await checkFirebaseConnection()
        return isConnected
    }
    
    deinit {
        reachabilityTimer?.invalidate()
        periodicCheckTask?.cancel()
        connectionCheckTask?.cancel()
        monitor.cancel()
        cancellables.forEach { $0.cancel() }
    }
} 
