//
//  GIFsEndpoint.swift
//  TenorTrialTask
//
//  Created by Vasyl Mytko on 26.06.2022.
//

import Foundation

protocol GIFsEndpoint {
    func fetch(
        searchParameters: GIFSearchParameters,
        completion: @escaping (Result<GIFsCollection, ErrorMessage>) -> Void
    )
}
