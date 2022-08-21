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
        // loadData()
    }
    
    private let fileManager = FileManager.default
    
    private var docUrl: URL? {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    private var cacheUrl: URL? {
        guard let url = docUrl else { return nil }
        return url.appendingPathComponent("ToDoItems.txt")
    }
    
    var items = [ToDoItem]() {
        didSet {
            saveData()
        }
    }
    
    private var jsonPath: String? {
        Bundle.main.path(forResource: "fileJSON", ofType: "json")
    }
    
    func addItem(item: ToDoItem) {
        items.append(item)
    }
    
    func deleteItem(byId: String) {
        guard let index = items.firstIndex(where: { $0.id == byId }) else { return }
        items.remove(at: index)
    }
    
    func refreshItem(_ item: ToDoItem, byId: String) {
        guard let index = items.firstIndex(where: { $0.id == byId }) else { return }
        items[index] = item.updated
    }
    
    func saveData(_ toURL: URL? = nil) {
        guard let cacheUrl = toURL ?? cacheUrl,
              !items.isEmpty,
              let jsonData = ToDoItemList.json(fromItems: items)
        else { return }
        print("dd:", String(data: jsonData, encoding: .utf8))
        fileManager.createFile(atPath: cacheUrl.path, contents: jsonData)
    }
    
    func loadLast() -> ToDoItem? {
        items.last
    }
    
    func loadData(_ fromURL: URL? = nil) {
        
        DDLogInfo(#function)
        
        var parsed: [ToDoItem]?
        
        parsed = parseCache(fromURL)
        print("parsed:", parsed)
        if parsed == nil {
            guard let path = jsonPath else { return }
            parsed = parseFromFile(pathForFile: path)
        }
        
        guard let parsedItems = parsed else { return }
        
        items = parsedItems
    }
    
//    func checkData() -> [ToDoItem]? {
//        guard let path = jsonPath else { return nil }
//        return parseFromFile(pathForFile: path)
//    }
//
//    var checkTodoItems: [ToDoItem] {
//        arrayToDoItems
//    }
    
    func parseCache(_ fromURL: URL? = nil) -> [ToDoItem]? {
        
        guard let cacheUrl = fromURL ?? cacheUrl else { return nil }
        
        do {
            let cacheData = try Data(contentsOf: cacheUrl)
            return cacheData.parseToItems()
        } catch {
            DDLogInfo(error)
        }
        
        return nil
    }
    
    @discardableResult func parseFromFile(pathForFile: String) -> [ToDoItem]? {
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: pathForFile))
            return data.parseToItems()
        } catch {
            DDLogInfo(error)
        }
        
        return nil
    }
    
}
