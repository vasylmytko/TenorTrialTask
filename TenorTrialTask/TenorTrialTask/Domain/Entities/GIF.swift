//
//  GIF.swift
//  TenorTrialTask
//
//  Created by Vasyl Mytko on 21.06.2022.
//

import Foundation

struct GIF: Hashable {
    let id: String
    let url: URL
    let dimensions: [Int]
    var isFavourite: Bool
    let data: Data? = nil
}
