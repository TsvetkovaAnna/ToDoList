//
//  MockNetworkService.swift
//  ToDoList
//
//  Created by Anna Tsvetkova on 12.08.2022.
//

import Foundation
import Reachability

class MockNetworkService: NetworkService {
    
    func getAllTodoItems(completion: @escaping (Result<[ToDoItem], Error>) -> Void) {

    }
    
    func editTodoItem(_ item: ToDoItem, completion: @escaping (Result<[ToDoItem], Error>) -> Void) {
        
    }
    
    func deleteTodoItem(at id: String, completion: @escaping (Result<[ToDoItem], Error>) -> Void) {
        
    }
    
    func isConnectionAvailable() -> Bool {
        do {
            let reachability = try Reachability()
            
            switch reachability.connection {
            case .unavailable, .none:
                return false
            case .cellular, .wifi:
                return true
            }
        } catch {
            print(error)
        }
        
        return false
    }
}

class MockNetworkService2: NetworkService {
    
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
