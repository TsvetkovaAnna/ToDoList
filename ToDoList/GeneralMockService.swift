//
//  GeneralMockService.swift
//  ToDoList
//
//  Created by Anna Tsvetkova on 13.08.2022.
//

import Foundation

class GeneralService {
    
    let networkService: NetworkService
    let fileCacheService: FileCacheService
    
    init(with networkService: NetworkService, fileCacheService: FileCacheService) {
        self.networkService = networkService
        self.fileCacheService = fileCacheService
    }
    
    private var cacheUrl: URL? {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        return url.appendingPathComponent("ToDoItems.txt")
    }
    
    private(set) var items = [ToDoItem]()
    
    func add(_ newItem: ToDoItem) {
        perfomInOtherThread {
            self.update()
            guard let cacheURL = self.cacheUrl else { return }
            self.fileCacheService.add(newItem)
            self.fileCacheService.save(to: cacheURL.path) { actualItems in
                self.items = actualItems
            }
            self.perfomInMainThread {
                self.networkService.addTodoItem(newItem) { _ in }
            }
        }
    }
    
    func delete(_ at: String) {
        perfomInOtherThread {
            self.update()
            guard let cacheURL = self.cacheUrl else { return }
            self.fileCacheService.delete(id: at)
            self.fileCacheService.save(to: cacheURL.path) { actualItems in
                self.items = actualItems
            }
            self.perfomInMainThread {
                self.networkService.deleteTodoItem(at: at) { _ in }
            }
        }
    }
    
    func update() {
        guard let cacheURL = self.cacheUrl else { return }
        
        self.networkService.getAllTodoItems { networkItems in
            
            self.fileCacheService.load(from: cacheURL.path) { cacheItems in
                
                self.items = cacheItems
                
                guard let networkItems = networkItems else { return }
                
                if cacheItems.isEmpty {
                    networkItems.forEach { item in
                        self.fileCacheService.add(item)
                    }
                    self.fileCacheService.save(to: cacheURL.path) { actualItems in
                        self.items = actualItems
                    }
                } else {
                    self.perfomInMainThread {
                        self.networkService.saveAllTodoItems(cacheItems) { _ in }
                    }
                }
            }
        }
    }
    
    private func perfomInOtherThread(_ completion: @escaping () -> Void) {
        DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now()) {
            completion()
        }
    }
    
    private func perfomInMainThread(_ completion: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            completion()
        }
    }
}
