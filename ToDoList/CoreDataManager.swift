//
//  CoreDataManager.swift
//  ToDoList
//
//  Created by Anna Tsvetkova on 25.08.2022.
//

import UIKit
import CoreData

final class CoreDataManager {
    
    // MARK: Private
    
    private var appDelegate: AppDelegate? {
        UIApplication.shared.delegate as? AppDelegate
    }
    
    private var context: NSManagedObjectContext? {
        appDelegate?.persistentContainer.viewContext
    }
    
    private func getAllTodoEntities() throws -> [TodoEntity] {
        
        let fetchRequest = TodoEntity.fetchRequest()
        
        guard let context = context else { throw CacheError.noDelegate }
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            throw CacheError.fetchError
        }
    }
    
    private func fetchTodoEntity(by item: ToDoItem? = nil, id: String? = nil) throws -> TodoEntity {
        
        do {
            let allTodoEntities = try getAllTodoEntities()
            guard let theId = item?.id ?? id else { throw CacheError.badParameters }
            guard let entity = (allTodoEntities.first { $0.id == theId }) else { throw CacheError.noItem }
            return entity
        } catch {
            throw error
        }
    }
    
    private func setTodoEntity(_ todoEntity: inout TodoEntity, by element: Element) {
        todoEntity.id = element.id
        todoEntity.text = element.text
        todoEntity.deadline = element.deadline as NSNumber?
        todoEntity.importance = element.importance
        todoEntity.done = element.done
        todoEntity.color = element.color
        todoEntity.createdAt = Int64(element.createdAt)
        todoEntity.changedAt = Int64(element.changedAt)
        todoEntity.lastUpdatedBy = element.lastUpdatedBy
    }
    
    private func getElementFrom(todoEntity: TodoEntity) -> Element {
        Element(id: todoEntity.id, text: todoEntity.text, deadline: todoEntity.deadline as? Int64, importance: todoEntity.importance, done: todoEntity.done, color: todoEntity.color, createdAt: Int(todoEntity.createdAt), changedAt: Int(todoEntity.changedAt), lastUpdatedBy: todoEntity.lastUpdatedBy)
    }
    
    // MARK: Public
    
    func getAllTodos() throws -> [ToDoItem] {
        do {
            let allTodoEntities = try getAllTodoEntities()
            return allTodoEntities.map({ getElementFrom(todoEntity: $0).likeItem })
        } catch {
            throw error
        }
    }
    
    func createNewTodo(_ item: ToDoItem) throws {
        do {
            _ = try fetchTodoEntity(by: item)
        } catch where error as? CacheError == CacheError.noItem {
            guard let context = context else { throw CacheError.noDelegate }
            var newEntity = TodoEntity(context: context)
            setTodoEntity(&newEntity, by: item.likeElement)
            appDelegate?.saveContext()
        } catch {
            throw error
        }
    }
    
    func updateTodo(_ item: ToDoItem) throws {
        do {
            var thisEntity = try fetchTodoEntity(by: item)
            setTodoEntity(&thisEntity, by: item.likeElement)
            appDelegate?.saveContext()
        } catch {
            throw error
        }
    }
    
    func deleteTodo(_ id: String) throws {
        do {
            let thisEntity = try fetchTodoEntity(id: id)
            guard let context = context,
            let appDelegate = appDelegate
            else { throw CacheError.noDelegate }
            context.delete(thisEntity)
            appDelegate.saveContext()
        } catch {
            throw error
        }
    }
    
    func clear() throws {
        
        guard let appDelegate = appDelegate else { throw CacheError.noDelegate }
        
        let container = appDelegate.persistentContainer
        
        guard let url = container.persistentStoreDescriptions.first?.url
        else { throw CacheError.noStoreURL }
        
        let coordinator = container.persistentStoreCoordinator
        
        do {
            try coordinator.destroyPersistentStore(at: url, type: NSPersistentStore.StoreType(rawValue: NSSQLiteStoreType), options: nil)
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            print(error)
        }
    }
   
}
