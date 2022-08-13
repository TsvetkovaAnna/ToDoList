//
//  NetworkService.swift
//  ToDoList
//
//  Created by Anna Tsvetkova on 12.08.2022.
//

import Foundation

protocol NetworkService {
    func getAllTodoItems(
        completion: @escaping (Result<[ToDoItem], Error>) -> Void
    )
    
    func editTodoItem(
        _ item: ToDoItem,
        completion: @escaping (Result<[ToDoItem], Error>) -> Void
    )
    
    func deleteTodoItem(
        at id: String,
        completion: @escaping (Result<[ToDoItem], Error>) -> Void
    )
}
