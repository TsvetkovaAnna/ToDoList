//
//  APINetworkingService.swift
//  ToDoList
//
//  Created by Anna Tsvetkova on 20.08.2022.
//

import Foundation

class APINetworkingService: NetworkService {
    
    let authKey = "Authorization"
    let authToken = "Bearer GuidebookOfFungi"
    
    let revisionKey = "X-Last-Known-Revision"
    var revision: String?
    
    let baseURL = URL(string: "https://beta.mrdekk.ru/todobackend/list")
    let urlSession: URLSession
    
    var request: URLRequest? {
        guard let baseURL = baseURL else { return nil }
        var request = URLRequest(url: baseURL)
        request.setValue(authToken, forHTTPHeaderField: authKey)
        
        if let revision = revision {
            request.setValue(revision, forHTTPHeaderField: revisionKey)
        }
        
        return request
    }
    
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        self.urlSession = URLSession(configuration: configuration)
    }
    
    func sendRequest(_ request: URLRequest, completion: @escaping (Data) -> Void) {
        
        urlSession.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                print("error:", error)
            }
            
            if let data = data {
                print("\(request.httpMethod ?? "") data:", data.count, data.description)
                completion(data)
            }
                      
            if let response = response {
                print("resp:", response.description)
            }
        }.resume()
    }
    
    func getTodoItem(_ id: String, completion: @escaping (Result<[ToDoItem], Error>) -> Void) {
        
        guard var request = request,
            let url = request.url,
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        else { return }
        
        components.queryItems = [URLQueryItem(name: "id", value: id)]
        
        guard let url = components.url else { return }
        request.url = url
        request.httpMethod = "GET"

        sendRequest(request) { data in
            
        }
    }
    
    func getAllTodoItems(completion: @escaping (Result<[ToDoItem], Error>) -> Void) {
        
        guard var request = request else { return }
        request.httpMethod = "GET"
        request.setValue(nil, forHTTPHeaderField: revisionKey)
        
        sendRequest(request) { data in
            
        }
    }
    
    func saveAllTodoItems(_ items: [ToDoItem], completion: @escaping (Result<[ToDoItem], Error>) -> Void) {
        
        guard var request = request else { return }
        request.httpMethod = "PATCH"
        request.httpBody = try? JSONEncoder().encode(items.map({ $0.likeElement }))

        sendRequest(request) { data in
            
        }
        
    }
    
    func addTodoItem(_ item: ToDoItem, completion: @escaping (Result<[ToDoItem], Error>) -> Void) {
        
        guard var request = combineRequest(item: item) else { return }
        request.httpMethod = "POST"

        sendRequest(request) { data in
            
        }
    }
    
    func editTodoItem(_ item: ToDoItem, completion: @escaping (Result<[ToDoItem], Error>) -> Void) {
        
        guard var request = combineRequest(id: item.id, item: item) else { return }
        
        request.setValue(revision, forHTTPHeaderField: revisionKey)
        request.httpMethod = "PUT"
        
        sendRequest(request) { data in
            
        }
    }
    
    func deleteTodoItem(at id: String, completion: @escaping (Result<[ToDoItem], Error>) -> Void) {
        
        guard var request = combineRequest(id: id) else { return }
        
        request.httpMethod = "DELETE"
        
        sendRequest(request) { data in
            
        }
    }
    
    func combineRequest(id: String? = nil, item: ToDoItem? = nil) -> URLRequest? {
        guard let baseURL = baseURL, var request = request else { return nil }
        
        if let id = id {
            request.url =  baseURL.appendingPathComponent(id)
        }
        
        if let item = item {
            request.httpBody = try? JSONEncoder().encode(item.likeElement)
        }
        
        return request
    }
    
}
