//
//  FavouritesStorage.swift
//  TenorTrialTask
//
//  Created by Vasyl Mytko on 26.06.2022.
//

import Foundation

protocol FavouritesStorage {
    func add(gif: GIF)
    func remove(gif: GIF)
    func isFavourite(gif: GIF) -> Bool
}
