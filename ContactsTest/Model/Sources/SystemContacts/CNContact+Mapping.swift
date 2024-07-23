//
//  CNContact+Mapping.swift
//
//
//  Created by Nikita Ponomarenko on 12.07.2024.
//

import Contacts
import Models

extension CNContact {
    func toModel() -> Contact {
        return Contact(
            id: identifier,
            givenName: givenName,
            familyName: familyName,
            fullName: CNContactFormatter.string(from: self, style: .fullName) ?? "",
            phoneNumber: phoneNumbers.first?.value.stringValue, // TODO: support multiple numbers
            avatarData: thumbnailImageData
        )
    }
}
