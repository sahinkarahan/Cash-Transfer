import Foundation

struct NotificationModel: Identifiable, Codable {
    let id: String
    let title: String
    let message: String
    let date: Date
    var isRead: Bool
    let senderName: String
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy HH:mm"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: date)
    }
    
    var senderInitials: String {
        let components = senderName.components(separatedBy: " ")
        let initials = components.compactMap { $0.first }
        return String(initials.prefix(2))
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case message
        case date
        case isRead
        case senderName
    }
    
    init(id: String = UUID().uuidString,
         title: String,
         message: String,
         date: Date,
         isRead: Bool,
         senderName: String) {
        self.id = id
        self.title = title
        self.message = message
        self.date = date
        self.isRead = isRead
        self.senderName = senderName
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        message = try container.decode(String.self, forKey: .message)
        let timestamp = try container.decode(TimeInterval.self, forKey: .date)
        date = Date(timeIntervalSince1970: timestamp)
        isRead = try container.decode(Bool.self, forKey: .isRead)
        senderName = try container.decode(String.self, forKey: .senderName)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(message, forKey: .message)
        try container.encode(date.timeIntervalSince1970, forKey: .date)
        try container.encode(isRead, forKey: .isRead)
        try container.encode(senderName, forKey: .senderName)
    }
    
    init?(dictionary: [String: Any], id: String) {
        guard let title = dictionary["title"] as? String,
              let message = dictionary["message"] as? String,
              let timestamp = dictionary["date"] as? TimeInterval,
              let isRead = dictionary["isRead"] as? Bool,
              let senderName = dictionary["senderName"] as? String else {
            return nil
        }
        
        self.id = id
        self.title = title
        self.message = message
        self.date = Date(timeIntervalSince1970: timestamp)
        self.isRead = isRead
        self.senderName = senderName
    }
    
    var dictionary: [String: Any] {
        return [
            "title": title,
            "message": message,
            "date": date.timeIntervalSince1970,
            "isRead": isRead,
            "senderName": senderName
        ]
    }
} 