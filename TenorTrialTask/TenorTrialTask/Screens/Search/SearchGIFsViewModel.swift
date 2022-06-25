//
//  SearchGIFsViewModel.swift
//  TenorTrialTask
//
//  Created by Vasyl Mytko on 17.06.2022.
//

import Foundation
import Combine
import CombineExt

struct SearchGIFs {
    struct Inputs {
        let onAppear: PassthroughSubject<Void, Never>
        let search: PassthroughSubject<String?, Never>
        let reachedBottom: PassthroughSubject<Void, Never>
        let selectedIndexPath: PassthroughSubject<IndexPath, Never>
    }
    
    struct Outputs {
        let items: AnyPublisher<[DefaultGIFCellViewModel], Never>
    }
}

protocol SearchGIFsViewModel {
    var inputs: SearchGIFs.Inputs { get }
    var outputs: SearchGIFs.Outputs { get }
}

final class DefaultSearchGIFsViewModel: SearchGIFsViewModel {
    
    let inputs: SearchGIFs.Inputs
    let outputs: SearchGIFs.Outputs
    
    private let viewModelsSubject: CurrentValueSubject<[DefaultGIFCellViewModel], Never> = .init([])
    private var cancellable: Set<AnyCancellable> = []
    
    private let fetchGIFsUseCase: FetchGIFsUseCase
    private let updateFavouritesUseCase: UpdateFavouritesUseCase
    
    init(
        fetchGIFsUseCase: FetchGIFsUseCase = PaginatedFetchGIFsUseCase(),
        updateFavouritesUseCase: UpdateFavouritesUseCase = DefaultUpdateFavouritesUseCase()
    ) {
        self.fetchGIFsUseCase = fetchGIFsUseCase
        self.updateFavouritesUseCase = updateFavouritesUseCase
        self.inputs = .init(
            onAppear: .init(),
            search: .init(),
            reachedBottom: .init(),
            selectedIndexPath: .init()
        )
        self.outputs = .init(
            items: viewModelsSubject.eraseToAnyPublisher()
        )
        configureInputs()
        configureOutputs()
    }
    
    private func configureInputs() {
        inputs.selectedIndexPath
            .sink { [weak self] indexPath in
                self?.selectedGIF(at: indexPath)
            }
            .store(in: &cancellable)
    }
    
    private func configureOutputs() {
        let onAppear = inputs.onAppear
            .map { String.defaultSearchTerm }
            .mapToOptional()
            
        let textChanged = inputs.search
            .removeDuplicates()
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
        
        let reachedBottom = inputs.reachedBottom
            .withLatestFrom(inputs.search.prepend(nil))
        
        Publishers.Merge3(onAppear, textChanged, reachedBottom)
            .replaceNil(with: .defaultSearchTerm)
            .replaceEmpty(with: .defaultSearchTerm)
            .searchGIFs(useCaseProvider: { [weak self] in self?.fetchGIFsUseCase })
            .ignoreFailure()
            .scan(.initial) { (result, nextSearchResult) -> SearchResult in
                if result.searchTerm == nextSearchResult.searchTerm {
                    return SearchResult(searchTerm: nextSearchResult.searchTerm, gifs: result.gifs + nextSearchResult.gifs)
                } else {
                    return nextSearchResult
                }
            }
            .map { searchResult in
                searchResult.gifs.map { DefaultGIFCellViewModel(gif: $0) }
            }
            .subscribe(viewModelsSubject)
            .store(in: &cancellable)
    }
    
    private func selectedGIF(at indexPath: IndexPath) {
        guard viewModelsSubject.value.indices.contains(indexPath.item) else {
            return
        }
        let viewModel = viewModelsSubject.value[indexPath.item]
        viewModelsSubject.value[indexPath.item].setIsFavourite(!viewModel.gif.isFavourite)
        var gif = viewModel.gif
        gif.isFavourite.toggle()
        updateFavouritesUseCase.execute(gif: gif)
    }
}

public extension Publisher {
    func mapToVoid() -> AnyPublisher<Void, Failure> {
        return map { _ in }.eraseToAnyPublisher()
    }
    
    func mapToOptional() -> AnyPublisher<Output?, Failure> {
        map { Optional<Output>.some($0) }.eraseToAnyPublisher()
    }
}

extension String {
    static let defaultSearchTerm = "Hello"
}

struct SearchResult {
    let searchTerm: String
    let gifs: [GIF]
    
    static let initial = SearchResult(searchTerm: "", gifs: [])
}

extension Publisher where Output: Collection {
    func replaceEmpty(with defaultValue: Output) -> AnyPublisher<Output, Failure> {
        map { $0.isEmpty ? defaultValue : $0 }.eraseToAnyPublisher()
    }
}

extension Publisher where Output == String, Failure == Never {
    func searchGIFs(
        useCaseProvider: @escaping () -> FetchGIFsUseCase?
    ) -> AnyPublisher<SearchResult, Error> {
        return self
            .flatMap { searchTerm in
                return Future { promise in
                    useCaseProvider()?.execute(searchParamaters: .init(searchTerm: searchTerm, page: nil)) { result in
                        switch result {
                        case .success(let page):
                            promise(.success(SearchResult(searchTerm: searchTerm, gifs: page.gifs)))
                        case .failure(let error):
                            promise(.failure(error))
                        }
                    }
                }
            }
            .eraseToAnyPublisher()
    }
}
