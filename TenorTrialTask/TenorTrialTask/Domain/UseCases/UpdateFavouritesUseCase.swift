//
//  UpdateFavouritesUseCase.swift
//  TenorTrialTask
//
//  Created by Vasyl Mytko on 23.06.2022.
//

import Foundation

@discardableResult
public func mutated<T>(_ value: T, configure: (inout T) -> Void) -> T {
    var copy = value
    configure(&copy)
    return copy
}

protocol UpdateFavouritesUseCase {
    func execute(gif: GIF)
}

final class DefaultUpdateFavouritesUseCase: UpdateFavouritesUseCase {
    
    private let favouritesStorage: FavouritesStorage
    
    init(favouritesStorage: FavouritesStorage = CoreDataFavouritesStorage()) {
        self.favouritesStorage = favouritesStorage
    }
    
    func execute(gif: GIF) {
        if gif.isFavourite {
            makeFavourite(gif: gif)
        } else {
            favouritesStorage.remove(gif: gif)
        }
    }
    
    private func makeFavourite(gif: GIF) {
        if favouritesStorage.isFavourite(gif: gif) {
            return
        }
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: gif.url)
            DispatchQueue.main.async {
                self.favouritesStorage.add(gif: mutated(gif) { $0.data = data })
            }
        }
    }
}
