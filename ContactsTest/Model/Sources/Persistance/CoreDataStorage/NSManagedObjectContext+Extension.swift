//
//  NSManagedObjectContext+Extension.swift
//
//
//  Created by Nikita Ponomarenko on 17.08.2024.
//

import CoreData

extension NSManagedObjectContext {
    func save(includingParent: Bool) throws {
        guard hasChanges else { return }
        
        try save()
        
        if includingParent, let parent {
            try parent.safePerformAndWait {
                try parent.save(includingParent: true)
            }
        }
    }
    
    func safePerformAndWait(_ block: @escaping () throws -> Void) throws {
        var outError: Error?
        
        performAndWait {
            do {
                try block()
            } catch {
                outError = error
            }
        }
        
        if let outError {
            throw outError
        }
    }
}
