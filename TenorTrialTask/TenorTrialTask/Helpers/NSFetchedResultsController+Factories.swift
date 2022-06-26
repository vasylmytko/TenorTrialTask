//
//  NSFetchedResultsController+Factories.swift
//  TenorTrialTask
//
//  Created by Vasyl Mytko on 26.06.2022.
//

import CoreData

extension NSFetchedResultsController where ResultType == GifMO {
    static func makeGIFs() -> NSFetchedResultsController<GifMO> {
        let sortDescriptor = NSSortDescriptor(key: "dateCreated", ascending: false)
        let fetchRequest: NSFetchRequest<GifMO> = GifMO.fetchRequest()
        fetchRequest.sortDescriptors = [sortDescriptor]
        return GIFFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: DefaultCoreDataManager.shared.managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
    }
}
