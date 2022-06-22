//
//  FavouritesStorage.swift
//  TenorTrialTask
//
//  Created by Vasyl Mytko on 21.06.2022.
//

import Foundation
import CoreData

protocol FavouritesStorage {
    func update(gif: GIF)
    func isFavourite(gif: GIF) -> Bool
}

final class CoreDataFavouritesStorage: FavouritesStorage {
    
    private let coreDataStorage: CoreDataManager
    
    init(coreDataStorage: CoreDataManager = DefaultCoreDataManager.shared) {
        self.coreDataStorage = coreDataStorage
    }
    
    func update(gif: GIF) {
        if gif.isFavourite {
            let gifMO = gif.toManagedObject(context: coreDataStorage.managedObjectContext)
            coreDataStorage.create(object: gifMO) { _ in
                print("saved")
            }
        } else {
            let predicate = NSPredicate(format: "id == %@", gif.id)
            let fetchedObject = coreDataStorage.fetch(with: predicate)
            guard let fetchedObject = fetchedObject else {
                return
            }
            coreDataStorage.delete(object: fetchedObject)
        }
    }
    
    func isFavourite(gif: GIF) -> Bool {
        let predicate = NSPredicate(format: "id == %@", gif.id)
        return coreDataStorage.fetch(with: predicate) != nil
    }
}

extension GIF {
    func toManagedObject(context: NSManagedObjectContext) -> GifMO {
        let gifMO = GifMO(context: context)
        gifMO.id = id
        gifMO.url = url
        return gifMO
    }
}
