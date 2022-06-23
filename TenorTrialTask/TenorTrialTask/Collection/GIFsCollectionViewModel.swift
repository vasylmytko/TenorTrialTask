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
        let selectedIndexPath: PassthroughSubject<IndexPath, Never>
    }
    
    struct Outputs {
        let items: AnyPublisher<[DefaultGIFCellViewModel], Never>
    }
}

protocol GIFsCollectionViewModel {
    var inputs: GIFsCollection.Inputs { get }
    var outputs: GIFsCollection.Outputs { get }
}

final class DefaultGIFsCollectionViewModel: GIFsCollectionViewModel {
    
    let inputs: GIFsCollection.Inputs
    let outputs: GIFsCollection.Outputs
    
    private let viewModelsSubject: CurrentValueSubject<[DefaultGIFCellViewModel], Never> = .init([])
    private var cancellable: Set<AnyCancellable> = []
    private var searchTerm: String?
    
    private let paginatedRepository: GIFPaginatedRepository
    private let favouritesStorage: FavouritesStorage
    private let updateFavouritesUseCase: UpdateFavouritesUseCase
    
    init(
        paginatedRepository: GIFPaginatedRepository = DefaultGIFPaginatedDataSource(),
        favouritesStorage: FavouritesStorage = CoreDataFavouritesStorage(),
        updateFavouritesUseCase: UpdateFavouritesUseCase = DefaultUpdateFavouritesUseCase()
    ) {
        self.paginatedRepository = paginatedRepository
        self.favouritesStorage = favouritesStorage
        self.updateFavouritesUseCase = updateFavouritesUseCase
        self.inputs = .init(
            onAppear: .init(),
            search: .init(),
            indexWillBeDisplayed: .init(),
            selectedIndexPath: .init()
        )
        self.outputs = .init(
            items: viewModelsSubject.eraseToAnyPublisher()
        )
        self.paginatedRepository.gifsUpdate = { [weak self] gifs in
            self?.viewModelsSubject.send(gifs.map {
                DefaultGIFCellViewModel(gif: $0)
            })
        }
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
                self?.fetchGIFs(for: searchTerm)
            }
            .store(in: &cancellable)
        
        inputs.indexWillBeDisplayed
            .combineLatest(inputs.search.prepend("hello"))
            .filter { (indexPath, _) in
                return indexPath.item == self.viewModelsSubject.value.count - 1
            }
            .compactMap { $0.1 }
            .sink { [weak self] searchTerm in
                self?.fetchGIFs(for: searchTerm)
            }
            .store(in: &cancellable)
        
        inputs.selectedIndexPath
            .sink { [weak self] indexPath in
                self?.selectedGIF(at: indexPath)
            }
            .store(in: &cancellable)
    }
    
    private func fetchGIFs(for searchTerm: String) {
        paginatedRepository.fetch(searchTerm: searchTerm)
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
}

extension GIFSearchParameters {
    static let `default` = GIFSearchParameters(searchTerm: "hello", next: nil)
}
