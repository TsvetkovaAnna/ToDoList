//
//  NetworkService.swift
//  ToDoList
//
//  Created by Anna Tsvetkova on 12.08.2022.
//

import Foundation

protocol NetworkService {
    
    func getAllTodoItems(
        completion: @escaping ([ToDoItem]?) -> Void
    )
    
    func saveAllTodoItems(
        _ items: [ToDoItem],
        completion: @escaping ([ToDoItem]?) -> Void
    )
    
    func addTodoItem(
        _ item: ToDoItem,
        completion: @escaping ([ToDoItem]?) -> Void
    )
    
    func editTodoItem(
        _ item: ToDoItem,
        completion: @escaping ([ToDoItem]?) -> Void
    )
    
    func deleteTodoItem(
        at id: String,
        completion: @escaping ([ToDoItem]?) -> Void
    )
}
