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

struct TenorGIFsResponse: Decodable {
    let results: [TenorGIF]
}

struct TenorGIF: Decodable {
    let id: String
    let itemURL: URL
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try values.decode(String.self, forKey: .id)
        self.itemURL = try values.decode(URL.self, forKey: .itemURL).appendingPathExtension("gif")
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case itemURL = "itemurl"
    }
}

extension TenorGIF {
    func toDomain() -> GIF {
        return .init(id: id, url: itemURL)
    }
}

struct GIF {
    let id: String
    let url: URL
}

final class DefaultGIFsCollectionViewModel: GIFsCollectionViewModel {
    
    let inputs: GIFsCollection.Inputs
    let outputs: GIFsCollection.Outputs
    
    private let itemsSubject: CurrentValueSubject<[GIF], Never> = .init([])
    private let dataService: DataService
    private var cancellable: Set<AnyCancellable> = []
    
    init(dataService: DataService = DefaultDataService()) {
        self.dataService = dataService
        self.inputs = .init(onAppear: .init())
        self.outputs = .init(items: itemsSubject.eraseToAnyPublisher())
        
        configureInputs()
    }
    
    private func configureInputs() {
        inputs.onAppear
            .sink { [weak self] in
                self?.fetchGIFs()
            }
            .store(in: &cancellable)
    }
    
    private func fetchGIFs() {
        guard let url = buildURL() else {
            return
        }
        dataService.fetch(type: TenorGIFsResponse.self, url: url) { [weak self] result in
            switch result {
            case .success(let gifsResponse):
                self?.itemsSubject.send(gifsResponse.results.map { $0.toDomain() })
            case .failure:
                break
            }
        }
    }
    
    private func buildURL() -> URL? {
        var urlComponents = URLComponents()
        urlComponents.queryItems = [
            URLQueryItem(name: "q", value: "okay"),
            URLQueryItem(name: "key", value: "AIzaSyBGP9Dix-_BQJH0uI7gLIiihKs8Q0Wcu48"),
            URLQueryItem(name: "limit", value: "8"),
            URLQueryItem(name: "media_filter", value: "gif")
        ]
        urlComponents.scheme = "https"
        urlComponents.host = "tenor.googleapis.com"
        urlComponents.path = "/v2/search"
        return urlComponents.url
    }
}
