//
//  ContactsFlowCoordinator.swift
//  ContactsTest
//
//  Created by Nikita Ponomarenko on 12.07.2024.
//

import UIKit
import Contacts
import ContactsModule

protocol ContactsSceneFlowCoordinatorDependencies {
    func makeSelectedContactsListViewController(actions: SelectedContactsListViewModelActions) -> UIViewController
    func makeContactsSearchViewController(actions: ContactsSearchViewModelActions) -> UIViewController
}

final class ContactsSceneFlowCoordinator {
    private weak var navigationController: UINavigationController?
    private let dependencies: ContactsSceneFlowCoordinatorDependencies

    private weak var selectedContactsListVC: UIViewController?
    private weak var contactsSearchNC: UINavigationController?

    init(navigationController: UINavigationController, dependencies: ContactsSceneFlowCoordinatorDependencies) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }

    func start() {
        let actions = SelectedContactsListViewModelActions(showContactsSearch: showContactsSearch)
        let vc = dependencies.makeSelectedContactsListViewController(actions: actions)

        navigationController?.pushViewController(vc, animated: false)
        selectedContactsListVC = vc
    }
    
    func showContactsSearch(_ onClosing: @escaping () -> Void) {
        let actions = ContactsSearchViewModelActions(closeContactsSearch: { [weak self] in
            self?.closeContactsSearch(onClosing)
        })
        
        let vc = dependencies.makeContactsSearchViewController(actions: actions)
        let navigationController = UINavigationController(rootViewController: vc)
        contactsSearchNC = navigationController
        selectedContactsListVC?.present(navigationController, animated: true)
    }
    
    private func closeContactsSearch(_ onClosing: @escaping () -> Void) {
        contactsSearchNC?.dismiss(animated: true, completion: onClosing)
    }
}
