//
//  Storage.swift
//
//
//  Created by Nikita Ponomarenko on 07.08.2024.
//

import Foundation

public protocol Storage {
    func execute<T>(_ request: FetchRequest<T>, completion: @escaping (Result<[T], Error>) -> Void)
    func insert<T: Storable>(_ objects: [T], completion: @escaping (Result<[T], Error>) -> Void)
    func update<T: Storable>(_ objects: [T], completion: @escaping (Result<[T], Error>) -> Void)
    func delete<T: Storable>(_ objects: [T], completion: @escaping (Result<(), Error>) -> Void)
    func deleteAllObjects<T: Storable>(of type: T.Type, completion: @escaping (Result<(), Error>) -> Void)
}

public extension Storage {
    func fetchAll<T: Storable>(completion: @escaping (Result<[T], Error>) -> Void) {
        execute(FetchRequest(), completion: completion)
    }
    
    func findFirst<T: Storable>(_ type: T.Type, primaryValue: String, predicate: NSPredicate? = nil, completion: @escaping (Result<T?, Error>) -> Void) {
        guard let primaryKey = type.primaryKeyName else {
            completion(.failure(StorageError.missingPrimaryKey))
            return
        }
        
        let primaryKeyPredicate = NSPredicate(format: "\(primaryKey) == %@", primaryValue)
        let fetchPredicate: NSPredicate
        
        if let predicate = predicate {
            fetchPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [primaryKeyPredicate, predicate])
        } else {
            fetchPredicate = primaryKeyPredicate
        }
        
        let request = FetchRequest<T>(predicate: fetchPredicate, fetchLimit: 1)
        
        execute(request) { result in
            completion(result.map({ $0.first }))
        }
    }
    
    func insert<T: Storable>(_ object: T, completion: @escaping (Result<T, Error>) -> Void) {
        insert([object], completion: {
            switch $0 {
            case .success(_): completion(.success(object))
            case .failure(let error): completion(.failure(error))
            }
        })
    }
    
    func update<T: Storable>(_ object: T, completion: @escaping (Result<T, Error>) -> Void) {
        update([object], completion: {
            switch $0 {
            case .success(_): completion(.success(object))
            case .failure(let error): completion(.failure(error))
            }
        })
    }
    
    func delete<T: Storable>(_ object: T, completion: @escaping (Result<(), Error>) -> Void) {
        delete([object], completion: completion)
    }
}
