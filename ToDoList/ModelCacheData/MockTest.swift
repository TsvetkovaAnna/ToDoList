//
//  Trash.swift
//  ToDoList
//
//  Created by Anna Tsvetkova on 14.08.2022.
//

import Foundation

/*
 
 /*
  1. first time -> getAll for revision, isDirty to false
  2. fileCache.items -> patch -> items & fileCache.items, isDirty to false
  
  3. editing -> save to fileCache, items? — isDirty
  4. if isDirty -> patch
  */
 
 perfomInOtherThread {
     guard let cacheURL = self.cacheUrl else { return }
     
     self.networkService.getAllTodoItems { [weak self] result in
         
         guard let self = self else { return }
         
         switch result {
         case .success(let networkItems):
             
             if self.items.isEmpty {
                 self.perfomInMainThread {
                     networkItems.forEach { item in
                         self.fileCacheService.add(item)
                     }
                     self.fileCacheService.save(to: cacheURL.path) { actualItems in
                         self.items = actualItems
                         self.perfomInMainThread {
                             completion()
                         }
                     }
                 }
             } else {
                 self.networkService.saveAllTodoItems(self.items) { _ in
                     self.perfomInMainThread {
                         completion()
                     }
                 }
             }
             
         case .failure(let error):
             DDLogInfo(error)
         }
         
     }
 }
 
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
    
    func editTodoItem(_ item: ToDoItem, completion: @escaping (Result<ToDoItem, Error>) -> Void) {
        fileCasheServise.add(item)
        getAllTodoItems { result in
            completion(result)
        }
    }
    
    func deleteTodoItem(at id: String, completion: @escaping (Result<ToDoItem, Error>) -> Void) {
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
*/
