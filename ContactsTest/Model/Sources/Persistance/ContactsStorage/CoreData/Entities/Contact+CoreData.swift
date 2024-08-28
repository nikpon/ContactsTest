//
//  Contact+Stored.swift
//
//
//  Created by Nikita Ponomarenko on 19.08.2024.
//

import Models
import CoreData

extension Contact: Storable {
    public static var primaryKeyName: String? {
        return "uid"
    }
    
    public var valueOfPrimaryKey: CVarArg? {
        return id
    }
}

extension Contact: CoreDataModelConvertible {
    public static var managedObjectClass: NSManagedObject.Type { return ContactEntity.self }
    public static var entityName: String { return String(describing: managedObjectClass) }
    
    public func upsertManagedObject(in context: NSManagedObjectContext, existedInstance: NSManagedObject?) -> NSManagedObject {
        let contactEntity: ContactEntity = if let result = existedInstance as? ContactEntity {
             result
        } else {
            NSEntityDescription.insertNewObject(forEntityName: Contact.entityName, into: context) as! ContactEntity
        }
      
        contactEntity.uid = id
        contactEntity.givenName = givenName
        contactEntity.familyName = familyName
        contactEntity.fullName = fullName
        contactEntity.phoneNumber = phoneNumber
        contactEntity.avatarData = avatarData
        
        return contactEntity
    }
    
    public static func from(_ managedObject: NSManagedObject) -> Storable {
        guard let contactEntity = managedObject as? ContactEntity else {
            fatalError("can't create Contact object from object \(managedObject)")
        }
        
        return Contact(id: contactEntity.uid, givenName: contactEntity.givenName!, familyName: contactEntity.familyName!, fullName: contactEntity.fullName!, phoneNumber: contactEntity.phoneNumber, avatarData: contactEntity.avatarData)
    }
    
    public func isPrimaryValueEqualTo(value: Any) -> Bool {
        if let value = value as? String {
            return value == id
        }
        
        return false
    }
}
