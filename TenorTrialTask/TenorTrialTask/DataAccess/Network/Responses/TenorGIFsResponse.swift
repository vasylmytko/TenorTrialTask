//
//  TenorGIFsResponse.swift
//  TenorTrialTask
//
//  Created by Vasyl Mytko on 21.06.2022.
//

import Foundation

struct TenorGIFsResponse: Decodable {
    let results: [TenorGIF]
    let next: String
}

extension TenorGIFsResponse {
    func toDomain() -> GIFsCollection {
        return .init(gifs: results.map { $0.toDomain() }, next: next)
    }
}
