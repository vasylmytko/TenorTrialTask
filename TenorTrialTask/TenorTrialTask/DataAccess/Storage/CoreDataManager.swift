//
//  CoreDataManager.swift
//  TenorTrialTask
//
//  Created by Vasyl Mytko on 21.06.2022.
//

import CoreData

protocol CoreDataManager {
    var managedObjectContext: NSManagedObjectContext { get }
    
    func create(object: NSManagedObject)
    func delete(object: NSManagedObject)
    func fetch(with predicate: NSPredicate) -> NSManagedObject? 
}

final class DefaultCoreDataManager: CoreDataManager {
    
    static let shared = DefaultCoreDataManager()
    
    private(set) lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TenorTrialTask")
        container.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("was unable to load store \(error)")
            }
        }
        return container
    }()

    private(set) lazy var managedObjectContext: NSManagedObjectContext = {
        let context = persistentContainer.viewContext
        return context
    }()
    
    func create(object: NSManagedObject) {
        guard managedObjectContext.hasChanges else {
            return
        }
        do {
            try managedObjectContext.save()
        } catch let error {
            print("Error occured while saving: \(error)")
        }
    }
    
    func delete(object: NSManagedObject) {
        managedObjectContext.delete(object)
        do {
            try managedObjectContext.save()
        } catch let error {
            print(error)
        }
    }
    
    func fetch(with predicate: NSPredicate) -> NSManagedObject? {
        do {
            let fetchRequest: NSFetchRequest<GifMO> = GifMO.fetchRequest()
            fetchRequest.predicate = predicate
            let objects = try managedObjectContext.fetch(fetchRequest)
            return objects.first
        } catch let error {
            print("Error occured while saving: \(error)")
            return nil
        }
    }
}

public extension Result where Success == Void {
    static var success: Result {
        return .success(())
    }
}
