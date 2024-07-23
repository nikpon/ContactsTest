//
//  CustomLogger.swift
//  ContactsTest
//
//  Created by Nikita Ponomarenko on 04.06.2024.
//

import Foundation
import os

public struct CustomLogger {
    public enum PrivacyLevel {
        case privateLvl
        case publicLvl
    }
    
    static public func log(_ str: String, privacy: PrivacyLevel = .privateLvl) {
        switch privacy {
        case .privateLvl: Logger.all.log("\(str, privacy: .private)")
        case .publicLvl: Logger.all.log("\(str, privacy: .public)")
        }
    }
    
    static public func error(_ str: String, privacy: PrivacyLevel = .privateLvl) {
        switch privacy {
        case .privateLvl: Logger.all.error("\(str, privacy: .private)")
        case .publicLvl: Logger.all.error("\(str, privacy: .public)")
        }
    }
}

fileprivate extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier!

    static let all = Logger(subsystem: subsystem, category: "contactsTest")
}
