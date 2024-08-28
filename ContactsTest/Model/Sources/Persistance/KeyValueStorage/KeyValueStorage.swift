//
//  KeyValueStorage.swift
//
//
//  Created by Nikita Ponomarenko on 18.08.2024.
//

import Foundation

public protocol KeyValueStorage {
    func save(string: String?, for key: String)
    func getString(for key: String) -> String?

    func save(int: Int?, for key: String)
    func getInt(for key: String) -> Int?

    func save(bool: Bool?, for key: String)
    func getBool(for key: String) -> Bool?
    
    func save(double: Double?, for key: String)
    func getDouble(for key: String) -> Double?

    func save(object: NSObject?, for key: String)
    func getObject(for key: String) -> NSObject?

    func saveGenericObject<T: Codable>(object: T, for key: String)
    func getGenericObject<T: Codable>(object: T.Type, for key: String) -> T?

    func remove(for key: String)
}
