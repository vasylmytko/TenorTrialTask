//
//  FavouritesViewModel.swift
//  TenorTrialTask
//
//  Created by Vasyl Mytko on 19.06.2022.
//

import Foundation
import CoreData
import Combine

protocol FavouritesViewModel {
    var numberOfItems: Int { get }
    var dataReloaded: AnyPublisher<Void, Never> { get }
    
    func itemAt(indexPath: IndexPath) -> DefaultGIFCellViewModel?
}

typealias GIFFetchedResultsController = NSFetchedResultsController<GifMO>

final class DefaultFavouritesViewModel: NSObject, FavouritesViewModel {

    private let fetchedResultsController: GIFFetchedResultsController
    private let dataReloadedSubject: PassthroughSubject<Void, Never> = .init()
    
    var numberOfItems: Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    let dataReloaded: AnyPublisher<Void, Never>
    
    init(fetchedResultsController: GIFFetchedResultsController) {
        self.fetchedResultsController = fetchedResultsController
        self.dataReloaded = dataReloadedSubject.eraseToAnyPublisher()
        super.init()
        
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
    }
 
    func itemAt(indexPath: IndexPath) -> DefaultGIFCellViewModel? {
        let gifMO = fetchedResultsController.object(at: indexPath)
        guard var gif = gifMO.toDomain() else {
            return nil
        }
        gif.isFavourite = false
        return DefaultGIFCellViewModel(gif: gif)
    }
}

extension DefaultFavouritesViewModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        dataReloadedSubject.send()
    }
}

extension GifMO {
    func toDomain() -> GIF? {
        guard let id = id, let url = url else {
            return nil
        }
        return .init(
            id: id,
            url: url,
            dimensions: dimensions ?? [],
            isFavourite: true,
            data: data
        )
    }
}
