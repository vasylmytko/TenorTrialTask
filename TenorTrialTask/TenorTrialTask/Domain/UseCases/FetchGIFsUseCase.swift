//
//  FetchGIFsUseCase.swift
//  TenorTrialTask
//
//  Created by Vasyl Mytko on 21.06.2022.
//

import Foundation

protocol FetchGIFsUseCase {
    func execute(
        searchParamaters: GIFSearchParameters,
        completion: @escaping (Result<GIFCollectionPage, Error>) -> Void
    )
}

struct GIFSearchParameters {
    let searchTerm: String
    let next: String?
}

final class DefaultFetchGIFsUseCase: FetchGIFsUseCase {
    
    private let gifsRepository: GIFsRepository
    private let favouritesStorage: FavouritesStorage
    
    init(
        gifsRepository: GIFsRepository = DefaultGIFsRepository(),
        favouritesStorage: FavouritesStorage = CoreDataFavouritesStorage()
    ) {
        self.gifsRepository = gifsRepository
        self.favouritesStorage = favouritesStorage
    }
    
    func execute(
        searchParamaters: GIFSearchParameters,
        completion: @escaping (Result<GIFCollectionPage, Error>) -> Void
    ) {
        gifsRepository.fetch(searchParameters: searchParamaters) { [weak self] result in
            switch result {
            case .success(let collection):
                self?.checkFavourites(in: collection, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func checkFavourites(
        in collection: GIFCollectionPage,
        completion: @escaping (Result<GIFCollectionPage, Error>) -> Void
    ) {
        let checkedIfFavourite = collection.gifs.map { gif in
            return GIF(
                id: gif.id,
                url: gif.url,
                dimensions: gif.dimensions,
                isFavourite: favouritesStorage.isFavourite(gif: gif)
            )
        }
        completion(.success(GIFCollectionPage(gifs: checkedIfFavourite, next: collection.next)))
    }
}
