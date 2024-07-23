//
//  ContactsSearchService.swift
//  ContactsTest
//
//  Created by Nikita Ponomarenko on 20.06.2024.
//

import Foundation
import Models

public final class ContactsSearchServiceFactory {
    public init() {}
    
    public func makeContactsSearchService() -> ContactsSearchService {
        return ContactsSearchServiceImpl()
    }
}

public protocol ContactsSearchService {
    func findTextRanges(query: String, in contact: Contact) -> ContactMatchRanges?
}

struct ContactsSearchServiceImpl: ContactsSearchService {
    func findTextRanges(query: String, in contact: Contact) -> ContactMatchRanges? {
        if !contact.fullName.trimmingCharacters(in: .whitespaces).isEmpty, let range = findConvertedPrefixRange(query: query, nameComponent: contact.fullName) {
            return ContactMatchRanges(fullNameRange: range)
        }
        
        if contact.givenName.isEmpty == false, let range = findConvertedPrefixRange(query: query, nameComponent: contact.givenName) {
            return ContactMatchRanges(givenNameRange: range)
        }
        
        if contact.familyName.isEmpty == false, let range = findConvertedPrefixRange(query: query, nameComponent: contact.familyName) {
            return ContactMatchRanges(familyNameRange: range)
        }
        
        if let phoneNumber = contact.phoneNumber, phoneNumber.isEmpty == false, let phoneNumberRange = phoneNumber.range(of: query) {
            return ContactMatchRanges(phoneNumberRange: phoneNumberRange)
        }
        
        return nil
    }

    private func findConvertedPrefixRange(query: String, nameComponent: String) -> Range<String.Index>? {
        let normalizedQuery = query.normalized()
        let normalizedNameComponent = nameComponent.normalized()
        
        if normalizedNameComponent.hasPrefix(normalizedQuery) {
            let prefixEndIndex = nameComponent.index(nameComponent.startIndex, offsetBy: normalizedQuery.count)
            return nameComponent.startIndex..<prefixEndIndex
        } else {
            return nil
        }
    }
}

fileprivate extension String {
    func normalized() -> String {
        let mutable = NSMutableString(string: self) as CFMutableString
        CFStringTransform(mutable, nil, "Any-Latin; Latin-ASCII; Any-Lower" as CFString, false)
        return mutable as String
    }
}

