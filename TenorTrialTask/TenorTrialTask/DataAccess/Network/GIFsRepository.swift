//
//  GIFsRepository.swift
//  TenorTrialTask
//
//  Created by Vasyl Mytko on 18.06.2022.
//

import Foundation

protocol GIFsRepository {
    func fetch(
        searchParameters: GIFSearchParameters,
        completion: @escaping (Result<GIFsCollection, Error>) -> Void
    )
}

final class DefaultGIFsRepository: GIFsRepository {
 
    private let dataService: DataService
    
    init(dataService: DataService = DefaultDataService()) {
        self.dataService = dataService
    }
    
    func fetch(
        searchParameters: GIFSearchParameters,
        completion: @escaping (Result<GIFsCollection, Error>) -> Void
    ) {
        guard let url = buildURL(searchParameters: searchParameters) else {
            return
        }
        dataService.fetch(type: TenorGIFsResponse.self, url: url) { result in
            switch result {
            case .success(let gifsResponse):
                completion(.success(gifsResponse.toDomain()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func buildURL(searchParameters: GIFSearchParameters) -> URL? {
        var urlComponents = URLComponents()
        urlComponents.queryItems = [
            URLQueryItem(name: "q", value: searchParameters.searchTerm),
            URLQueryItem(name: "key", value: "AIzaSyBGP9Dix-_BQJH0uI7gLIiihKs8Q0Wcu48"),
            URLQueryItem(name: "media_filter", value: "gif")
        ]
        if let page = searchParameters.page {
            urlComponents.queryItems?.append(URLQueryItem(name: "pos", value: page))
        }
        urlComponents.scheme = "https"
        urlComponents.host = "tenor.googleapis.com"
        urlComponents.path = "/v2/search"
        return urlComponents.url
    }
}
