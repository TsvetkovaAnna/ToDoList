//
//  GeneralServiceProtocol.swift
//  ToDoList
//
//  Created by Anna Tsvetkova on 20.08.2022.
//

import Foundation

enum Redacting {
    case add, edit, delete
}

protocol GeneralServiceProtocol {
    
    func load(completion: @escaping (VoidResult) -> Void)
        
    func redact(_ action: Redacting, item: ToDoItem, _ completion: @escaping (VoidResult) -> Void)
    
    func update(_ completion: @escaping (VoidResult) -> Void)
    
}
