//
//  MockNetworkService.swift
//  ToDoList
//
//  Created by Anna Tsvetkova on 12.08.2022.
//

import Foundation
//import Reachability

class MockNetworkService: NetworkService {
    
    var mockItems: [ToDoItem] {[
        ToDoItem(text: "Dream", importance: .low, deadline: Date(timeIntervalSinceNow: 3*24*3600)),
        ToDoItem(text: "Work", importance: .basic, deadline: Date(timeIntervalSinceNow: 5*24*3600)),
        ToDoItem(text: "Sleep", importance: .important, deadline: Date(timeIntervalSinceNow: 7*24*3600))
    ]}
    
    func getAllTodoItems(completion: @escaping ([ToDoItem]?) -> Void) {
        mockCompletion { items in
            completion(items)
        }
    }
    
    func saveAllTodoItems(_ items: [ToDoItem], completion: @escaping ([ToDoItem]?) -> Void) {
        mockCompletion { items in
            completion(items)
        }
    }
    
    func addTodoItem(_ item: ToDoItem, completion: @escaping ([ToDoItem]?) -> Void) {
        mockCompletion { items in
            completion(items)
        }
    }
    
    func editTodoItem(_ item: ToDoItem, completion: @escaping ([ToDoItem]?) -> Void) {
        mockCompletion { items in
            completion(items)
        }
    }
    
    func deleteTodoItem(at id: String, completion: @escaping ([ToDoItem]?) -> Void) {
        mockCompletion { items in
            completion(items)
        }
    }
    
    func mockCompletion(completion: @escaping ([ToDoItem]?) -> Void) {
        mockLeftOffClosure {
            if self.isConnectionAvailable() {
                completion(self.mockItems)
            } else {
                completion(nil)
            }
        }
    }
    
    private func mockLeftOffClosure(_ completion: @escaping () -> Void) {
        let timeout = TimeInterval.random(in: 1..<3)
        DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + timeout) {
            completion()
        }
    }
    
    func isConnectionAvailable() -> Bool {
        
        return true
        
//        do {
//            let reachability = try Reachability()
//
//            switch reachability.connection {
//            case .unavailable, .none:
//                return false
//            case .cellular, .wifi:
//                return true
//            }
//        } catch {
//            print(error)
//        }
//
//        return false
    }
}

class MockNetworkService2 {
    
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
