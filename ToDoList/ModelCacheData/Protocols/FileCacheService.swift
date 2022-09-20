//
//  FileCacheService.swift
//  ToDoList
//
//  Created by Anna Tsvetkova on 12.08.2022.
//

import Foundation

enum VoidResult {
    case success
    case failure(Error)
}

protocol FileCacheService {
    
    func save(
        items: [ToDoItem],
        completion: @escaping (VoidResult) -> Void
    )
    
    func load(
        /*from url: URL,*/
        completion: @escaping (Result<[ToDoItem], Error>) -> Void
    )
    
    func add(
        _ newItem: ToDoItem,
        completion: @escaping (VoidResult) -> Void
    )
    
    func edit(
        _ item: ToDoItem,
        completion: @escaping (VoidResult) -> Void
    )
    
    func delete(
        id: String,
        completion: @escaping (VoidResult) -> Void
    )
}
