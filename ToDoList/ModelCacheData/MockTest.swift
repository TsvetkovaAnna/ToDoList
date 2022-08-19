//
//  Trash.swift
//  ToDoList
//
//  Created by Anna Tsvetkova on 14.08.2022.
//

import Foundation

class DefaultNetworkingService2 {
    
    private let fileCasheServise = MockFileCacheService2()
    
    private var cacheUrl: URL? {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        return url.appendingPathComponent("ToDoItems.txt")
    }
    
    func getAllTodoItems(completion: @escaping (Result<[ToDoItem], Error>) -> Void) {
        guard let cacheURL = cacheUrl else { return }
        fileCasheServise.load(from: cacheURL.path) { result in
            completion(result)
        }
    }
    
    func editTodoItem(_ item: ToDoItem, completion: @escaping (Result<[ToDoItem], Error>) -> Void) {
        fileCasheServise.add(item)
        getAllTodoItems { result in
            completion(result)
        }
    }
    
    func deleteTodoItem(at id: String, completion: @escaping (Result<[ToDoItem], Error>) -> Void) {
        fileCasheServise.delete(id: id)
        getAllTodoItems { result in
            completion(result)
        }
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
