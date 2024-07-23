//
//  ContactsSceneDIContainer.swift
//  ContactsTest
//
//  Created by Nikita Ponomarenko on 04.06.2024.
//

import SwiftUI
import ContactsModule
import Persistance
import SystemContacts

final class ContactsSceneDIContainer: ContactsSceneFlowCoordinatorDependencies {
    private let storageFactory: StorageFactory
    private let systemContactsServiceFactory = SystemContactsServiceFactory()
    private let contactsSearchServiceFactory = ContactsSearchServiceFactory()

    init(storageFactory: StorageFactory) {
        self.storageFactory = storageFactory
    }
    
    // MARK: Storages
    lazy private var contactsStorage: ContactsStorage = storageFactory.makeContactsStorage()
    
    // MARK: Services
    lazy private var systemContactsService: SystemContactsService = systemContactsServiceFactory.makeSystemContactsService()
    lazy private var contactsSearchService: ContactsSearchService = contactsSearchServiceFactory.makeContactsSearchService()
    
    // MARK: Contacts List
    func makeSelectedContactsListViewController(actions: SelectedContactsListViewModelActions) -> UIViewController {
        let view = SelectedContactsListView(viewModel: makeSelectedContactsListViewModel(actions: actions))
        return UIHostingController(rootView: view)
    }
    
    func makeSelectedContactsListViewModel(actions: SelectedContactsListViewModelActions) -> SelectedContactsListViewModel {
        return SelectedContactsListViewModel(systemContactsService: systemContactsService, contactsStorage: contactsStorage, actions: actions)
    }
    
    // MARK: Contacts Search
    func makeContactsSearchViewController(actions: ContactsSearchViewModelActions) -> UIViewController {
        let view = ContactsSearchView(viewModel: makeContactsSearchViewModel(actions: actions))
        return UIHostingController(rootView: view)
    }
    
    func makeContactsSearchViewModel(actions: ContactsSearchViewModelActions) -> ContactsSearchViewModel {
        return ContactsSearchViewModel(systemContactsService: systemContactsService, contactsSearchService: contactsSearchService, actions: actions, contactsStorage: contactsStorage)
    }
    
    // MARK: Flow Coordinators
    func makeContactsSceneFlowCoordinator(navigationController: UINavigationController) -> ContactsSceneFlowCoordinator {
        return ContactsSceneFlowCoordinator(navigationController: navigationController, dependencies: self)
    }
}
