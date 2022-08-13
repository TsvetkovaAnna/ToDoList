import UIKit

enum Importance: String {
    case low
    case basic
    case important
}

struct ToDoItem: Equatable {
    
    let id: String
    let text: String
    let importance: Importance
    let deadline: Date?
    let isDone: Bool
    let dateCreated: Date
    let dateChanged: Date?
    
    init(text: String, importance: Importance, deadline: Date?) {
        self.id = UUID().uuidString
        self.text = text
        self.importance = importance
        self.deadline = deadline
        self.isDone = false
        self.dateCreated = Date()
        self.dateChanged = nil
    }
    
    private init(dict: [String: Any]) {
        
        self.id = dict["id"] as? String ?? UUID().uuidString
        self.text = dict["text"] as? String ?? ""
        self.importance = Importance(rawValue: (dict["importance"] as? String) ?? "basic") ?? Importance.basic
        self.isDone = dict["toDoDone"] as? Bool ?? false
        
        func dateByKey(_ key: String) -> Date? {
            guard let unixDeadline = dict[key] as? Int64 else { return nil }
            return Date(timeIntervalSince1970: Double(unixDeadline))
        }
        
        self.deadline = dateByKey("deadline")
        self.dateChanged = dateByKey("dateChanged")
        self.dateCreated = dateByKey("dateCreated") ?? Date.now
    }
}

extension ToDoItem {
    
    var json: [String: Any] {
        
        var dict: [String: Any] = [:]
        dict["id"] = id
        dict["text"] = text
        if importance != .basic { dict["importance"] = importance.rawValue; print("importance.rawValue", importance.rawValue) }
        if let deadline = deadline { dict["deadline"] = deadline.timeIntervalSince1970 }
        dict["toDoDone"] = isDone
        dict["dateCreated"] = dateCreated.timeIntervalSince1970
        dict["dateChanged"] = dateChanged?.timeIntervalSince1970
        return dict
    }
    
    static func parse(json: [String: Any]) -> ToDoItem? {
       ToDoItem(dict: json)
    }
}

struct ToDoItemList {
    
    let todoItems: [ToDoItem]?
    
    static func json(fromItems todoItems: [ToDoItem]) -> Data? {
        
        var jsonArray = [[String: Any]]()
        
        for item in todoItems {
            jsonArray.append(item.json)
        }
        
        do {
            return try JSONSerialization.data(withJSONObject: ["list": jsonArray])
        } catch {
            print(error)
        }
        
        return nil
    }
    
    init(_ dict: [String: Any]) {
        guard let list = dict["list"] as? [[String: Any]] else {
            todoItems = nil
            return
        }
        var items = [ToDoItem]()
        for item in list {
            guard let todoItem = ToDoItem.parse(json: item) else { continue }
            items.append(todoItem)
        }
        todoItems = items
    }
}