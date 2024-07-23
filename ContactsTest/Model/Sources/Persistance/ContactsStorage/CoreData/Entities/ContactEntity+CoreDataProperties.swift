//
//  ContactEntity+CoreDataProperties.swift
//  ContactsTest
//
//  Created by Nikita Ponomarenko on 04.06.2024.
//
//

import Foundation
import CoreData

extension ContactEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ContactEntity> {
        return NSFetchRequest<ContactEntity>(entityName: "ContactEntity")
    }

    @NSManaged public var avatarData: Data?
    @NSManaged public var familyName: String?
    @NSManaged public var givenName: String?
    @NSManaged public var fullName: String?
    @NSManaged public var uid: String
    @NSManaged public var phoneNumber: String?
}

extension ContactEntity: Identifiable {}
