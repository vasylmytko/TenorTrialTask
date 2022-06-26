//
//  DefaultFetchGIFsUseCase.swift
//  TenorTrialTask
//
//  Created by Vasyl Mytko on 21.06.2022.
//

import Foundation

final class DefaultFetchGIFsUseCase: FetchGIFsUseCase {
    
    private let gifsEndpoint: GIFsEndpoint
    private let favouritesStorage: FavouritesStorage
    
    init(
        gifsEndpoint: GIFsEndpoint = DefaultGIFsEndpoint(),
        favouritesStorage: FavouritesStorage = CoreDataFavouritesStorage()
    ) {
        self.gifsEndpoint = gifsEndpoint
        self.favouritesStorage = favouritesStorage
    }
    
    func execute(
        searchParamaters: GIFSearchParameters,
        completion: @escaping (Result<GIFsCollection, ErrorMessage>) -> Void
    ) {
        gifsEndpoint.fetch(searchParameters: searchParamaters) { [weak self] result in
            switch result {
            case .success(let collection):
                self?.checkFavourites(in: collection, completion: completion)
            case .failure(let error):
                completion(.failure(.init(error)))
            }
        }
    }
    
    private func checkFavourites(
        in collection: GIFsCollection,
        completion: @escaping (Result<GIFsCollection, ErrorMessage>) -> Void
    ) {
        let checkedIfFavourite = collection.gifs.map { gif in
            return mutated(gif) { $0.isFavourite = favouritesStorage.isFavourite(gif: gif) }
        }
        completion(.success(GIFsCollection(gifs: checkedIfFavourite, next: collection.next)))
    }
}
