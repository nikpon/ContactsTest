//
//  Storable.swift
//
//
//  Created by Nikita Ponomarenko on 19.08.2024.
//

import Foundation

public protocol Storable {
    static var primaryKeyName: String? { get }
    
    var valueOfPrimaryKey: CVarArg? { get }
}
