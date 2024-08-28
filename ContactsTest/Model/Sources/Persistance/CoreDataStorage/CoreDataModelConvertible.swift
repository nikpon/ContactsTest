//
//  CoreDataModelConvertible.swift
//  
//
//  Created by Nikita Ponomarenko on 28.08.2024.
//

import CoreData

public protocol CoreDataModelConvertible: Storable {
    func upsertManagedObject(in context: NSManagedObjectContext, existedInstance: NSManagedObject?) -> NSManagedObject
    
    static var managedObjectClass: NSManagedObject.Type { get }
    static var entityName: String { get }
    
    func isPrimaryValueEqualTo(value: Any) -> Bool
    
    static func from(_ managedObject: NSManagedObject) -> Storable
}
