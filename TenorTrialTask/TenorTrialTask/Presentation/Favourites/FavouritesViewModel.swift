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
    var onLoad: PassthroughSubject<Void, Never> { get }
    var dataReloaded: AnyPublisher<Void, Never> { get }
    
    func itemAt(indexPath: IndexPath) -> DefaultGIFCellViewModel?
}

typealias GIFFetchedResultsController = NSFetchedResultsController<GifMO>

final class DefaultFavouritesViewModel: NSObject, FavouritesViewModel {

    let onLoad: PassthroughSubject<Void, Never> = .init()
    let dataReloaded: AnyPublisher<Void, Never>
    
    var numberOfItems: Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    private let dataReloadedSubject: PassthroughSubject<Void, Never> = .init()
    private var cancellable: Set<AnyCancellable> = []
    
    private let fetchedResultsController: GIFFetchedResultsController
    
    init(fetchedResultsController: GIFFetchedResultsController) {
        self.fetchedResultsController = fetchedResultsController
        self.dataReloaded = dataReloadedSubject.eraseToAnyPublisher()
        super.init()
        
        fetchedResultsController.delegate = self
        configureInputs()
    }
 
    func itemAt(indexPath: IndexPath) -> DefaultGIFCellViewModel? {
        let gifMO = fetchedResultsController.object(at: indexPath)
        guard var gif = gifMO.toDomain() else {
            return nil
        }
        gif.isFavourite = false
        return DefaultGIFCellViewModel(gif: gif)
    }
    
    private func configureInputs() {
        onLoad
            .sink { [weak self] in
                try? self?.fetchedResultsController.performFetch()
            }
            .store(in: &cancellable)
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
