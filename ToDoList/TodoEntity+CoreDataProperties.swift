//
//  TodoEntity+CoreDataProperties.swift
//  
//
//  Created by Anna Tsvetkova on 25.08.2022.
//
//

import Foundation
import CoreData

extension TodoEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TodoEntity> {
        return NSFetchRequest<TodoEntity>(entityName: "TodoEntity")
    }

    @NSManaged public var id: String
    @NSManaged public var text: String
    @NSManaged public var deadline: NSNumber?
    @NSManaged public var importance: String
    @NSManaged public var done: Bool
    @NSManaged public var color: String?
    @NSManaged public var createdAt: Int64
    @NSManaged public var changedAt: Int64
    @NSManaged public var lastUpdatedBy: String

}
