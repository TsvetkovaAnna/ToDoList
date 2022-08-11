//
//  FileCache.swift
//  YaToDoList
//
//  Created by Anna Tsvetkova on 04.08.2022.
//

import UIKit
import CocoaLumberjack

final class FileCache {
    
    init() {
        loadData()
    }
    
    private let fileManager = FileManager.default
    
    private var docUrl: URL? {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    private var cacheUrl: URL? {
        guard let url = docUrl else { return nil }
        print(url)
        return url.appendingPathComponent("ToDoItems.txt")
    }
    
    private(set) var arrayToDoItems = [ToDoItem]()
    private var jsonPath: String? {
        Bundle.main.path(forResource: "fileJSON", ofType: "json")
    }
    
    func addItem(item: ToDoItem) {
        arrayToDoItems.append(item)
        saveData()
    }
    
    func deleteItem(byId: String) {
        guard let index = arrayToDoItems.firstIndex(where: { $0.id == byId }) else { return }
        arrayToDoItems.remove(at: index)
        saveData()
    }
    
    func refreshItem(_ item: ToDoItem, byId: String) {
        print(#function)
        guard let index = arrayToDoItems.firstIndex(where: { $0.id == byId }) else { return }
        arrayToDoItems[index] = item
        //print(item.text)
        DDLogInfo(item.text)
        //print(arrayToDoItems)
        DDLogInfo(arrayToDoItems)
        saveData()
    }
    
    func saveData() {
        guard let cacheUrl = cacheUrl,
              arrayToDoItems.count > 0,
              let jsonData = ToDoItemList.json(fromItems: arrayToDoItems)
        else { return }
        
        fileManager.createFile(atPath: cacheUrl.path, contents: jsonData)
    }
    
    func loadLast() -> ToDoItem? {
        arrayToDoItems.last
    }
    
    func loadData() {
        
        var parsed: [ToDoItem]? = nil
        
        parsed = parseCache()
        
        if parsed == nil {
            guard let path = jsonPath else { return }
            parsed = parseFromFile(pathForFile: path)
        }
        
        guard let parsedItems = parsed else { return }
        
        arrayToDoItems = parsedItems
    }
    
//    func checkData() -> [ToDoItem]? {
//        guard let path = jsonPath else { return nil }
//        return parseFromFile(pathForFile: path)
//    }
//
//    var checkTodoItems: [ToDoItem] {
//        arrayToDoItems
//    }
    
    func parseCache() -> [ToDoItem]? {
        
        guard let cacheUrl = cacheUrl else { return nil }
        
        do {
            let cacheData = try Data(contentsOf: cacheUrl)
            guard let cacheDict = try JSONSerialization.jsonObject(with: cacheData, options: .allowFragments) as? [String: [[String: Any]]]
            else { return nil }
            
            return ToDoItemList(cacheDict).todoItems
            
        } catch {
            print(error)
        }
        
        return nil
    }
    
    @discardableResult func parseFromFile(pathForFile: String) -> [ToDoItem]? {
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: pathForFile))
            guard let dict = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
            else { return nil }
            return ToDoItemList(dict).todoItems
        } catch {
            print(error)
        }
        
        return nil
    }
    
}
