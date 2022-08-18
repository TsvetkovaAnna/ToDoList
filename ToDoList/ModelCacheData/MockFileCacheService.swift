import Foundation

class MockFileCacheService: FileCacheService {
    
    let fileCache = FileCache()
    
    func save(to file: String, completion: @escaping ([ToDoItem]) -> Void) {
        fileCache.saveData(URL(string: file))
        fileCache.loadData(URL(string: file))
        completion(fileCache.items)
    }
    
    func load(from file: String, completion: @escaping ([ToDoItem]) -> Void) {
        fileCache.loadData(URL(string: file))
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
