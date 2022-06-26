//
//  PaginatedFetchGIFsUseCase.swift
//  TenorTrialTask
//
//  Created by Vasyl Mytko on 26.06.2022.
//

import Foundation

final class PaginatedFetchGIFsUseCase: FetchGIFsUseCase {
    
    private let fetchGIFsUseCase: FetchGIFsUseCase
    private var previouslySearched: String?
    private var nextPage: String?
    
    public init(fetchGIFsUseCase: FetchGIFsUseCase = DefaultFetchGIFsUseCase()) {
        self.fetchGIFsUseCase = fetchGIFsUseCase
    }
    
    func execute(
        searchParamaters: GIFSearchParameters,
        completion: @escaping (Result<GIFsCollection, ErrorMessage>) -> Void
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
        completion: @escaping (Result<GIFsCollection, ErrorMessage>) -> Void
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
