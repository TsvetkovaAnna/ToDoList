//
//  GeneralServiceProtocol.swift
//  ToDoList
//
//  Created by Anna Tsvetkova on 20.08.2022.
//

import Foundation

protocol GeneralServiceProtocol {
    
    func edit(_ item: ToDoItem)
    
    func add(_ newItem: ToDoItem)
    
    func delete(_ at: String)
    
    func update(_ completion: @escaping () -> Void)
    
}
