//
//  StorageError.swift
//
//
//  Created by Nikita Ponomarenko on 16.07.2024.
//

import Foundation

enum StorageError: Error {
    case readError(Error)
    case saveError(Error)
    case deleteError(Error)
}
