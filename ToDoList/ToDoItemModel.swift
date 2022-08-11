
import UIKit

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

enum ImportanceEnum: String {
    case low
    case basic
    case important
}

struct ToDoItem: Equatable {
    
    
    let id: String
    let text: String
    let importance: ImportanceEnum
    let deadline: Date?
    let toDoDone: Bool
    let dateCreated: Date
    let dateChanged: Date?
    
    init(text: String, importance: ImportanceEnum, deadline: Date?) {
        self.id = UUID().uuidString
        self.text = text
        self.importance = importance
        self.deadline = deadline
        self.toDoDone = false
        self.dateCreated = Date()
        self.dateChanged = nil
    }
    
    private init(dict: [String: Any]) {
        
        id = dict["id"] as? String ?? UUID().uuidString
        text = dict["text"] as? String ?? ""
        importance = dict["importance"] as? ImportanceEnum ?? ImportanceEnum.basic
        toDoDone = dict["toDoDone"] as? Bool ?? false
        
        func dateByKey(_ key: String) -> Date? {
            guard let unixDeadline = dict[key] as? Int64 else { return nil }
            return Date(timeIntervalSince1970: Double(unixDeadline))
        }
        
        deadline = dateByKey("deadline")
        dateChanged = dateByKey("dateChanged")
        dateCreated = dateByKey("dateCreated") ?? Date.now
    }
}

extension ToDoItem {
    
    var json: [String: Any] {
        
        var dict: [String: Any] = [:]
        dict["id"] = id
        dict["text"] = text
        if importance != .basic { dict["importance"] = importance.rawValue }
        if let deadline = deadline { dict["deadline"] = deadline.timeIntervalSince1970 }
        dict["toDoDone"] = toDoDone
        dict["dateCreated"] = dateCreated.timeIntervalSince1970
        dict["dateChanged"] = dateChanged?.timeIntervalSince1970
        return dict
    }
    
    
    static func parse(json: [String: Any]) -> ToDoItem? {
       ToDoItem(dict: json)
    }

}

//final class FileCache {
//
//    init() {
//        loadData()
//    }
//
//    private let fileManager = FileManager.default
//
//    private var docUrl: URL? {
//        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
//    }
//
//    private var cacheUrl: URL? {
//        guard let url = docUrl else { return nil }
//        print(url)
//        return url.appendingPathComponent("ToDoItems.txt")
//    }
//
//    private var arrayToDoItems = [ToDoItem]()
//    private var jsonPath: String? {
//        Bundle.main.path(forResource: "fileJSON", ofType: "json")
//    }
//
//    func addItem(item: ToDoItem) {
//        arrayToDoItems.append(item)
//        saveData()
//    }
//
//    func deleteItem(byId: String) {
//        guard let index = arrayToDoItems.firstIndex(where: { $0.id == byId }) else { return }
//        arrayToDoItems.remove(at: index)
//        saveData()
//    }
//
//    func saveData() {
//        guard let cacheUrl = cacheUrl,
//              arrayToDoItems.count > 0,
//              let jsonData = ToDoItemList.json(fromItems: arrayToDoItems)
//        else { return }
//
//        fileManager.createFile(atPath: cacheUrl.path, contents: jsonData)
//    }
//
//    func loadLast() -> ToDoItem? {
//        arrayToDoItems.last
//    }
//
//    func loadData() {
//
//        var parsed: [ToDoItem]? = nil
//
//        parsed = parseCache()
//
//        if parsed == nil {
//            guard let path = jsonPath else { return }
//            parsed = parseFromFile(pathForFile: path)
//        }
//
//        guard let parsedItems = parsed else { return }
//
//        arrayToDoItems = parsedItems
//    }
//
////    func checkData() -> [ToDoItem]? {
////        guard let path = jsonPath else { return nil }
////        return parseFromFile(pathForFile: path)
////    }
////
////    var checkTodoItems: [ToDoItem] {
////        arrayToDoItems
////    }
//
//    func parseCache() -> [ToDoItem]? {
//
//        guard let cacheUrl = cacheUrl else { return nil }
//
//        do {
//            let cacheData = try Data(contentsOf: cacheUrl)
//            guard let cacheDict = try JSONSerialization.jsonObject(with: cacheData, options: .allowFragments) as? [String: [[String: Any]]]
//            else { return nil }
//
//            return ToDoItemList(cacheDict).todoItems
//
//        } catch {
//            print(error)
//        }
//
//        return nil
//    }
//
//    @discardableResult func parseFromFile(pathForFile: String) -> [ToDoItem]? {
//
//        do {
//            let data = try Data(contentsOf: URL(fileURLWithPath: pathForFile))
//            guard let dict = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
//            else { return nil }
//            return ToDoItemList(dict).todoItems
//        } catch {
//            print(error)
//        }
//
//        return nil
//    }
//
//}

