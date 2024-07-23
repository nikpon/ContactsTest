//
//  ContactMatchRanges.swift
//  
//
//  Created by Nikita Ponomarenko on 12.07.2024.
//

import Foundation

public struct ContactMatchRanges {
    var givenNameRange: Range<String.Index>? = nil
    var familyNameRange: Range<String.Index>? = nil
    var fullNameRange: Range<String.Index>? = nil
    var phoneNumberRange: Range<String.Index>? = nil
}
