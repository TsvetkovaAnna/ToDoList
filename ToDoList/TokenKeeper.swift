//
//  TokenKeeper.swift
//  ToDoList
//
//  Created by Anna Tsvetkova on 28.08.2022.
//

import Foundation

final class TokenKeeper {
    
    private static let token = "Bearer GuidebookOfFungi"
    private static let key = "token"
    
    static func save() {
        UserDefaults.standard.set(token, forKey: key)
    }
    
    static func load() -> String? {
        UserDefaults.standard.string(forKey: key)
    }
}
