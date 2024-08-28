//
//  StorageFactory.swift
//
//
//  Created by Nikita Ponomarenko on 14.07.2024.
//

import Foundation

public class StorageFactory {
    private let coreDataStorage: CoreDataStorage
    private let keyValueStorage: KeyValueStorage
        
    public init(coreDataStorage: CoreDataStorage = CoreDataStorage(versionNumber: CoreDataStorage.Version.actual), keyValueStorage: KeyValueStorage = UserDefaults.standard) {
        self.coreDataStorage = coreDataStorage
        self.keyValueStorage = keyValueStorage
    }
    
    public func makeContactsStorage() -> ContactsStorage {
        return ContactsStorageImpl(storage: coreDataStorage, keyValueStorage: keyValueStorage)
    }
}
