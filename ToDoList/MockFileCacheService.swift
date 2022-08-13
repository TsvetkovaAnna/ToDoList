import Foundation

class MockFileCacheService: FileCacheService {
    
    func save(to file: String, completion: @escaping (Result<Void, Error>) -> Void) {
        <#code#>
    }
    
    func load(from file: String, completion: @escaping (Result<[ToDoItem], Error>) -> Void) {
        <#code#>
    }
    
    func add(_ newItem: ToDoItem) {
        <#code#>
    }
    
    func delete(id: String) {
        <#code#>
    }
    
}

class MockFileCacheService2: FileCacheService {
    
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
