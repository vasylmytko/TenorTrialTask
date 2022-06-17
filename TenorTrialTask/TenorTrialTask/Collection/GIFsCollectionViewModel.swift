//
//  GIFsCollectionViewModel.swift
//  TenorTrialTask
//
//  Created by Vasyl Mytko on 17.06.2022.
//

import Foundation
import Combine

struct GIFsCollection {
    struct Inputs {
        let onAppear: PassthroughSubject<Void, Never>
    }
    
    struct Outputs {
        let items: AnyPublisher<[GIF], Never>
    }
}

protocol GIFsCollectionViewModel {
    var inputs: GIFsCollection.Inputs { get }
    var outputs: GIFsCollection.Outputs { get }
}

struct GIFsRepsonse: Decodable {
    let results: [GIF]
}

struct GIF: Decodable {
    let id: String
    let url: URL
}

final class DefaultGIFsCollectionViewModel: GIFsCollectionViewModel {
    
    let inputs: GIFsCollection.Inputs
    let outputs: GIFsCollection.Outputs
    
    private let itemsSubject: CurrentValueSubject<[GIF], Never> = .init([])
    private let dataService: DataService
    
    init(dataService: DataService = DefaultDataService()) {
        self.dataService = dataService
        self.inputs = .init(onAppear: .init())
        self.outputs = .init(items: itemsSubject.eraseToAnyPublisher())
    }
    
    func onAppear() {
        guard let url = buildURL() else {
            return
        }
        dataService.fetch(type: GIFsRepsonse.self, url: url) { [weak self] result in
            switch result {
            case .success(let gifsResponse):
                self?.itemsSubject.send(gifsResponse.results)
            case .failure:
                break
            }
        }
    }
    
    private func buildURL() -> URL? {
        var urlComponents = URLComponents()
        urlComponents.queryItems = [
            URLQueryItem(name: "q", value: "hello"),
            URLQueryItem(name: "key", value: "hello"),
            URLQueryItem(name: "limit", value: "8")
        ]
        urlComponents.host = "g.tenor.com"
        urlComponents.path = "/v1/search_suggestions"
        return urlComponents.url
    }
}
