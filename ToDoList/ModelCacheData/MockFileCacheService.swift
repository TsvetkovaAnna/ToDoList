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
    
    func delete(id: String) {
        fileCache.deleteItem(byId: id)
    }
    
}

class MockFileCacheService2 {
    
    let fileCache = FileCache()
    
    func save(to file: String, completion: @escaping (Result<Void, Error>) -> Void) {
        mockLeftOffClosure {
            func unknown() {}
            self.fileCache.saveData()
            completion(.success(unknown()))
        }
    }
    
    func load(from file: String, completion: @escaping (Result<[ToDoItem], Error>) -> Void) {
        mockLeftOffClosure {
            self.fileCache.loadData()
            completion(.success(self.fileCache.items))
        }
    }
    
    func add(_ newItem: ToDoItem) {
        mockLeftOffClosure {
            if self.fileCache.items.firstIndex(where: { $0.id == newItem.id }) != nil {
                self.fileCache.refreshItem(newItem, byId: newItem.id)
            } else {
                self.fileCache.addItem(item: newItem)
            }
            self.fileCache.saveData()
        }
    }
    
    func delete(id: String) {
        mockLeftOffClosure {
            self.fileCache.deleteItem(byId: id)
            self.fileCache.saveData()
        }
    }
    
    private func mockLeftOffClosure(_ completion: @escaping () -> Void) {
        let timeout = TimeInterval.random(in: 1..<3)
        DispatchQueue.main.asyncAfter(deadline: .now() + timeout) {
            completion()
        }
    }
}
