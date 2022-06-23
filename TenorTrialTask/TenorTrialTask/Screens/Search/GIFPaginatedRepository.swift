//
//  GIFPaginatedRepository.swift
//  TenorTrialTask
//
//  Created by Vasyl Mytko on 21.06.2022.
//

import Foundation
import Combine
import UIKit

enum SingleSection: Hashable {
    case main
}

typealias GIFsSnapshot = NSDiffableDataSourceSnapshot<SingleSection, GIF>

protocol GIFPaginatedRepository: AnyObject {
    var gifsUpdate: (([GIF]) -> Void)? { get set }

    func fetch(searchTerm: String)
}

final class DefaultGIFPaginatedDataSource: GIFPaginatedRepository {
    
    private let fetchGIFsUseCase: FetchGIFsUseCase
    private var searchedParameters: GIFSearchParameters?
    private var nextPage: String?
    private var snapshot: GIFsSnapshot = .init()
    
    private var gifs: [GIF] = []
    var gifsUpdate: (([GIF]) -> Void)?
    var snapshotUpdate: ((GIFsSnapshot) -> Void)?
    
    init(fetchGIFsUseCase: FetchGIFsUseCase = DefaultFetchGIFsUseCase()) {
        self.fetchGIFsUseCase = fetchGIFsUseCase
    }

    func fetch(searchTerm: String) {
        if searchedParameters?.searchTerm == searchTerm {
            fetch(searchParameters: .init(searchTerm: searchTerm, next: nextPage))
        } else {
            gifs.removeAll()
            gifsUpdate?(gifs)
            fetch(searchParameters: .init(searchTerm: searchTerm, next: nil))
        }
    }
    
    private func fetch(searchParameters: GIFSearchParameters) {
        fetchGIFsUseCase.execute(searchParamaters: searchParameters) { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let gifsCollection):
                self.gifs.append(contentsOf: gifsCollection.gifs)
                self.searchedParameters = searchParameters
                self.nextPage = gifsCollection.next
                self.gifsUpdate?(self.gifs)
            case .failure(let error):
                print("error occured")
            }
        }
    }
}
