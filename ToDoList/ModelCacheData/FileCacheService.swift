//
//  FileCacheService.swift
//  ToDoList
//
//  Created by Anna Tsvetkova on 12.08.2022.
//

import Foundation

protocol FileCacheService {

    var fileCache: FileCache { get set }
    
    func save(
        to file: String,
        completion: @escaping ([ToDoItem]) -> Void
    )
    
    func load(
        from url: URL,
        completion: @escaping ([ToDoItem]) -> Void
    )
    
    func add(_ newItem: ToDoItem)
    func edit(_ item: ToDoItem)
    func delete(id: String)
}
