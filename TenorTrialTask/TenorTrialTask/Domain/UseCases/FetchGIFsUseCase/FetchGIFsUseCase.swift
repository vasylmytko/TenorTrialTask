//
//  FetchGIFsUseCase.swift
//  TenorTrialTask
//
//  Created by Vasyl Mytko on 26.06.2022.
//

import Foundation

protocol FetchGIFsUseCase: AnyObject {
    func execute(
        searchParamaters: GIFSearchParameters,
        completion: @escaping (Result<GIFsCollection, ErrorMessage>) -> Void
    )
}
