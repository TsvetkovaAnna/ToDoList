//
//  GeneralMockService.swift
//  ToDoList
//
//  Created by Anna Tsvetkova on 26.08.2022.
//

import Foundation
import CocoaLumberjack

final class GeneralService: GeneralServiceProtocol {
    
    // MARK: Public
    
    let networkService: NetworkService
    let fileCacheService: FileCacheService
    
    var items = [ToDoItem]()
    var isDirty = true
    
    init(with networkService: NetworkService, fileCacheService: FileCacheService) {
        self.networkService = networkService
        self.fileCacheService = fileCacheService
    }
    
    func load(completion: @escaping (VoidResult) -> Void) {
            
        fileCacheService.load { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let cacheItems):
                self.items = cacheItems
                completion(.success)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func redact(_ action: Redacting, item: ToDoItem, _ completion: @escaping (VoidResult) -> Void) { 
        redactNetworkItem(action, item: item) { [weak self] networkResult in
            guard let self = self else { return }
            self.redactLocally(action, item: item, byResult: networkResult) { result in
                switch result {
                case .success:
                    self.refreshOwnItems(networkResult) { refreshingResult in
                        self.perfomInMainThread { completion(refreshingResult) }
                    }
                case .failure(let error):
                    self.perfomInMainThread { completion(.failure(error)) }
                }
            }
        }
    }
    
    func update(_ completion: @escaping (VoidResult) -> Void) {
        
        func saveFreshItems(_ freshItems: [ToDoItem], _ completion: @escaping (VoidResult) -> Void) {
            items = freshItems
            fileCacheService.save(items: items) { result in
                completion(result)
            }
        }
        
        func saveActualItemsIfAvailable(from result: Result<[ToDoItem], Error>, _ completion: @escaping (VoidResult) -> Void) {
            perfomInMainThread { [weak self] in
                guard let self = self else { return }
                switch result {
                case .failure(let error):
                    completion(.failure(error))
                case .success(let freshItems):
                    self.isDirty = false
                    saveFreshItems(freshItems) { savingResult in
                        switch savingResult {
                        case .failure(let error):
                            completion(.failure(error))
                        case .success:
                            completion(.success)
                        }
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
        
        if networkService.revision != nil {
            syncItems { result in
                completion(result)
            }
        } else {
            networkService.getAllTodoItems { [weak self] gettingResult in
                guard let self = self else { return }
                self.perfomInMainThread {
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
    }
    
    // MARK: Private
    
    private func refreshOwnItems(_ networkResult: Result<ToDoItem, Error>, _ completion: @escaping (VoidResult) -> Void) {
        perfomInMainThread { [weak self] in
            guard let self = self else { return }
            self.fileCacheService.load { cacheResult in
                
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
    }
    
    private func redactNetworkItem(_ action: Redacting, item: ToDoItem, _ completion: @escaping (Result<ToDoItem, Error>) -> Void) {
        update { [weak self] updatingResult in
            guard let self = self else { return }
            switch updatingResult {
            case .success where action == .add:
                self.networkService.addTodoItem(item) { networkResult in
                    completion(networkResult)
                }
            case .success where action == .edit:
                self.networkService.editTodoItem(item) { networkResult in
                    completion(networkResult)
                }
            case .success where action == .delete:
                self.networkService.deleteTodoItem(at: item.id) { networkResult in
                    completion(networkResult)
                }
            case .failure(let error):
                self.perfomInMainThread { completion(.failure(error)) }
            default:
                break
            }
        }
    }
    
    private func redactLocally(_ action: Redacting, item: ToDoItem, byResult networkResult: Result<ToDoItem, Error>, _ completion: @escaping (VoidResult) -> Void) {
        perfomInMainThread { [weak self] in
            guard let self = self else { return }
            switch networkResult {
            case .success where action == .add:
                self.fileCacheService.add(item) { result in
                    completion(result)
                }
            case .success where action == .edit:
                self.fileCacheService.edit(item) { result in
                    completion(result)
                }
            case .success where action == .delete:
                self.fileCacheService.delete(id: item.id) { result in
                    completion(result)
                }
            case .failure(let error):
                completion(.failure(error))
            default:
                break
            }
        }
    }
    
    // MARK: Service
    
    private func perfomInMainThread(_ completion: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            completion()
        }
    }
}
