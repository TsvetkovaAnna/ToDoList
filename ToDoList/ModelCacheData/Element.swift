import Foundation

struct ListCase: Codable {
    
    var list: [Element]
    var revision: Int32?
    
    init(_ list: [Element]) {
        self.list = list
    }
}

struct ElementCase: Codable {
    
    var element: Element
    var revision: Int32?
    
    init(_ element: Element) {
        self.element = element
    }
}

struct Element: Codable {
    let id: String
    let text: String
    let deadline: Int64?
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
    
    init(id: String, text: String, deadline: Int64?, importance: String, done: Bool, color: String?, createdAt: Int, changedAt: Int, lastUpdatedBy: String) {
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
        try container.encode(deadline, forKey: .deadline)
        try container.encode(importance, forKey: .importance)
        try container.encode(done, forKey: .done)
        try container.encode(color, forKey: .color)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(changedAt, forKey: .changedAt)
        try container.encode(lastUpdatedBy, forKey: .lastUpdatedBy)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        text = try container.decode(String.self, forKey: .text)
        deadline = try container.decodeIfPresent(Int64.self, forKey: .deadline)
        importance = try container.decode(String.self, forKey: .importance)
        done = try container.decode(Bool.self, forKey: .done)
        color = try container.decodeIfPresent(String.self, forKey: .color)
        createdAt = try container.decode(Int.self, forKey: .createdAt)
        changedAt = try container.decode(Int.self, forKey: .changedAt)
        lastUpdatedBy = try container.decode(String.self, forKey: .lastUpdatedBy)
    }
}

extension Element {
    var likeItem: ToDoItem {
        
        var deadlineValue: Date?
        
        if let deadline = deadline {
            deadlineValue = Date(timeIntervalSince1970: Double(deadline))
        }
        
        return ToDoItem(id: id, text: text, importance: ToDoItem.Importance(rawValue: importance) ?? .basic, deadline: deadlineValue, isDone: done, dateCreated: Date(timeIntervalSince1970: Double(createdAt)), dateChanged: Date(timeIntervalSince1970: Double(changedAt)))
    }
}
