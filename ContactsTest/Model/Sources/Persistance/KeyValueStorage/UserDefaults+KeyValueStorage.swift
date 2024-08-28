//
//  UserDefaults+KeyValueStorage.swift
//
//
//  Created by Nikita Ponomarenko on 18.08.2024.
//

import Foundation

extension UserDefaults: KeyValueStorage {
    // MARK: String
    public func save(string: String?, for key: String) {
        set(string, forKey: key)
    }

    public func getString(for key: String) -> String? {
        return object(forKey: key) as? String
    }
    
    // MARK: Int
    public func save(int: Int?, for key: String) {
        set(int, forKey: key)
    }

    public func getInt(for key: String) -> Int? {
        return object(forKey: key) as? Int
    }
    
    // MARK: Bool
    public func save(bool: Bool?, for key: String) {
        set(bool, forKey: key)
    }
    
    public func getBool(for key: String) -> Bool? {
        return object(forKey: key) as? Bool
    }
    
    // MARK: Double
    public func save(double: Double?, for key: String) {
        set(double, forKey: key)
    }

    public func getDouble(for key: String) -> Double? {
        double(forKey: key)
    }
    
    // MARK: Objects
    public func save(object: NSObject?, for key: String) {
        setValue(object, forKey: key)
    }

    public func getObject(for key: String) -> NSObject? {
        return object(forKey: key) as? NSObject
    }

    public func saveGenericObject<T>(object: T, for key: String) where T: Decodable, T: Encodable {
        let data = try? JSONEncoder().encode(object)
        set(data, forKey: key)
    }

    public func getGenericObject<T>(object: T.Type, for key: String) -> T? where T: Decodable, T: Encodable {
        guard let data = self.object(forKey: key) as? Data else { return nil }

        return try? JSONDecoder().decode(T.self, from: data)
    }

    public func remove(for key: String) {
        removeObject(forKey: key)
    }
}
