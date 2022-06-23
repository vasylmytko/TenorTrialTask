//
//  UpdateFavouritesUseCase.swift
//  TenorTrialTask
//
//  Created by Vasyl Mytko on 23.06.2022.
//

import Foundation

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
            favouritesStorage.remove(gif: gif)
        } else {
            favouritesStorage.add(gif: gif)
        }
    }
}
