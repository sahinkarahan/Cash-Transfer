import SwiftUI

struct UserData: Codable {
    let fullName: String
    let email: String
    let phoneNumber: String
    let idCash: String
    let iban: String
    let profilePhotoData: String?
    let createdAt: Date
    var bankAccount: BankAccount
    
    enum CodingKeys: String, CodingKey {
        case fullName
        case email
        case phoneNumber
        case idCash
        case iban
        case profilePhotoData
        case createdAt
        case bankAccount
    }
}

struct BankAccount: Codable {
    var balanceTL: Double
    var balanceUSD: Double
    var transactions: [Transaction]
    
    enum CodingKeys: String, CodingKey {
        case balanceTL
        case balanceUSD
        case transactions
    }
}

struct Transaction: Codable {
    let id: String
    let type: TransactionType
    let amount: Double
    let currency: Currency
    let date: Date
    let senderID: String?
    let receiverID: String?
    let status: TransactionStatus
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case amount
        case currency
        case date
        case senderID
        case receiverID
        case status
        case message
    }
}

enum TransactionType: String, Codable {
    case deposit
    case withdraw
    case send
    case receive
}

enum Currency: String, Codable {
    case TL
    case USD
}

enum TransactionStatus: String, Codable {
    case pending
    case completed
    case failed
} 
