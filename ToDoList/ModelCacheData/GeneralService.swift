//
//  GeneralMockService.swift
//  ToDoList
//
//  Created by Anna Tsvetkova on 13.08.2022.
//

import Foundation
import CocoaLumberjack

class GeneralService: GeneralServiceProtocol {
    
    let networkService: NetworkService
    let fileCacheService: FileCacheService
    
    private var cacheUrl: URL? {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        return url.appendingPathComponent("ToDoItems.txt")
    }
    
    var items = [ToDoItem]()
    
    init(with networkService: NetworkService, fileCacheService: FileCacheService) {
        self.networkService = networkService
        self.fileCacheService = fileCacheService
        
        guard let cacheURL = self.cacheUrl else { return }
            
        self.fileCacheService.load(from: cacheURL.path) { [weak self] cacheItems in
            guard let self = self else { return }
            self.items = cacheItems
        }
    }
    
    func edit(_ item: ToDoItem) {
        perfomInOtherThread {
            self.update {
                guard let cacheURL = self.cacheUrl else { return }
                
                self.networkService.editTodoItem(item) { _ in
                    self.perfomInMainThread {
                        self.fileCacheService.edit(item)
                        self.fileCacheService.save(to: cacheURL.path) { [weak self] actualItems in
                            guard let self = self else { return }
                            self.items = actualItems
                        }
                    }
                }
            }
        }
    }
    
    func add(_ newItem: ToDoItem) {
        perfomInOtherThread {
            self.update {
                guard let cacheURL = self.cacheUrl else { return }
                
                self.networkService.addTodoItem(newItem) { _ in
                    self.perfomInMainThread {
                        self.fileCacheService.add(newItem)
                        self.fileCacheService.save(to: cacheURL.path) { [weak self] actualItems in
                            guard let self = self else { return }
                            self.items = actualItems
                        }
                    }
                }
            }
        }
    }
    
    func delete(_ at: String) {
        perfomInOtherThread {
            self.update {
                guard let cacheURL = self.cacheUrl else { return }
                
                self.networkService.deleteTodoItem(at: at) { _ in
                    self.perfomInMainThread {
                        self.fileCacheService.delete(id: at)
                        self.fileCacheService.save(to: cacheURL.path) { [weak self] actualItems in
                            guard let self = self else { return }
                            self.items = actualItems
                        }
                    }
                }
            }
        }
    }
    
    func update(_ completion: @escaping () -> Void) { // ?laod
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
                                completion()
                            }
                        }
                    } else {
                        self.networkService.saveAllTodoItems(self.items) { _ in
                            completion()
                        }
                    }
                    
                case .failure(let error):
                    DDLogInfo(error)
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
