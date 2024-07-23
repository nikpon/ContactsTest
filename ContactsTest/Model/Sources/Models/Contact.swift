//
//  Contact.swift
//
//
//  Created by Nikita Ponomarenko on 12.07.2024.
//

import Foundation

public struct Contact: Identifiable, Hashable, Equatable {
    public let id: String
    public let givenName: String
    public let familyName: String
    public let fullName: String
    public let phoneNumber: String? // TODO: let phoneNumbers: [(value: String, label: String?)]
    public let avatarData: Data?
    
    public init(id: String, givenName: String, familyName: String, fullName: String, phoneNumber: String?, avatarData: Data?) {
        self.id = id
        self.givenName = givenName
        self.familyName = familyName
        self.fullName = fullName
        self.phoneNumber = phoneNumber
        self.avatarData = avatarData
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(givenName)
        hasher.combine(familyName)
        hasher.combine(fullName)
        hasher.combine(phoneNumber)
    }
}
