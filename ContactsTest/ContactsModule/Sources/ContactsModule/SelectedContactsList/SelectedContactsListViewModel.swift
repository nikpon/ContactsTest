//
//  SelectedContactsListViewModel.swift
//  ContactsTest
//
//  Created by Nikita Ponomarenko on 04.06.2024.
//

import Foundation
import Combine
import Persistance
import Models
import SystemContacts

public struct SelectedContactsListViewModelActions {
    let showContactsSearch: (_ onClosing: @escaping () -> Void) -> Void
    
    public init(showContactsSearch: @escaping (_: @escaping () -> Void) -> Void) {
        self.showContactsSearch = showContactsSearch
    }
}

final public class SelectedContactsListViewModel: ObservableObject {
    private let systemContactsService: SystemContactsService
    private let actions: SelectedContactsListViewModelActions?
    private let contactsStorage: ContactsStorage
    
    @Published private(set) var contacts: [Contact] = []
    @Published private(set) var contactsAccessAuthStatus: ContactsAccessAuthStatus = .unknown
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    
    private var cancellables = Set<AnyCancellable>()
    
    public init(systemContactsService: SystemContactsService, contactsStorage: ContactsStorage, actions: SelectedContactsListViewModelActions? = nil) {
        self.systemContactsService = systemContactsService
        self.actions = actions
        self.contactsStorage = contactsStorage
        
        setupBindings()
    }
    
    // MARK: Internal methods
    func load() {
        requestAuthorization()
        fetchSavedContacts(sync: syncContacts)
    }
    
    func deleteContacts(at offsets: IndexSet) {
        let contactsToDelete = offsets.map { contacts[$0] }
        contacts.remove(atOffsets: offsets)
        
        Publishers.Sequence(sequence: contactsToDelete)
            .flatMap { contact in
                self.contactsStorage.delete(contact: contact)
                    .ignoreOutput()
                    .catch { _ in Empty() } // ignore
            }
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &cancellables)
    }
    
    // MARK: Private methods
    private func setupBindings() {
        setupContactStoreChangesBinding()
    }
    
    private func setupContactStoreChangesBinding() {
        systemContactsService.contactStoreChanges.sink(
            receiveValue: { [weak self] _ in
                guard let self, !contacts.isEmpty else { return }
                syncContacts(contacts)
            })
        .store(in: &cancellables)
    }
    
    private func requestAuthorization() {
        systemContactsService.requestContactsAuthorization()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure = completion {
                        self?.contactsAccessAuthStatus = .failed
                    }
                }, receiveValue: { [weak self] granted in
                    self?.contactsAccessAuthStatus = granted ? .granted : .denied
                }
            )
            .store(in: &cancellables)
    }
    
    private func fetchSavedContacts(sync: (([Contact]) -> Void)?) {
        isLoading = true
        
        contactsStorage.fetchContacts()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false

                    if case .failure(let error) = completion {
                        self?.error = error
                    }
                },
                receiveValue: { [weak self] contacts in
                    guard let self else { return }
                    
                    if !contacts.isEmpty {
                        updateContacts(contacts)
                        sync?(contacts)
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    private func syncContacts(_ contacts: [Contact]) {
        let contactsIdentifiers = contacts.map { $0.id }
        
        systemContactsService
            .fetchContacts(with: contactsIdentifiers)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] contacts in
                    guard let self, let contacts else { return }
                    
                    if contactsStorage.latestContactsHash != contacts.hashValue {
                        self.updateContacts(contacts)
                        self.contactsStorage.save(contacts: contacts)
                            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
                            .store(in: &cancellables)
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    private func updateContacts(_ contacts: [Contact]) {
        self.contacts = contacts
        self.contactsStorage.setLatestContactsHash(contacts.hashValue)
    }
}

// MARK: - Input
extension SelectedContactsListViewModel {
    func showContactsSearch() {
        actions?.showContactsSearch({ [weak self] in
            guard let self else { return }
            
            self.fetchSavedContacts(sync: nil)
        })
    }
}

// MARK: - AuthorizationStatus
extension SelectedContactsListViewModel {
    enum ContactsAccessAuthStatus: Equatable {
        case unknown
        case granted
        case denied
        case failed
    }
}

// MARK: - Contacts hashValue
fileprivate extension Collection where Element == Contact {
    var hashValue: Int {
        var hasher = Hasher()
        forEach { hasher.combine($0.hashValue) }
        return hasher.finalize()
    }
}
