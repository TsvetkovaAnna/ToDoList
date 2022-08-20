import Foundation

struct Element: Codable {
    let id: String
    let text: String
    let deadline: Int?
    let importance: String
    let done: Bool
    let color: String?
    let createdAt: Int
    let changedAt: Int
    let lastUpdatedBy: String

    enum CodingKeys: String, CodingKey {
        case id, text, deadline, importance, done, color
        case createdAt = "created_at"
        case changedAt = "changed_at"
        case lastUpdatedBy = "last_updated_by"
    }
    
    init(id: String, text: String, deadline: Int?, importance: String, done: Bool, color: String?, createdAt: Int, changedAt: Int, lastUpdatedBy: String) {
        self.id = id
        self.text = text
        self.deadline = deadline
        self.importance = importance
        self.done = done
        self.color = color
        self.createdAt = createdAt
        self.changedAt = changedAt
        self.lastUpdatedBy = lastUpdatedBy
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(text, forKey: .text)
        try container.encode(deadline, forKey: .deadline) //?
        try container.encode(importance, forKey: .importance)
        try container.encode(done, forKey: .done)
        try container.encode(color, forKey: .color) //?
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(changedAt, forKey: .changedAt)
        try container.encode(lastUpdatedBy, forKey: .lastUpdatedBy)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        text = try container.decode(String.self, forKey: .text)
        deadline = try container.decode(Int.self, forKey: .deadline)
        importance = try container.decode(String.self, forKey: .importance)
        done = try container.decode(Bool.self, forKey: .done)
        color = try container.decode(String.self, forKey: .color)
        createdAt = try container.decode(Int.self, forKey: .createdAt)
        changedAt = try container.decode(Int.self, forKey: .changedAt)
        lastUpdatedBy = try container.decode(String.self, forKey: .lastUpdatedBy)
    }
}

struct Welcome: Codable {
    let list: [Element]
    let revision: Int?
    let status: String? //наверно не нужен
}
