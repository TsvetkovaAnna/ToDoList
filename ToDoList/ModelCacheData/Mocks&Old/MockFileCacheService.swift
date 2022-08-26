import Foundation

class MockFileCacheService/*: FileCacheService*/ {
    
    var fileCache = FileCache()
    
    func save(items: [ToDoItem], completion: @escaping ([ToDoItem]) -> Void) {
        fileCache.saveData()
        fileCache.loadData()
        completion(fileCache.items)
    }
    
    func load(/*from url: URL, */completion: @escaping ([ToDoItem]) -> Void) {
        fileCache.loadData()
        completion(fileCache.items)
    }
    
    func add(_ newItem: ToDoItem) {
        fileCache.addItem(item: newItem)
    }
    
    func edit(_ item: ToDoItem) {
        fileCache.refreshItem(item, byId: item.id)
    }
    
    func delete(id: String) {
        fileCache.deleteItem(byId: id)
    }
    
}
