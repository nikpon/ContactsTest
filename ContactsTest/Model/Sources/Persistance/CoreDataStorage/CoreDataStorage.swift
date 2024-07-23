//
//  CoreDataStorage.swift
//  ContactsTest
//
//  Created by Nikita Ponomarenko on 04.06.2024.
//
//

import CoreData
import Combine
import Utilities

public typealias VersionNumber = UInt

final class CoreDataStorage {
    private let persistentContainer: NSPersistentContainer
    
    init(directory: FileManager.SearchPathDirectory = .documentDirectory, domainMask: FileManager.SearchPathDomainMask = .userDomainMask, versionNumber: VersionNumber) {

        let version = Version(versionNumber)
        let versionName = version.modelName
    
        persistentContainer = NSPersistentContainer(name: versionName, managedObjectModel: getModelFromBundle(name: versionName))
        
        if let url = version.dbFileURL(directory, domainMask) {
            let store = NSPersistentStoreDescription(url: url)
            persistentContainer.persistentStoreDescriptions = [store]
        }
        
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            if let error {
                assertionFailure("CoreDataStorage Unresolved error \(error), \(error.localizedDescription)")
            }
        }
    }

    func save() {
        let context = persistentContainer.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                CustomLogger.error("CoreDataStorage Unresolved error - \(error)")
                assertionFailure("CoreDataStorage Unresolved error \(error), \((error as NSError).userInfo)")
            }
        }
    }

    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        persistentContainer.performBackgroundTask(block)
    }
}

// MARK: - Versioning
extension CoreDataStorage.Version {
    static var actual: VersionNumber { 1 }
}

extension CoreDataStorage {
    struct Version {
        private let number: VersionNumber
        
        init(_ number: VersionNumber) {
            self.number = number
        }
        
        var modelName: String {
            return "db_model_v\(number)"
        }
        
        func dbFileURL(_ directory: FileManager.SearchPathDirectory, _ domainMask: FileManager.SearchPathDomainMask) -> URL? {
            return FileManager.default.urls(for: directory, in: domainMask).first?.appendingPathComponent(subpathToDB)
        }
        
        private var subpathToDB: String {
            return "db.sql"
        }
    }
}

// MARK: - Model from module
fileprivate func getModelFromBundle(name: String) -> NSManagedObjectModel {
    /// needed to init NSPersistentContainer when model placed in bundle
    guard let url = Bundle.module.url(forResource: name, withExtension: ".momd") else {
        fatalError("Could not get URL for model: \(name)")
    }

    guard let model = NSManagedObjectModel(contentsOf: url) else {
        fatalError("Could not get model for: \(url)")
    }
    
    return model
}
