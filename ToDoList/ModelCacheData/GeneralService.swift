//
//  GeneralMockService.swift
//  ToDoList
//
//  Created by Anna Tsvetkova on 26.08.2022.
//

import Foundation
import CocoaLumberjack

class GeneralService: GeneralServiceProtocol {
    
    let networkService: NetworkService
    let fileCacheService: FileCacheService
    
    var items = [ToDoItem]()
    var isDirty = true
    
    init(with networkService: NetworkService, fileCacheService: FileCacheService) {
        self.networkService = networkService
        self.fileCacheService = fileCacheService
    }
    
    func load(completion: @escaping (VoidResult) -> Void) {
            
        fileCacheService.load { result in
            
            switch result {
            case .success(let cacheItems):
                self.items = cacheItems
                completion(.success)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /*
     switch result {
     case .success:
         
     case .failure(let error):
         completion(.failure(error))
     }
     */
    
    func edit(_ item: ToDoItem, _ completion: @escaping (VoidResult) -> Void) {
        self.update { updatingResult in
            switch updatingResult {
            case .success:
                self.networkService.editTodoItem(item) { networkResult in
                    switch networkResult {
                    case .success:
                        self.fileCacheService.edit(item) { editingResult in
                            switch editingResult {
                            case .success:
                                self.refreshOwnItems(networkResult) { refreshingResult in
                                    self.perfomInMainThread { completion(refreshingResult) }
                                }
                            case .failure(let error):
                                self.perfomInMainThread { completion(.failure(error)) }
                            }
                        }
                    case .failure(let error):
                        self.perfomInMainThread { completion(.failure(error)) }
                    }
                }
            case .failure(let error):
                self.perfomInMainThread { completion(.failure(error)) }
            }
        }
    }
    
    func add(_ newItem: ToDoItem, _ completion: @escaping (VoidResult) -> Void) {
        self.update { updatingResult in
            switch updatingResult {
            case .success:
                self.networkService.addTodoItem(newItem) { networkResult in
                    switch networkResult {
                    case .success:
                        self.fileCacheService.add(newItem) { editingResult in
                            switch editingResult {
                            case .success:
                                self.refreshOwnItems(networkResult) { refreshingResult in
                                    self.perfomInMainThread { completion(refreshingResult) }
                                }
                            case .failure(let error):
                                self.perfomInMainThread { completion(.failure(error)) }
                            }
                        }
                    case .failure(let error):
                        self.perfomInMainThread { completion(.failure(error)) }
                    }
                }
            case .failure(let error):
                self.perfomInMainThread { completion(.failure(error)) }
            }
        }
    }
     
    func delete(_ at: String, _ completion: @escaping (VoidResult) -> Void) {
        self.update { updatingResult in
            switch updatingResult {
            case .success:
                self.networkService.deleteTodoItem(at: at) { networkResult in
                    switch networkResult {
                    case .success:
                        self.fileCacheService.delete(id: at) { editingResult in
                            switch editingResult {
                            case .success:
                                self.refreshOwnItems(networkResult) { refreshingResult in
                                    self.perfomInMainThread { completion(refreshingResult) }
                                }
                            case .failure(let error):
                                self.perfomInMainThread { completion(.failure(error)) }
                            }
                        }
                    case .failure(let error):
                        self.perfomInMainThread { completion(.failure(error)) }
                    }
                }
            case .failure(let error):
                self.perfomInMainThread { completion(.failure(error)) }
            }
        }
    }
    
    func update(_ completion: @escaping (VoidResult) -> Void) {
        
        func saveFreshItems(_ freshItems: [ToDoItem], _ completion: @escaping (VoidResult) -> Void) {
            self.items = freshItems
            self.fileCacheService.save(items: self.items) { result in
                completion(result)
            }
        }
        
        func saveActualItemsIfAvailable(from result: Result<[ToDoItem], Error>, _ completion: @escaping (VoidResult) -> Void) {
            
            switch result {
            case .failure(let error):
                perfomInMainThread { completion(.failure(error)) }
            case .success(let freshItems):
                self.isDirty = false
                saveFreshItems(freshItems) { savingResult in
                    switch savingResult {
                    case .failure(let error):
                        self.perfomInMainThread { completion(.failure(error)) }
                    case .success:
                        self.perfomInMainThread { completion(.success) }
                    }
                }
            }
        }
        
        func syncItems(_ completion: @escaping (VoidResult) -> Void) {
            networkService.saveAllTodoItems(items) { networkResult in
                saveActualItemsIfAvailable(from: networkResult) { savingResult in
                    completion(savingResult)
                }
            }
        }
        
        if self.networkService.revision != nil {
            syncItems { result in
                completion(result)
            }
        } else {
            self.networkService.getAllTodoItems { gettingResult in
                self.fileCacheService.load { loadingResult in
                    switch loadingResult {
                    case .success(let actualItems):
                        actualItems.isEmpty ?
                        saveActualItemsIfAvailable(from: gettingResult) { savingResult in
                            completion(savingResult)
                        } :
                        syncItems { syncingResult in
                            completion(syncingResult)
                        }
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
        }
    }
    
    func refreshOwnItems(_ networkResult: Result<ToDoItem, Error>, _ completion: @escaping (VoidResult) -> Void) {
            
        self.fileCacheService.load { [weak self] cacheResult in
            guard let self = self else { return }
            
            switch cacheResult {
            case .success(let actualItems):
                self.items = actualItems
                
                switch networkResult {
                case .failure(_):
                    self.isDirty = true
                case .success(_):
                    self.isDirty = false
                }
                
                completion(.success)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func perfomInMainThread(_ completion: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            completion()
        }
    }
}
