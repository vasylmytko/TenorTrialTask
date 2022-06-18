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
        let search: PassthroughSubject<String?, Never>
        let indexWillBeDisplayed: PassthroughSubject<IndexPath, Never>
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
    let next: String
}

extension TenorGIFsResponse {
    func toDomain() -> GIFCollectionPage {
        return .init(gifs: results.map { $0.toDomain() }, next: next)
    }
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

struct GIFCollectionPage {
    let gifs: [GIF]
    let next: String
}

final class DefaultGIFsCollectionViewModel: GIFsCollectionViewModel {
    
    let inputs: GIFsCollection.Inputs
    let outputs: GIFsCollection.Outputs
    
    private let itemsSubject: CurrentValueSubject<[GIF], Never> = .init([])
    private let dataService: DataService
    private var cancellable: Set<AnyCancellable> = []
    private var searchTerm: String?
    private var next: String?
    
    init(dataService: DataService = DefaultDataService()) {
        self.dataService = dataService
        self.inputs = .init(
            onAppear: .init(),
            search: .init(),
            indexWillBeDisplayed: .init()
        )
        self.outputs = .init(items: itemsSubject.eraseToAnyPublisher())
        
        configureInputs()
    }
    
    private func configureInputs() {
        inputs.onAppear
            .sink { [weak self] in
                self?.fetchGIFs(for: "hello")
            }
            .store(in: &cancellable)
        
        inputs.search
            .removeDuplicates()
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] searchTerm in
                self?.next = nil
                self?.itemsSubject.value = []
                self?.fetchGIFs(for: searchTerm)
            }
            .store(in: &cancellable)
        
        inputs.indexWillBeDisplayed
            .combineLatest(inputs.search)
            .filter { (indexPath, _) in
                indexPath.item == self.itemsSubject.value.count - 1
            }
            .sink { [weak self] (indexPath, searchTerm) in
                guard let self = self else {
                    return
                }
                self.fetchGIFs(for: searchTerm ?? "")
            }
            .store(in: &cancellable)
    }
    
    private func fetchGIFs(for searchTerm: String) {
        guard let url = buildURL(searchTerm: searchTerm, next: next) else {
            return
        }
        dataService.fetch(type: TenorGIFsResponse.self, url: url) { [weak self] result in
            switch result {
            case .success(let gifsResponse):
                self?.next = gifsResponse.next
                self?.itemsSubject.value.append(contentsOf: gifsResponse.results.map { $0.toDomain() })
            case .failure:
                break
            }
        }
    }
    
    private func buildURL(searchTerm: String, next: String?) -> URL? {
        var urlComponents = URLComponents()
        urlComponents.queryItems = [
            URLQueryItem(name: "q", value: searchTerm),
            URLQueryItem(name: "key", value: "AIzaSyBGP9Dix-_BQJH0uI7gLIiihKs8Q0Wcu48"),
            URLQueryItem(name: "media_filter", value: "gif")
        ]
        if let next = next {
            urlComponents.queryItems?.append(URLQueryItem(name: "pos", value: next))
        }
        urlComponents.scheme = "https"
        urlComponents.host = "tenor.googleapis.com"
        urlComponents.path = "/v2/search"
        return urlComponents.url
    }
}

public extension Publisher {
    func mapToVoid() -> AnyPublisher<Void, Failure> {
        return map { _ in }.eraseToAnyPublisher()
    }
}
