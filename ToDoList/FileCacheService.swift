//
//  FileCacheService.swift
//  ToDoList
//
//  Created by Anna Tsvetkova on 12.08.2022.
//

import Foundation

protocol FileCacheService {
    func save(
        to file: String,
        completion: @escaping ([ToDoItem]) -> Void
    )
    
    func load(
        from file: String,
        completion: @escaping ([ToDoItem]) -> Void
    )
    
    func add(_ newItem: ToDoItem)
    
    func delete(id: String)
}
