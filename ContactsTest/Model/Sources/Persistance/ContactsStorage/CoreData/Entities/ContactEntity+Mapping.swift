//
//  ContactEntity.swift
//  ContactsTest
//
//  Created by Nikita Ponomarenko on 04.06.2024.
//

import Foundation
import CoreData
import Models

extension ContactEntity {
    convenience init(contact: Contact, insertInto context: NSManagedObjectContext) {
        self.init(context: context)
        
        self.uid = contact.id
        self.givenName = contact.givenName
        self.familyName = contact.familyName
        self.fullName = contact.fullName
        self.phoneNumber = contact.phoneNumber
        self.avatarData = contact.avatarData
    }
}

extension ContactEntity {
    func toModel() -> Contact {
        return Contact(id: uid, givenName: givenName!, familyName: familyName!, fullName: fullName!, phoneNumber: phoneNumber, avatarData: avatarData)
    }
}
