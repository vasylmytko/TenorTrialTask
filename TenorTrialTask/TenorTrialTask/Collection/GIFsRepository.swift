//
//  GIFsRepository.swift
//  TenorTrialTask
//
//  Created by Vasyl Mytko on 18.06.2022.
//

import Foundation

protocol GIFsRepository {
    func fetch()
}

final class DefaultGIFsRepository: GIFsRepository {
    
    private let dataService: DataService
    
    init(dataService: DataService) {
        self.dataService = dataService
    }
    
    func fetch() {
        
    }
}
