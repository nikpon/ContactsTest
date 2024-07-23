//
//  ContactsSearchViewModel.swift
//  ContactsTest
//
//  Created by Nikita Ponomarenko on 04.06.2024.
//

import Foundation
import Combine
import Persistance
import SystemContacts
import Models

public struct ContactsSearchViewModelActions {
    let closeContactsSearch: () -> Void
    
    public init(closeContactsSearch: @escaping () -> Void) {
        self.closeContactsSearch = closeContactsSearch
    }
}

final public class ContactsSearchViewModel: ObservableObject {
    private let systemContactsService: SystemContactsService
    private let contactsSearchService: ContactsSearchService
    private let actions: ContactsSearchViewModelActions?
    private let contactsStorage: ContactsStorage
    private var cancellables = Set<AnyCancellable>()
    
    @Published private(set) var state: State = .idle
    @Published var searchQuery: String = ""
    
    private var systemContacts: [Contact] = []
    @Published private(set) var filteredContactsAndRanges: [(contact: Contact, matchRanges: ContactMatchRanges?)] = []
    @Published private(set) var selectedContacts: Set<Contact> = []
    
    public init(systemContactsService: SystemContactsService, contactsSearchService: ContactsSearchService, actions: ContactsSearchViewModelActions, contactsStorage: ContactsStorage) {
        self.systemContactsService = systemContactsService
        self.contactsSearchService = contactsSearchService
        self.actions = actions
        self.contactsStorage = contactsStorage
        
        setupBindings()
    }
    
    // MARK: Internal methods
    func toggleSelection(for contact: Contact) {
        if selectedContacts.contains(contact) {
            selectedContacts.remove(contact)
        } else {
            selectedContacts.insert(contact)
        }
    }
    
    func load() {
        state = .loading
        
        fetchSystemContacts()
    }
    
    func saveContactsAndClose() {
        contactsStorage.save(contacts: Array(selectedContacts))
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.closeContactsSearch()
            }, receiveValue: { _ in })
            .store(in: &cancellables)
    }
    
    // MARK: Private methods
    private func setupBindings() {
        setupSearchQueryBinding()
    }
    
    private func setupSearchQueryBinding() {
        $searchQuery
            .removeDuplicates()
            .debounce(for: .milliseconds(100), scheduler: DispatchQueue.main)
            .sink { [weak self] query in
                guard let self else { return }
                
                self.filteredContactsAndRanges = self.filterSystemContacts(query: query)
            }
            .store(in: &cancellables)
    }
    
    private func filterSystemContacts(query: String) -> [(Contact, ContactMatchRanges?)] {
        guard !query.isEmpty else { return systemContacts.map { ($0, nil) } }
        
        return systemContacts.compactMap { contact in
            contactsSearchService.findTextRanges(query: query, in: contact).map { (contact, $0) }
        }
    }
    
    private func fetchSystemContacts() {
        systemContactsService.fetchContacts(with: nil)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished: self?.state = .loaded
                    case .failure(_): self?.state = .failed
                    }
                },
                receiveValue: { [weak self] contacts in
                    if let contacts {
                        self?.systemContacts = contacts
                        self?.filteredContactsAndRanges = contacts.map { ($0, nil) }
                    }
                }
            )
            .store(in: &cancellables)
    }
}

// MARK: - Input
extension ContactsSearchViewModel {
    private func closeContactsSearch() {
        actions?.closeContactsSearch()
    }
}

// MARK: - State
extension ContactsSearchViewModel {
    enum State: Equatable {
        case idle
        case loading
        case failed
        case loaded
    }
}
