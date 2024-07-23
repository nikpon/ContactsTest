//
//  SystemContactsServiceFactory.swift
//
//
//  Created by Nikita Ponomarenko on 14.07.2024.
//

import Foundation

public class SystemContactsServiceFactory {
    public init() {}
    
    public func makeSystemContactsService() -> SystemContactsService {
        return SystemContactsServiceImpl()
    }
}
