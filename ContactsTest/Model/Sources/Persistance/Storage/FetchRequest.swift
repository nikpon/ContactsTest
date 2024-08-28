//
//  File.swift
//  
//
//  Created by Nikita Ponomarenko on 07.08.2024.
//

import Foundation

public struct FetchRequest<T: Storable> {
    public let sortDescriptors: [NSSortDescriptor]?
    public let predicate: NSPredicate?
    public let fetchOffset: Int
    public let fetchLimit: Int
    
    public init(predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil, fetchOffset: Int = 0, fetchLimit: Int = 0) {
        self.predicate = predicate
        self.sortDescriptors = sortDescriptors
        self.fetchOffset = fetchOffset
        self.fetchLimit = fetchLimit
    }
}

// MARK: - Filtering
public extension FetchRequest {
    func filtered(with predicate: NSPredicate) -> FetchRequest<T> {
        return request(withPredicate: predicate)
    }
    
    func filtered(with key: String, equalTo value: String) -> FetchRequest<T> {
        return request(withPredicate: NSPredicate(format: "\(key) == %@", value))
    }
    
    func filtered(with key: String, in value: [String]) -> FetchRequest<T> {
        return request(withPredicate: NSPredicate(format: "\(key) IN %@", value))
    }
    
    func filtered(with key: String, notIn value: [String]) -> FetchRequest<T> {
        return request(withPredicate: NSPredicate(format: "NOT (\(key) IN %@)", value))
    }
}

// MARK: - Sorting
public extension FetchRequest {
    func sorted(with sortDescriptor: NSSortDescriptor) -> FetchRequest<T> {
        return request(withSortDescriptors: [sortDescriptor])
    }
    
    func sorted(with sortDescriptors: [NSSortDescriptor]) -> FetchRequest<T> {
        return request(withSortDescriptors: sortDescriptors)
    }
    
    func sorted(with key: String?, ascending: Bool, comparator cmptr: @escaping Comparator) -> FetchRequest<T> {
        return request(withSortDescriptors: [NSSortDescriptor(key: key, ascending: ascending, comparator: cmptr)])
    }
    
    func sorted(with key: String?, ascending: Bool) -> FetchRequest<T> {
        return request(withSortDescriptors: [NSSortDescriptor(key: key, ascending: ascending)])
    }
    
    func sorted(with key: String?, ascending: Bool, selector: Selector) -> FetchRequest<T> {
        return request(withSortDescriptors: [NSSortDescriptor(key: key, ascending: ascending, selector: selector)])
    }
}

// MARK: - Private
private extension FetchRequest {
    func request(withPredicate predicate: NSPredicate) -> FetchRequest<T> {
        return FetchRequest<T>(predicate: predicate, sortDescriptors: sortDescriptors, fetchOffset: fetchOffset, fetchLimit: fetchLimit)
    }
    
    func request(withSortDescriptors sortDescriptors: [NSSortDescriptor]) -> FetchRequest<T> {
        return FetchRequest<T>(predicate: predicate, sortDescriptors: sortDescriptors, fetchOffset: fetchOffset, fetchLimit: fetchLimit)
    }
}
