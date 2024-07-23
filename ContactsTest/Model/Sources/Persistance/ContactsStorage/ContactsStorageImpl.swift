//
//  CoreDataContactsStorage.swift
//  ContactsTest
//
//  Created by Nikita Ponomarenko on 04.06.2024.
//

import Foundation
import CoreData
import Combine
import Models

final class ContactsStorageImpl: ContactsStorage {
    private static let sortDescriptors = [
        NSSortDescriptor(key: #keyPath(ContactEntity.familyName), ascending: true),
        NSSortDescriptor(key: #keyPath(ContactEntity.givenName), ascending: true)
    ]
    
    private let latestContactsHashKey = "latestContactsHash"
    
    private let coreDataStorage: CoreDataStorage
    private let userDefaults: UserDefaults
    
    init(coreDataStorage: CoreDataStorage) {
        self.coreDataStorage = coreDataStorage
        self.userDefaults = UserDefaults.standard
    }
    
    private func cleanUpContacts(for contact: Contact, in context: NSManagedObjectContext) throws {
        let request: NSFetchRequest = ContactEntity.fetchRequest()
        request.sortDescriptors = Self.sortDescriptors
        var result = try context.fetch(request)
        
        removeDuplicates(for: contact, in: &result, in: context)
    }
    
    private func removeDuplicates(for contact: Contact, in contacts: inout [ContactEntity], in context: NSManagedObjectContext) {
        contacts.filter { $0.uid == contact.id }.forEach { context.delete($0) }
        contacts.removeAll { $0.uid == contact.id }
    }
    
    private func fetchRequest(for contact: Contact) -> NSFetchRequest<ContactEntity> {
        let request: NSFetchRequest = ContactEntity.fetchRequest()
        request.predicate = NSPredicate(format: "%K = %@", #keyPath(ContactEntity.uid), contact.id)
        
        return request
    }
    
    // MARK: ContactsStorage
    func fetchContacts() -> AnyPublisher<[Contact], Error> {
        return Future<[Contact], Error> { [weak self] promise in
            self?.coreDataStorage.performBackgroundTask { context in
                do {
                    let request: NSFetchRequest = ContactEntity.fetchRequest()
                    request.sortDescriptors = Self.sortDescriptors
                    
                    let result = try context.fetch(request).map { $0.toModel() }
                    promise(.success(result))
                } catch {
                    promise(.failure(StorageError.readError(error)))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func save(contacts: [Contact]) -> AnyPublisher<[Contact], Error> {
        return Future<[Contact], Error> { [weak self] promise in
            self?.coreDataStorage.performBackgroundTask { context in
                do {
                    try contacts.forEach { contact in try self?.cleanUpContacts(for: contact, in: context) }
                    let contactEntities = contacts.map { ContactEntity(contact: $0, insertInto: context) }
                    try context.save()
                    
                    promise(.success(contactEntities.map { $0.toModel() }))
                } catch {
                    promise(.failure(StorageError.saveError(error)))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func delete(contact: Contact) -> AnyPublisher<Contact, Error> {
        let request = fetchRequest(for: contact)
        
        return Future<Contact, Error> { [weak self] promise in
            self?.coreDataStorage.performBackgroundTask { context in
                do {
                    if let result = try context.fetch(request).first {
                        context.delete(result)
                        try context.save()
                        promise(.success(contact))
                    }
                } catch {
                    promise(.failure(StorageError.deleteError(error)))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    var latestContactsHash: Int? {
        return userDefaults.integer(forKey: latestContactsHashKey)
    }
    
    func setLatestContactsHash(_ hash: Int) {
        userDefaults.setValue(hash, forKey: latestContactsHashKey)
    }
}
