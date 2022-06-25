//
//  FetchGIFsUseCase.swift
//  TenorTrialTask
//
//  Created by Vasyl Mytko on 21.06.2022.
//

import Foundation

protocol FetchGIFsUseCase: AnyObject {
    func execute(
        searchParamaters: GIFSearchParameters,
        completion: @escaping (Result<GIFsCollection, Error>) -> Void
    )
}

struct GIFSearchParameters {
    let searchTerm: String
    let page: String?
}

final class PaginatedFetchGIFsUseCase: FetchGIFsUseCase {
    
    private let fetchGIFsUseCase: FetchGIFsUseCase
    private var previouslySearched: String?
    private var nextPage: String?
    
    public init(fetchGIFsUseCase: FetchGIFsUseCase = DefaultFetchGIFsUseCase()) {
        self.fetchGIFsUseCase = fetchGIFsUseCase
    }
    
    func execute(
        searchParamaters: GIFSearchParameters,
        completion: @escaping (Result<GIFsCollection, Error>) -> Void
    ) {
        let sameSearchTerm = searchParamaters.searchTerm == previouslySearched
        guard let nextPage = nextPage, sameSearchTerm else {
            nextPage = nil
            previouslySearched = nil
            fetch(searchParameters: searchParamaters, completion: completion)
            return
        }
        let paginatedSearchParameters = GIFSearchParameters(
            searchTerm: searchParamaters.searchTerm,
            page: nextPage
        )
        fetch(searchParameters: paginatedSearchParameters, completion: completion)
    }
    
    private func fetch(
        searchParameters: GIFSearchParameters,
        completion: @escaping (Result<GIFsCollection, Error>) -> Void
    ) {
        fetchGIFsUseCase.execute(searchParamaters: searchParameters) { [weak self] result in
            switch result {
            case .success(let page):
                self?.previouslySearched = searchParameters.searchTerm
                self?.nextPage = page.next
                completion(.success(page))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
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
        completion: @escaping (Result<GIFsCollection, Error>) -> Void
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
        in collection: GIFsCollection,
        completion: @escaping (Result<GIFsCollection, Error>) -> Void
    ) {
        let checkedIfFavourite = collection.gifs.map { gif in
            return GIF(
                id: gif.id,
                url: gif.url,
                dimensions: gif.dimensions,
                isFavourite: favouritesStorage.isFavourite(gif: gif)
            )
        }
        completion(.success(GIFsCollection(gifs: checkedIfFavourite, next: collection.next)))
    }
}
