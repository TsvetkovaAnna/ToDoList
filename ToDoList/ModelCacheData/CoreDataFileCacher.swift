//
//  CoreDataFileCacher.swift
//  ToDoList
//
//  Created by Anna Tsvetkova on 25.08.2022.
//

import Foundation

final class CoreDataFileCacher: FileCacheService {
    
    let coreDataManager: CoreDataManager
    
    init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
    }
    
    func save(items: [ToDoItem], completion: @escaping (VoidResult) -> Void) {
        do {
            try coreDataManager.clear()
            
            items.forEach {
                self.add($0) { result in
                switch result {
                case .failure(let error):
                    completion(.failure(error))
                default:
                    break
                }
            } }
            
            completion(.success)
            
        } catch {
            completion(.failure(error))
        }
    }
    
    func load(/*from url: URL, */completion: @escaping (Result<[ToDoItem], Error>) -> Void) {
        do {
            let todos = try coreDataManager.getAllTodos()
            completion(.success(todos))
        } catch {
            completion(.failure(error))
        }
    }
    
    func add(_ newItem: ToDoItem, completion: @escaping (VoidResult) -> Void) {
        do {
            try coreDataManager.createNewTodo(newItem)
            completion(.success)
        } catch {
            completion(.failure(error))
        }
    }
    
    func edit(_ item: ToDoItem, completion: @escaping (VoidResult) -> Void) {
        do {
            try coreDataManager.updateTodo(item)
            completion(.success)
        } catch {
            completion(.failure(error))
        }
    }
    
    func delete(id: String, completion: @escaping (VoidResult) -> Void) {
        do {
            try coreDataManager.deleteTodo(id)
            completion(.success)
        } catch {
            completion(.failure(error))
        }
    }
}
