
import UIKit

//let date = Date()
//let format = date.getFormatedDate(format: "dd.MM.YYYY")
//extension Date {
//    func getFormatedDate(format: String) -> String {
//        let dateFormat = DateFormatter()
//        dateFormat.dateFormat = format
//        return dateFormat.string(from: self)
//
//    }
//}

struct ToDoItemList {
    
    let todoItems: [ToDoItem]?
    
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

struct ToDoItem {
    
    
    let id: String
    let text: String
    enum ImportanceEnum: String {
        case low
        case basic
        case important
    }
    let importance: ImportanceEnum
    let deadline: Date?
    let toDoDone: Bool
    let dateCreated: Date
    let dateChanged: Date?
    
    private init(dict: [String: Any]) {
        id = dict["id"] as? String ?? UUID().uuidString
        text = dict["text"] as? String ?? ""
        importance = dict["importance"] as? ImportanceEnum ?? ImportanceEnum.basic
        
        if let unixDeadlineString = dict["deadline"] as? String, let unixDeadLine = Double(unixDeadlineString) {
            deadline = Date(timeIntervalSince1970: unixDeadLine)
        } else { deadline = nil }
        
        toDoDone = dict["toDoDone"] as? Bool ?? false
        dateCreated = dict["dateCreated"] as? Date ?? Date.now
        dateChanged = dict["dateChanged"] as? Date ?? nil

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

final class FileCache {
    
    private var arrayToDoItems = [ToDoItem]()
    private let jsonPath = Bundle.main.path(forResource: "fileJSON", ofType: "json")!
    
    func addItem(item: ToDoItem) {
        arrayToDoItems.append(item)
        //saveData()
        
    }
    
    func deleteItem(byId: String) {
        guard let index = arrayToDoItems.firstIndex(where: { $0.id == byId }) else { return }
        arrayToDoItems.remove(at: index)
        //saveData()
    }
    
    func saveData() {
//        for arrayToDoItem in arrayToDoItems {
//            //let js = arrayToDoItem.json
//        }
    }
    
    func loadData() {
        parseFromFile(pathForFile: jsonPath)
    }
    
    func checkData() -> [ToDoItem]? {
        parseFromFile(pathForFile: jsonPath)
    }
    
    @discardableResult func parseFromFile(pathForFile: String) -> [ToDoItem]? {
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: pathForFile))
            guard let dict = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
            else { return nil }
            return ToDoItemList(dict).todoItems
        } catch {
            print(error)
        }
        
        return nil
    }
    
}

