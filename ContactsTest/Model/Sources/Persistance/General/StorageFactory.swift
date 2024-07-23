//
//  StorageFactory.swift
//
//
//  Created by Nikita Ponomarenko on 14.07.2024.
//

public class StorageFactory {
    private let coreDataStorage: CoreDataStorage
        
    public init(storageVersionNumber: VersionNumber? = nil) {
        if let storageVersionNumber {
            self.coreDataStorage = CoreDataStorage(versionNumber: storageVersionNumber)
        } else {
            self.coreDataStorage = CoreDataStorage(versionNumber: CoreDataStorage.Version.actual)
        }
    }
    
    public func makeContactsStorage() -> ContactsStorage {
        return ContactsStorageImpl(coreDataStorage: coreDataStorage)
    }
}
