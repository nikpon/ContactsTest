//
//  CoreDataStorage.swift
//
//
//  Created by Nikita Ponomarenko on 17.08.2024.
//

import CoreData

public typealias VersionNumber = UInt

public class CoreDataStorage {
    private let modelName: String
    private let bundle: Bundle = .module
    private let persistentStoreType = NSSQLiteStoreType
    
    public init(versionNumber: VersionNumber) {
        let version = Version(versionNumber)
        
        self.modelName = version.modelName
    }
    
    // MARK: Core Data Stack
    private lazy var storeURL: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let applicationDocumentsDirectory = urls[urls.count - 1]
        
        return applicationDocumentsDirectory.appendingPathComponent("\(self.modelName).sqlite")
    }()
    
    private lazy var managedObjectModel: NSManagedObjectModel = {
        guard
            let modelURL = self.bundle.url(forResource: self.modelName, withExtension: "momd"),
            let objectModel = NSManagedObjectModel(contentsOf: modelURL)
        else {
            fatalError("Can't find managedObjectModel named \(self.modelName) in \(self.bundle)")
        }
        
        return objectModel
    }()
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel:  self.managedObjectModel)
        
        do {
            try coordinator.addPersistentStore(ofType: self.persistentStoreType, configurationName: nil, at: self.storeURL, options: nil)
            return coordinator
        } catch let error {
            fatalError("\(error)")
        }
        
        return coordinator
    }()
    
    private lazy var rootContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        let parentContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        parentContext.persistentStoreCoordinator = coordinator
        
        return parentContext
    }()
    
    fileprivate lazy var mainContext: NSManagedObjectContext = {
        let mainContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        mainContext.parent = self.rootContext
        
        return mainContext
    }()
    
    private lazy var readManagedContext: NSManagedObjectContext = {
        let fetchContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        fetchContext.parent = self.mainContext
        
        return fetchContext
    }()
    
    private lazy var writeManagedContext: NSManagedObjectContext = {
        let fetchContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        fetchContext.parent = self.mainContext
        
        return fetchContext
    }()
    
    // MARK: Read
    private func performReadTask(closure: @escaping (NSManagedObjectContext) -> ()) {
        let context = readManagedContext
        context.perform {
            closure(context)
        }
    }
    
    private func performReadTaskAndWait(closure: @escaping (NSManagedObjectContext) -> ()) {
        let context = readManagedContext
        context.performAndWait {
            closure(context)
        }
    }
    
    // MARK: Write
    private func performWriteTask(_ closure: @escaping (NSManagedObjectContext, (() throws -> ())) -> ()) {
        let context = writeManagedContext
        context.perform {
            closure(context) {
                try context.save(includingParent: true)
            }
        }
    }
    
    private func performWriteTaskAndWait(_ closure: @escaping (NSManagedObjectContext, (() throws -> ())) -> ()) {
        let context = writeManagedContext
        context.performAndWait {
            closure(context) {
                try context.save(includingParent: true)
            }
        }
    }
}

// MARK: - Storage
extension CoreDataStorage: Storage {
    public func execute<T>(_ request: FetchRequest<T>, completion: @escaping (Result<[T], Error>) -> Void) where T: Storable {
        let coreDataModelType = check(type: T.self)
        
        performReadTask { context in
            let fetchRequest = self.fetchRequest(for: coreDataModelType)
            fetchRequest.predicate = request.predicate
            fetchRequest.sortDescriptors = request.sortDescriptors
            fetchRequest.fetchLimit = request.fetchLimit
            fetchRequest.fetchOffset = request.fetchOffset
            
            do {
                let result = try context.fetch(fetchRequest) as! [NSManagedObject]
                let resultModels = result.compactMap { coreDataModelType.from($0) as? T }
                
                completion(.success(resultModels))
            } catch let error {
                completion(.failure(error))
            }
        }
    }
    
    public func insert<T>(_ objects: [T], completion: @escaping (Result<[T], Error>) -> Void) where T: Storable {
        check(type: T.self)
        
        performWriteTask { context, savingClosure in
            var insertedObjects = [T]()
            let foundObjects = self.find(objects: objects, in: context)
            
            for (object, storedObject) in foundObjects {
                if storedObject != nil { continue }
                
                _ = object.upsertManagedObject(in: context, existedInstance: nil)
                insertedObjects.append(object as! T)
            }
            
            do {
                try savingClosure()
                completion(.success(insertedObjects))
            } catch let error {
                completion(.failure(error))
            }
        }
    }
    
    public func update<T>(_ objects: [T], completion: @escaping (Result<[T], Error>) -> Void) where T: Storable {
        check(type: T.self)
        
        performWriteTask { context, savingClosure in
            var updatedObjects = [T]()
            let foundObjects = self.find(objects: objects, in: context)
            
            for (object, storedObject) in foundObjects {
                guard let storedObject else { continue }
                
                _ = object.upsertManagedObject(in: context, existedInstance: storedObject)
                updatedObjects.append(object as! T)
            }
            
            do {
                try savingClosure()
                completion(.success(updatedObjects))
            } catch let error {
                completion(.failure(error))
            }
        }
    }
    
    public func upsert<T>(_ objects: [T], completion: @escaping (Result<(updated: [T], inserted: [T]), Error>) -> Void) where T: Storable {
        check(type: T.self)
        
        performWriteTask { context, savingClosure in
            var updatedObjects = [T]()
            var insertedObjects = [T]()
            let foundObjects = self.find(objects: objects, in: context)
            
            for (object, storedObject) in foundObjects {
                _ = object.upsertManagedObject(in: context, existedInstance: storedObject)
                
                if storedObject == nil {
                    insertedObjects.append(object as! T)
                } else {
                    updatedObjects.append(object as! T)
                }
            }
            
            do {
                try savingClosure()
                completion(.success((updated: updatedObjects, inserted: insertedObjects)))
            } catch let error {
                completion(.failure(error))
            }
        }
    }
    
    public func delete<T>(_ objects: [T], completion: @escaping (Result<(), Error>) -> Void) where T: Storable {
        check(type: T.self)
        
        performWriteTask { context, savingClosure in
            let foundObjects = self.find(objects, in: context)
            foundObjects.forEach { context.delete($0) }
            
            do {
                try savingClosure()
                completion(.success(()))
            } catch let error {
                completion(.failure(error))
            }
        }
    }
    
    public func deleteAllObjects<T>(of type: T.Type, completion: @escaping (Result<(), Error>) -> Void) where T : Storable {
        let type = check(type: T.self)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: type.entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        deleteRequest.resultType = .resultTypeObjectIDs
        
        performWriteTask { [weak mainContext] context, savingClosure in
            do {
                let result = try context.execute(deleteRequest) as? NSBatchDeleteResult
                
                if let objectIDs = result?.result as? [NSManagedObjectID] {
                    for objectID in objectIDs {
                        guard let object = mainContext?.object(with: objectID) else { continue }
                        mainContext?.delete(object)
                    }
                }
                
                try savingClosure()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
}

// MARK: - Private
private extension CoreDataStorage {
    func fetchRequest(for entity: CoreDataModelConvertible.Type) -> NSFetchRequest<NSFetchRequestResult> {
        return NSFetchRequest(entityName: entity.entityName)
    }
    
    @discardableResult
    func check<T>(type: T) -> CoreDataModelConvertible.Type {
        switch type {
        case let type as CoreDataModelConvertible.Type: return type
        default:
            let modelType = String(describing: CoreDataStorage.self)
            let protocolType = String(describing: CoreDataModelConvertible.self)
            let givenType = String(describing: type)
            fatalError("`\(modelType)` can manage only types which conform to `\(protocolType)`. Type given is `\(givenType)`.")
        }
    }
    
    func find<T: Storable>(_ objects: [T], in context: NSManagedObjectContext) -> [NSManagedObject] {
        let coreDataModelType = check(type: T.self)
        guard let primaryKeyName = T.primaryKeyName else { return [] }
        
        let ids = objects.compactMap { $0.valueOfPrimaryKey }
        let fetchRequest = self.fetchRequest(for: coreDataModelType)
        fetchRequest.predicate = NSPredicate(format: "%K IN %@", primaryKeyName, ids)
        
        guard let storedObjects = try? context.fetch(fetchRequest) as? [NSManagedObject] else { return [] }
        
        return storedObjects
    }
    
    func find<T: Storable>(objects: [T], in context: NSManagedObjectContext) -> [(object: CoreDataModelConvertible, storedObject: NSManagedObject?)] {
        guard let primaryKeyName = T.primaryKeyName else { return [] }
        
        let storedObjects = find(objects, in: context)
        
        return convert(objects: objects).map { object -> (CoreDataModelConvertible, NSManagedObject?) in
            let managedObject = storedObjects.first(where: { (obj: NSManagedObject) -> Bool in
                if let value = obj.value(forKey: primaryKeyName) {
                    return object.isPrimaryValueEqualTo(value: value)
                }
                
                return false
            })
            
            return (object, managedObject)
        }
    }
    
    func convert<T: Storable>(objects: [T]) -> [CoreDataModelConvertible] {
        check(type: T.self)
        
        return objects.compactMap { $0 as? CoreDataModelConvertible }
    }
}

// MARK: - Version
extension CoreDataStorage.Version {
    static public var actual: VersionNumber { 1 }
}

extension CoreDataStorage {
    public struct Version {
        private let number: VersionNumber
        
        init(_ number: VersionNumber) {
            self.number = number
        }
        
        var modelName: String {
            return "db_model_v\(number)"
        }
    }
}
