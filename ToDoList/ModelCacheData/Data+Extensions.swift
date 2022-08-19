//
//  Data+Extensions.swift
//  ToDoList
//
//  Created by Anna Tsvetkova on 14.08.2022.
//

import Foundation
import CocoaLumberjack

extension Data {
    func parseToItems() -> [ToDoItem]? {
        do {
            guard let dict = try JSONSerialization.jsonObject(with: self, options: .allowFragments) as? [String: Any]
            else { return nil }
            return ToDoItemList(dict).todoItems
        } catch {
            DDLogInfo(error)
        }
        
        return nil
    }
}
