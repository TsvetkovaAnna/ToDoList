//
//  GeneralServiceProtocol.swift
//  ToDoList
//
//  Created by Anna Tsvetkova on 20.08.2022.
//

import Foundation

protocol GeneralServiceProtocol {
    
    func load(completion: @escaping () -> Void) // extra
        
    func edit(_ item: ToDoItem)
    
    func add(_ newItem: ToDoItem)
    
    func delete(_ at: String, _ completion: @escaping () -> Void)
    
    func update(_ completion: @escaping () -> Void)
    
}