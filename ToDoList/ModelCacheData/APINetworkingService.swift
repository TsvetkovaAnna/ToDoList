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
        print(#function)
        guard var request = request,
            let url = request.url,
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        else { return }
        
        components.queryItems = [URLQueryItem(name: "id", value: id)]
        
        guard let url = components.url else { return }
        request.url = url
        request.httpMethod = "GET"

        sendRequest(request) { data in
            self.itemsCompletion(from: data) { result in
                completion(result)
            }
        }
    }
    
    func getAllTodoItems(completion: @escaping (Result<[ToDoItem], Error>) -> Void) {
        print(#function)
        guard var request = request else { return }
        request.httpMethod = "GET"
        request.setValue(nil, forHTTPHeaderField: revisionKey)
        
        sendRequest(request) { data in
            self.itemsCompletion(from: data) { result in
                completion(result)
            }
        }
    }
    
    func saveAllTodoItems(_ items: [ToDoItem], completion: @escaping (Result<[ToDoItem], Error>) -> Void) {
        print(#function)
        guard var request = request else { return }
        request.httpMethod = "PATCH"
        request.httpBody = try? JSONEncoder().encode(ListCase(items.map({ $0.likeElement })))
        print("httpBody list:", String(data: request.httpBody!, encoding: .utf8))
        
        sendRequest(request) { data in
            self.itemsCompletion(from: data) { result in
                completion(result)
            }
        }
        
    }
    
    func addTodoItem(_ item: ToDoItem, completion: @escaping (Result<ToDoItem, Error>) -> Void) {
        
        guard var request = combineRequest(item: item) else { return }
        request.httpMethod = "POST"
        print("addTodoItem, rev:", request.value(forHTTPHeaderField: revisionKey))
        sendRequest(request) { data in
            self.itemCompletion(from: data) { result in
                completion(result)
            }
        }
    }
    
    func editTodoItem(_ item: ToDoItem, completion: @escaping (Result<ToDoItem, Error>) -> Void) {
        print(#function)
        guard var request = combineRequest(id: item.id, item: item) else { return }
        
        request.setValue(revision, forHTTPHeaderField: revisionKey)
        request.httpMethod = "PUT"
        
        sendRequest(request) { data in
            self.itemCompletion(from: data) { result in
                completion(result)
            }
        }
    }
    
    func deleteTodoItem(at id: String, completion: @escaping (Result<ToDoItem, Error>) -> Void) {
        print(#function)
        guard var request = combineRequest(id: id) else { return }
        
        request.httpMethod = "DELETE"
        
        sendRequest(request) { data in
            self.itemCompletion(from: data) { result in
                completion(result)
            }
        }
    }
    
    func itemsCompletion(from data: Data, completion: @escaping (Result<[ToDoItem], Error>) -> Void) {
        guard let listCase = try? JSONDecoder().decode(ListCase.self, from: data)
        else { completion(.failure(NetworkError.itemDecoding));  print("NetworkError.itemDecoding"); return; }
        print("succecc decoding, rev;", listCase.revision)
        if let revisionValue = listCase.revision {
            revision = String(revisionValue)
        }
        completion(.success(listCase.list.map({ $0.likeItem })))
    }
    
    func itemCompletion(from data: Data, completion: @escaping (Result<ToDoItem, Error>) -> Void) {
        guard let elementCase = try? JSONDecoder().decode(ElementCase.self, from: data)
        else { completion(.failure(NetworkError.itemDecoding)); return }
        if let revisionValue = elementCase.revision {
            revision = String(revisionValue)
        }
        completion(.success(elementCase.element.likeItem))
    }
    
    func combineRequest(id: String? = nil, item: ToDoItem? = nil) -> URLRequest? {
        guard let baseURL = baseURL, var request = request else { return nil }
        
        if let id = id {
            request.url =  baseURL.appendingPathComponent(id)
        }
        
        if let item = item {
            request.httpBody = try? JSONEncoder().encode(ElementCase(item.likeElement))
            print("httpBody:", String(data: request.httpBody!, encoding: .utf8))
        }
        
        return request
    }
    
}
