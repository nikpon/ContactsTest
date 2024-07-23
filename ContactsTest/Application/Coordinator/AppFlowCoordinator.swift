//
//  AppFlowCoordinator.swift
//  ContactsTest
//
//  Created by Nikita Ponomarenko on 03.06.2024.
//

import UIKit

final class AppFlowCoordinator {
    var navigationController: UINavigationController
    private let appDIContainer: AppDIContainer
    
    init(navigationController: UINavigationController, appDIContainer: AppDIContainer) {
        self.navigationController = navigationController
        self.appDIContainer = appDIContainer
    }

    func start() {
        let contactsSceneDIContainer = appDIContainer.makeContactsSceneDIContainer()
        let flow = contactsSceneDIContainer.makeContactsSceneFlowCoordinator(navigationController: navigationController)
        flow.start()
    }
}
