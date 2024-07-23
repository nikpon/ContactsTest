//
//  SystemContactsService.swift
//  ContactsTest
//
//  Created by Nikita Ponomarenko on 04.06.2024.
//

import Contacts
import Combine
import Utilities
import Models

enum ContactsAuthorizationError: Error {
    case unknownError
}

public protocol SystemContactsService {
    func requestContactsAuthorization() -> AnyPublisher<Bool, Error>
    func fetchContacts(with identifiers: [String]?) -> AnyPublisher<[Contact]?, Error>
    var contactStoreChanges: AnyPublisher<Void, Never> { get }
}

final class SystemContactsServiceImpl: SystemContactsService {
    private let contactStore = CNContactStore()
    private let contactStoreChangesSubject = PassthroughSubject<Void, Never>()
    
    private static let contactFetchKeys: [CNKeyDescriptor] = [
        CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
        CNContactPhoneNumbersKey as CNKeyDescriptor,
        CNContactThumbnailImageDataKey as CNKeyDescriptor
    ]
    
    lazy var contactStoreChanges: AnyPublisher<Void, Never> = {
        NotificationCenter.default.publisher(for: .CNContactStoreDidChange)
            .map { _ in () }
            .eraseToAnyPublisher()
    }()
    
    func requestContactsAuthorization() -> AnyPublisher<Bool, Error> {
        return Future<Bool, Error> { [weak self] promise in
            self?.contactStore.requestAccess(for: CNEntityType.contacts) { (granted, error) -> Void in
                if granted {
                    promise(.success(granted))
                } else {
                    // can't disambiguate not granted and other error.
                    let error = error ?? ContactsAuthorizationError.unknownError
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func fetchContacts(with identifiers: [String]? = nil) -> AnyPublisher<[Contact]?, Error> {
        return Future<[Contact]?, Error> { [weak self] promise in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    var contacts: [Contact] = []
                    let contactFetchRequest = CNContactFetchRequest(keysToFetch: Self.contactFetchKeys)
                    
                    if let identifiers {
                        contactFetchRequest.predicate = CNContact.predicateForContacts(withIdentifiers: identifiers)
                    }
                    
                    contactFetchRequest.sortOrder = .userDefault
                    
                    try autoreleasepool {
                        try self?.contactStore.enumerateContacts(with: contactFetchRequest) { (cnContact, _) in
                            contacts.append(cnContact.toModel())
                        }
                    }
                    
                    promise(.success(contacts))
                } catch let error {
                    CustomLogger.error("ContactsServiceImpl error - \(error)")
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
