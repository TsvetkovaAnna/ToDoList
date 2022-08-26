//
//  GeneralServiceProtocol.swift
//  ToDoList
//
//  Created by Anna Tsvetkova on 20.08.2022.
//

import Foundation

protocol GeneralServiceProtocol {
    
    func load(completion: @escaping (VoidResult) -> Void) // extra
        
    func edit(_ item: ToDoItem, _ completion: @escaping (VoidResult) -> Void)
    
    func add(_ newItem: ToDoItem, _ completion: @escaping (VoidResult) -> Void)
    
    func delete(_ at: String, _ completion: @escaping (VoidResult) -> Void)
    
    func update(_ completion: @escaping (VoidResult) -> Void)
    
}
