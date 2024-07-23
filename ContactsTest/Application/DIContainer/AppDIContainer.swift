//
//  AppDIContainer.swift
//  ContactsTest
//
//  Created by Nikita Ponomarenko on 04.06.2024.
//

import Foundation
import Persistance

final class AppDIContainer {
    private let storageFactory = StorageFactory()
    
    func makeContactsSceneDIContainer() -> ContactsSceneDIContainer {
        return ContactsSceneDIContainer(storageFactory: storageFactory)
    }
}
