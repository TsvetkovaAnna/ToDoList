//
//  APINetworkingService.swift
//  ToDoList
//
//  Created by Anna Tsvetkova on 20.08.2022.
//

import Foundation
import CocoaLumberjack

final class APINetworkingService: NetworkService {
    
    let authKey = "Authorization"
    
    let revisionKey = "X-Last-Known-Revision"
    var revision: String?
    
    let baseURL = URL(string: "https://beta.mrdekk.ru/todobackend/list")
    let urlSession: URLSession
    
    var request: URLRequest? {
        guard let authToken = TokenKeeper.load(),
              let baseURL = baseURL else { return nil }
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
    
    func getTodoItem(_ id: String, completion: @escaping (Result<[ToDoItem], Error>) -> Void) {
        DDLogInfo(#function)
        guard var request = request,
            let url = request.url,
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        else { return }
        
        components.queryItems = [URLQueryItem(name: "id", value: id)]
        
        guard let url = components.url else { return }
        request.url = url
        request.httpMethod = "GET"

        sendRequest(request) { [weak self] data in
            guard let self = self else { return }
            self.itemsCompletion(from: data) { result in
                completion(result)
            }
        }
    }
    
    func getAllTodoItems(completion: @escaping (Result<[ToDoItem], Error>) -> Void) {
        DDLogInfo(#function)
        guard var request = request else { return }
        request.httpMethod = "GET"
        request.setValue(nil, forHTTPHeaderField: revisionKey)
        
        sendRequest(request) { [weak self] data in
            guard let self = self else { return }
            self.itemsCompletion(from: data) { result in
                completion(result)
            }
        }
    }
    
    func saveAllTodoItems(_ items: [ToDoItem], completion: @escaping (Result<[ToDoItem], Error>) -> Void) {
        
        guard var request = request else { return }
        request.httpMethod = "PATCH"
        request.httpBody = try? JSONEncoder().encode(ListCase(items.map({ $0.likeElement })))
        
        sendRequest(request) { [weak self] data in
            guard let self = self else { return }
            self.itemsCompletion(from: data) { result in
                completion(result)
            }
        }
        
    }
    
    func addTodoItem(_ item: ToDoItem, completion: @escaping (Result<ToDoItem, Error>) -> Void) {
        
        guard var request = combineRequest(item: item) else { return }
        request.httpMethod = "POST"
        sendRequest(request) { [weak self] data in
            guard let self = self else { return }
            self.itemCompletion(from: data) { result in
                completion(result)
            }
        }
    }
    
    func editTodoItem(_ item: ToDoItem, completion: @escaping (Result<ToDoItem, Error>) -> Void) {
        DDLogInfo(#function)
        guard var request = combineRequest(id: item.id, item: item) else { return }
        
        request.setValue(revision, forHTTPHeaderField: revisionKey)
        request.httpMethod = "PUT"
        
        sendRequest(request) { [weak self] data in
            guard let self = self else { return }
            self.itemCompletion(from: data) { result in
                completion(result)
            }
        }
    }
    
    func deleteTodoItem(at id: String, completion: @escaping (Result<ToDoItem, Error>) -> Void) {
        DDLogInfo(#function)
        guard var request = combineRequest(id: id) else { return }
        
        request.httpMethod = "DELETE"
        
        sendRequest(request) { [weak self] data in
            guard let self = self else { return }
            self.itemCompletion(from: data) { result in
                completion(result)
            }
        }
    }
    
    // MARK: Private
    
    private func sendRequest(_ request: URLRequest, completion: @escaping (Data) -> Void) {
        
        urlSession.dataTask(with: request) { (data, _/*response*/, error) in
            
            if let error = error {
                DDLogInfo(error)
            }
            
            if let data = data {
                completion(data)
            }
        }.resume()
    }
    
    private func itemsCompletion(from data: Data, completion: @escaping (Result<[ToDoItem], Error>) -> Void) {
        guard let listCase = try? JSONDecoder().decode(ListCase.self, from: data)
        else { completion(.failure(NetworkError.itemDecoding));  return; }
        
        if let revisionValue = listCase.revision {
            revision = String(revisionValue)
        }
        completion(.success(listCase.list.map({ $0.likeItem })))
    }
    
    private func itemCompletion(from data: Data, completion: @escaping (Result<ToDoItem, Error>) -> Void) {
        guard let elementCase = try? JSONDecoder().decode(ElementCase.self, from: data)
        else { completion(.failure(NetworkError.itemDecoding)); return }
        if let revisionValue = elementCase.revision {
            revision = String(revisionValue)
        }
        completion(.success(elementCase.element.likeItem))
    }
    
    private func combineRequest(id: String? = nil, item: ToDoItem? = nil) -> URLRequest? {
        guard let baseURL = baseURL, var request = request else { return nil }
        
        if let id = id {
            request.url =  baseURL.appendingPathComponent(id)
        }
        
        if let item = item {
            request.httpBody = try? JSONEncoder().encode(ElementCase(item.likeElement))
        }
        
        return request
    }
    
}
