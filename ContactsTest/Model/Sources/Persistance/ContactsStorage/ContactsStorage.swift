//
//  ContactsStorage.swift
//  ContactsTest
//
//  Created by Nikita Ponomarenko on 04.06.2024.
//

import Combine
import Models

public protocol ContactsStorage {
    func fetchContacts() -> AnyPublisher<[Contact], Error>
    func save(contacts: [Contact]) -> AnyPublisher<[Contact], Error>
    func delete(contact: Contact) -> AnyPublisher<Contact, Error>
    var latestContactsHash: Int? { get }
    func setLatestContactsHash(_ hash: Int)
}
