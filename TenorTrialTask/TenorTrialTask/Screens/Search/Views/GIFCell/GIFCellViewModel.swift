//
//  GIFCellViewModel.swift
//  TenorTrialTask
//
//  Created by Vasyl Mytko on 23.06.2022.
//

import Foundation
import Combine

protocol GIFCellViewModel: HashableByID {
    var gif: GIF { get }
    var isFavourite: AnyPublisher<Bool, Never> { get }
    
    func toggleIsFavourite()
}

final class DefaultGIFCellViewModel: GIFCellViewModel {
    var id: String {
        return gif.id
    }
    
    let isFavourite: AnyPublisher<Bool, Never>
    private let isFavouriteUpdate: CurrentValueSubject<Bool, Never>
    private(set) var gif: GIF
    
    public init(gif: GIF) {
        self.gif = gif
        self.isFavouriteUpdate = .init(gif.isFavourite)
        self.isFavourite = isFavouriteUpdate.eraseToAnyPublisher()
    }
    
    func toggleIsFavourite() {
        gif.isFavourite.toggle()
        isFavouriteUpdate.send(gif.isFavourite)
    }
}

public protocol HashableByID: Hashable, Identifiable { }

extension HashableByID {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}
