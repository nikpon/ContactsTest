//
//  CoreDataContactsStorage.swift
//  ContactsTest
//
//  Created by Nikita Ponomarenko on 04.06.2024.
//

import Foundation
import Combine
import Models

final class ContactsStorageImpl: ContactsStorage {
    private static let sortDescriptors = [
        NSSortDescriptor(key: #keyPath(ContactEntity.familyName), ascending: true),
        NSSortDescriptor(key: #keyPath(ContactEntity.givenName), ascending: true)
    ]
    
    private let latestContactsHashKey = "latestContactsHash"
    
    private let storage: Storage
    private let keyValueStorage: KeyValueStorage
    
    init(storage: Storage, keyValueStorage: KeyValueStorage) {
        self.storage = storage
        self.keyValueStorage = keyValueStorage
    }
    
    // MARK: ContactsStorage
    func fetchContacts() -> AnyPublisher<[Contact], Error> {
        return Future<[Contact], Error> { [weak self] promise in
            let requst = FetchRequest<Contact>(sortDescriptors: Self.sortDescriptors)
            
            self?.storage.execute(requst, completion: { (result: Result<[Contact], Error>) in
                switch result {
                case .success(let contacts): promise(.success(contacts))
                case .failure(let error): promise(.failure(error))
                }
            })
        }.eraseToAnyPublisher()
    }
    
    func save(contacts: [Contact]) -> AnyPublisher<[Contact], Error> {
        return Future<[Contact], Error> { [weak self] promise in
            self?.storage.insert(contacts, completion: { result in
                switch result {
                case .success(_): promise(.success(contacts))
                case .failure(let error): promise(.failure(error))
                }
            })
            
        }
        .eraseToAnyPublisher()
    }
    
    func delete(contact: Contact) -> AnyPublisher<Contact, Error> {
        return Future<Contact, Error> { [weak self] promise in
            self?.storage.delete([contact], completion: { result in
                switch result {
                case .success(): promise(.success(contact))
                case .failure(let error): promise(.failure(error))
                }
            })
        }
        .eraseToAnyPublisher()
    }
    
    var latestContactsHash: Int? {
        return keyValueStorage.getInt(for: latestContactsHashKey)
    }
    
    func setLatestContactsHash(_ hash: Int) {
        keyValueStorage.save(int: hash, for: latestContactsHashKey)
    }
}
