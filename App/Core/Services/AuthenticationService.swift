import Foundation
import FirebaseAuth
import FirebaseFirestore
import SwiftUI

protocol AuthenticationServiceProtocol {
    func createUser(email: String, password: String) async throws -> AuthDataResult
    func signIn(email: String, password: String) async throws -> AuthDataResult
    func signOut() throws
    func generateUniqueIdCash() async throws -> String
    var currentUser: User? { get }
}

final class AuthenticationService: AuthenticationServiceProtocol {
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    
    var currentUser: User? {
        auth.currentUser
    }
    
    func generateUniqueIdCash() async throws -> String {
        let usersRef = db.collection("users")
        var isUnique = false
        var idCash = ""
        
        while !isUnique {
            // 10 haneli rastgele sayı oluştur
            let randomNumber = Int.random(in: 1000000000...9999999999)
            idCash = String(randomNumber)
            
            // Firestore'da bu idCash'in kullanılıp kullanılmadığını kontrol et
            let query = usersRef.whereField("idCash", isEqualTo: idCash)
            let snapshot = try await query.getDocuments()
            
            if snapshot.documents.isEmpty {
                isUnique = true
            }
        }
        
        return idCash
    }
    
    private func generateUniqueIBAN() async throws -> String {
        let usersRef = db.collection("users")
        var isUnique = false
        var iban = ""
        
        while !isUnique {
            // 24 haneli rastgele sayı oluştur
            var randomDigits = ""
            for _ in 1...24 {
                randomDigits += String(Int.random(in: 0...9))
            }
            
            // IBAN formatını oluştur (TR + 24 haneli sayı)
            iban = "TR" + randomDigits
            
            // 4'er haneli gruplar halinde formatla
            iban = stride(from: 0, to: iban.count, by: 4).map {
                let start = iban.index(iban.startIndex, offsetBy: $0)
                let end = iban.index(start, offsetBy: min(4, iban.count - $0))
                return String(iban[start..<end])
            }.joined(separator: " ")
            
            // Firestore'da bu IBAN'ın kullanılıp kullanılmadığını kontrol et
            let query = usersRef.whereField("iban", isEqualTo: iban)
            let snapshot = try await query.getDocuments()
            
            if snapshot.documents.isEmpty {
                isUnique = true
            }
        }
        
        return iban
    }
    
    func createUser(email: String, password: String) async throws -> AuthDataResult {
        try await auth.createUser(withEmail: email, password: password)
    }
    
    func signIn(email: String, password: String) async throws -> AuthDataResult {
        try await auth.signIn(withEmail: email, password: password)
    }
    
    func signOut() throws {
        try auth.signOut()
    }
    
    func saveUserData(userId: String, phoneNumber: String, fullName: String, email: String) async throws {
        let idCash = try await generateUniqueIdCash()
        let iban = try await generateUniqueIBAN()
        
        try await db.collection("users").document(userId).setData([
            "phoneNumber": phoneNumber,
            "fullName": fullName,
            "email": email,
            "idCash": idCash,
            "iban": iban,
            "createdAt": FieldValue.serverTimestamp(),
            "bankAccount": [
                "balanceTL": 0.0,
                "balanceUSD": 0.0,
                "transactions": []
            ]
        ])
    }
} 
