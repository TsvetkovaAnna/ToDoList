//
//  GeneralMockService.swift
//  ToDoList
//
//  Created by Anna Tsvetkova on 13.08.2022.
//

import Foundation

class GeneralMockService {
    
    let networkService = MockNetworkService()
    let fileCacheService = MockFileCacheService()
    
    var items = [ToDoItem]()
    
    func delete(_ at: String) {
        if networkService.isConnectionAvailable() {
//            networkService.deleteTodoItem(at: at, completion: <#T##(Result<[ToDoItem], Error>) -> Void#>)
        } else {
//            fileCacheService.delete(id: <#T##String#>)
        }
    }
    
    func update() {
        
    }
}
