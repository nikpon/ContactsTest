//
//  NSManagedObject+Storable.swift
//
//
//  Created by Nikita Ponomarenko on 28.08.2024.
//

import CoreData

extension NSManagedObject: Storable {
    public static var primaryKeyName: String? { return nil }
    
    public var valueOfPrimaryKey: CVarArg? { return nil }
}
