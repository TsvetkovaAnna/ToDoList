//
//  DefaultNetworkingService.swift
//  ToDoList
//
//  Created by Anna Tsvetkova on 12.08.2022.
//

import Foundation
// import Reachability

enum Request {
    case get, post
}

enum NetworkError: Error {
    case noConnection
    case badParsing
}

class DefaultNetworkingService: NetworkService {
    
    let baseURL = URL(string: "https://beta.mrdekk.ru/todobackend")
    let urlSession: URLSession
    
    init() {
        //super.init()
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        self.urlSession = URLSession(configuration: configuration)
    }
    
    func getTodoItem(completion: @escaping (Result<[ToDoItem], Error>) -> Void) {
        
        guard let url = baseURL?.appendingPathComponent("get") else { return }
        
        request(.get, url: url) { result in
            completion(result)
        }
    }
    
    func getAllTodoItems(completion: @escaping (Result<[ToDoItem], Error>) -> Void) {
        
        guard let url = baseURL?.appendingPathComponent("getAll") else { return }
        
        request(.get, url: url) { result in
            completion(result)
        }
    }
    
    func saveAllTodoItems(_ items: [ToDoItem], completion: @escaping (Result<[ToDoItem], Error>) -> Void) {
        
        guard let url = baseURL?.appendingPathComponent("saveAll"),
              let json = ToDoItemList.json(fromItems: items) else { return }
        
        let parameters = [
            "list": json
        ]
        
        request(.post, url: url, parameters: parameters) { result in
            completion(result)
        }
    }
    
    func addTodoItem(_ item: ToDoItem, completion: @escaping (Result<[ToDoItem], Error>) -> Void) {
        
        guard let url = baseURL?.appendingPathComponent("add") else { return }
        
        request(.post, url: url, parameters: item.json) { result in
            completion(result)
        }
    }
    
    func editTodoItem(_ item: ToDoItem, completion: @escaping (Result<[ToDoItem], Error>) -> Void) {
        
        guard let url = baseURL?.appendingPathComponent("edit") else { return }
        
        request(.post, url: url, parameters: item.json) { result in
            completion(result)
        }
    }
    
    func deleteTodoItem(at id: String, completion: @escaping (Result<[ToDoItem], Error>) -> Void) {
        
        guard let url = baseURL?.appendingPathComponent("delete") else { return }
        
        let parameters = [
            "id": id
        ]
        
        request(.post, url: url, parameters: parameters) { result in
            completion(result)
        }
    }
    
    func request(_ type: Request, url: URL, parameters: [String: Any]? = nil, completion: @escaping (Result<[ToDoItem], Error>) -> Void) {
        mockCompletion { result in
            completion(result)
        }
    }
    
    func mockCompletion(completion: @escaping (Result<[ToDoItem], Error>) -> Void) {
        mockLeftOffClosure {
            if self.isConnectionAvailable() {
                guard let mockServerData = MockServer.mockServerData else { return }
                guard let parsedItems = mockServerData.parseToItems() else {
                    completion(.failure(NetworkError.badParsing))
                    return
                }
                completion(.success(parsedItems))
            } else {
                completion(.failure(NetworkError.noConnection))
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
            DDLogInfo(error)
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
