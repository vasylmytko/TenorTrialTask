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
    enum State {
        case idle(StateInfo)
        case loading
        case error(StateInfo)
        case results([DefaultGIFCellViewModel])
    }
    
    struct Inputs {
        let onAppear: PassthroughSubject<Void, Never>
        let search: PassthroughSubject<String?, Never>
        let reachedBottom: PassthroughSubject<Void, Never>
        let selectedIndexPath: PassthroughSubject<IndexPath, Never>
    }
    
    struct Outputs {
        let state: AnyPublisher<State, Never>
    }
}

protocol SearchGIFsViewModel {
    var inputs: SearchGIFs.Inputs { get }
    var outputs: SearchGIFs.Outputs { get }
}

final class DefaultSearchGIFsViewModel: SearchGIFsViewModel {
    
    let inputs: SearchGIFs.Inputs
    let outputs: SearchGIFs.Outputs
    
    private var cancellable: Set<AnyCancellable> = []
    private let stateSubject: CurrentValueSubject<SearchGIFs.State, Never> = .init(.loading)
    private let gifSelected: AnyPublisher<DefaultGIFCellViewModel, Never>
    
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
            state: stateSubject.eraseToAnyPublisher()
        )
        let gifs = outputs.state
            .compactMap { state -> [DefaultGIFCellViewModel]? in
                if case .results(let viewModels) = state {
                    return viewModels
                } else {
                    return nil
                }
            }
            .eraseToAnyPublisher()
        
        self.gifSelected = inputs.selectedIndexPath.viewModel(viewModels: gifs)
        configureInputs()
        configureOutputs()
    }
    
    private func configureInputs() {
        gifSelected
            .sink { [weak self] viewModel in
                self?.selectedGif(viewModel)
            }
            .store(in: &cancellable)
    }
    
    private func configureOutputs() {
        let onAppear = inputs.onAppear
            .map { String.defaultSearchTerm }
            .mapToOptional()
            
        let loading = inputs.search
            .compactMap { $0 }
            .map { $0.isEmpty ? SearchGIFs.State.idle(.idleInfo) : SearchGIFs.State.loading }
        
        let textChanged = inputs.search
            .removeDuplicates()
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
        
        let reachedBottom = inputs.reachedBottom
            .withLatestFrom(inputs.search.prepend(.defaultSearchTerm))
        
        let loaded = Publishers.Merge3(textChanged, reachedBottom, onAppear)
            .filterOutEmpty()
            .searchGIFs(useCaseProvider: { [weak self] in self?.fetchGIFsUseCase })
            .scan(.initial) { (result, nextSearchResult) -> SearchResult in
                if result.searchTerm == nextSearchResult.searchTerm {
                    return SearchResult(
                        searchTerm: nextSearchResult.searchTerm,
                        gifsViewModels: result.gifsViewModels + nextSearchResult.gifsViewModels
                    )
                } else {
                    return nextSearchResult
                }
            }
            .map { SearchGIFs.State.results($0.gifsViewModels) }
            .catch { _ in Just(SearchGIFs.State.error(.errorInfo)) }
    
        Publishers.Merge(loading, loaded)
            .subscribe(stateSubject)
            .store(in: &cancellable)
    }
    
    private func selectedGif(_ gifCellViewModel: DefaultGIFCellViewModel) {
        gifCellViewModel.toggleIsFavourite()
        updateFavouritesUseCase.execute(gif: gifCellViewModel.gif)
    }
}

extension String {
    static let defaultSearchTerm = "Hello"
}

struct SearchResult {
    let searchTerm: String
    let gifsViewModels: [DefaultGIFCellViewModel]
    
    static let initial = SearchResult(searchTerm: "", gifsViewModels: [])
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
                            promise(.success(SearchResult(
                                searchTerm: searchTerm,
                                gifsViewModels: page.gifs.map { DefaultGIFCellViewModel(gif: $0) })
                            ))
                        case .failure(let error):
                            promise(.failure(error))
                        }
                    }
                }
            }
            .eraseToAnyPublisher()
    }
}

extension Publisher where Output == IndexPath {
    func viewModel(
        viewModels: AnyPublisher<[DefaultGIFCellViewModel], Failure>
    ) -> AnyPublisher<DefaultGIFCellViewModel, Failure> {
        return map(\.item)
            .withLatestFrom(viewModels) { index, models in
                return models[index]
            }
            .eraseToAnyPublisher()
    }
}
