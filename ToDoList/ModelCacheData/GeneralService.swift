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
    var isDirty = true
    
    init(with networkService: NetworkService, fileCacheService: FileCacheService) {
        self.networkService = networkService
        self.fileCacheService = fileCacheService
    }
    
    func load(completion: @escaping () -> Void) {
        guard let cacheURL = self.cacheUrl else { return }
            
        self.fileCacheService.load(from: cacheURL.path) { [weak self] cacheItems in
            guard let self = self else { return }
            self.items = cacheItems
            completion()
        }
    }
    
    func edit(_ item: ToDoItem) {
        print(#function)
        perfomInOtherThread {
            self.update {
                self.networkService.editTodoItem(item) { result in
                    self.perfomInMainThread {
                        self.fileCacheService.edit(item)
                        self.saveChangeToFileCache(result)
                    }
                }
            }
        }
    }
    
    func add(_ newItem: ToDoItem) {
        print(#function)
        perfomInOtherThread {
            self.update {
                self.networkService.addTodoItem(newItem) { result in
                    self.perfomInMainThread {
                        self.fileCacheService.add(newItem)
                        self.saveChangeToFileCache(result)
                    }
                }
            }
        }
    }
    
    func delete(_ at: String, _ completion: @escaping () -> Void) {
        print(#function)
        perfomInOtherThread {
            self.update {
                self.networkService.deleteTodoItem(at: at) { result in
                    self.perfomInMainThread {
                        self.fileCacheService.delete(id: at)
                        print("c:", self.fileCacheService.fileCache.items.count)
//                        self.fileCacheService.save(to: self.cacheUrl!.path) { _ in
                            self.saveChangeToFileCache(result)
                            completion()
//                        }
                    }
                }
            }
        }
    }
    
    func update(_ completion: @escaping () -> Void) {
        print(#function)
        
        func saveFreshItems(_ freshItems: [ToDoItem]) {
            self.items = freshItems
            self.fileCacheService.fileCache.items = self.items
        }
        
        func saveActualItemsIfAvailable(from result: Result<[ToDoItem], Error>)  {
            switch result {
            case .failure(let error):
                DDLogInfo(error)
            case .success(let freshItems):
                self.isDirty = false
                saveFreshItems(freshItems)
            }
            
            self.perfomInMainThread {
                completion()
            }
        }
        
        func syncItems() {
            networkService.saveAllTodoItems(items) { result in
                saveActualItemsIfAvailable(from: result)
            }
        }
        
        perfomInOtherThread {
            if self.networkService.revision != nil {
                syncItems()
            } else {
                self.networkService.getAllTodoItems { result in
                    if self.fileCacheService.fileCache.items.isEmpty {
                        saveActualItemsIfAvailable(from: result)
                    } else {
                        syncItems()
                    }
                }
            }
        }
    }
    
    func saveChangeToFileCache(_ result: Result<ToDoItem, Error>) {
        guard let cacheURL = self.cacheUrl else { return }
            
        self.fileCacheService.load(from: cacheURL.path) { [weak self] actualItems in
            guard let self = self else { return }
            self.items = actualItems
            print("c2:", self.items.count)
            switch result {
            case .failure(_):
                self.isDirty = true
            case .success(_):
                self.isDirty = false
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
