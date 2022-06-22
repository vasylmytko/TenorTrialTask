//
//  GIF.swift
//  TenorTrialTask
//
//  Created by Vasyl Mytko on 21.06.2022.
//

import Foundation

struct GIF: HashableByID {
    let id: String
    let url: URL
    let dimensions: [Int]
    var isFavourite: Bool
}

struct GIFCollectionPage {
    let gifs: [GIF]
    let next: String
}
