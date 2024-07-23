//
//  SceneDelegate.swift
//  ContactsTest
//
//  Created by Nikita Ponomarenko on 03.06.2024.
//

import UIKit
import Mocking

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    private let appDIContainer = AppDIContainer()
    private var appFlowCoordinator: AppFlowCoordinator?
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        let navigationController = UINavigationController()
        
        window.rootViewController = navigationController
        appFlowCoordinator = AppFlowCoordinator(navigationController: navigationController, appDIContainer: appDIContainer)
        appFlowCoordinator?.start()
        window.makeKeyAndVisible()
        self.window = window
    }
    
//    private func mock() {
//        // simulator only
//        ContactsGenerator.requestAccessAndCreateRandomContacts(1000)
//        ContactsGenerator.deleteRandomContacts()
//    }
}
