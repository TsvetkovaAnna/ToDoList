//
//  MockNetworkService.swift
//  ToDoList
//
//  Created by Anna Tsvetkova on 12.08.2022.
//

import Foundation
// import Reachability

enum Request {
    case get, post
}

class MockNetworkService: NetworkService {
    
    let baseURL = URL(string: "https://google.com/request/")
    
    func getAllTodoItems(completion: @escaping ([ToDoItem]?) -> Void) {
        
        guard let url = baseURL?.appendingPathComponent("getAll") else { return }
        
        request(.get, url: url) { items in
            completion(items)
        }
    }
    
    func saveAllTodoItems(_ items: [ToDoItem], completion: @escaping ([ToDoItem]?) -> Void) {
        
        guard let url = baseURL?.appendingPathComponent("saveAll"),
              let json = ToDoItemList.json(fromItems: items) else { return }
        
        let parameters = [
            "list": json
        ]
        
        request(.post, url: url, parameters: parameters) { items in
            completion(items)
        }
    }
    
    func addTodoItem(_ item: ToDoItem, completion: @escaping ([ToDoItem]?) -> Void) {
        
        guard let url = baseURL?.appendingPathComponent("add") else { return }
        
        request(.post, url: url, parameters: item.json) { items in
            completion(items)
        }
    }
    
    func editTodoItem(_ item: ToDoItem, completion: @escaping ([ToDoItem]?) -> Void) {
        
        guard let url = baseURL?.appendingPathComponent("edit") else { return }
        
        request(.post, url: url, parameters: item.json) { items in
            completion(items)
        }
    }
    
    func deleteTodoItem(at id: String, completion: @escaping ([ToDoItem]?) -> Void) {
        
        guard let url = baseURL?.appendingPathComponent("delete") else { return }
        
        let parameters = [
            "id": id
        ]
        
        request(.post, url: url, parameters: parameters) { items in
            completion(items)
        }
    }
    
    func request(_ type: Request, url: URL, parameters: [String: Any]? = nil, completion: @escaping ([ToDoItem]?) -> Void) {
        mockCompletion { items in
            completion(items)
        }
    }
    
    func mockCompletion(completion: @escaping ([ToDoItem]?) -> Void) {
        mockLeftOffClosure {
            if self.isConnectionAvailable() {
                guard let mockServerData = MockServer.mockServerData else { return }
                completion(mockServerData.parseToItems())
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
        
        /*do {
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

        return false*/
    }
}

extension ToDoItem {
    func parameters() -> [String: Any] {
        var parameters = [
            "id":          id,
            "text":        text,
            "importance":  importance.rawValue,
            "isDone":      isDone,
            "dateCreated": dateCreated.inString(withYear: true)
        ] as [String : Any]
        
        if let deadline = deadline?.inString(withYear: true) {
            parameters["deadline"] = deadline
        }
        
        if let dateChanged = dateChanged?.inString(withYear: true) {
            parameters["dateChanged"] = dateChanged
        }
        
        return parameters
    }
}
