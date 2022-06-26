//
//  GIFCellViewModel.swift
//  TenorTrialTask
//
//  Created by Vasyl Mytko on 23.06.2022.
//

import Foundation
import Combine

struct GIFCellModel {
    struct Outputs {
        let gifURL: AnyPublisher<URL, Never>
        let isFavourite: AnyPublisher<Bool, Never>
    }
}

protocol GIFCellViewModel: HashableByID {
    var gif: GIF { get }
    var outputs: GIFCellModel.Outputs { get }
    func toggleIsFavourite()
}

final class DefaultGIFCellViewModel: GIFCellViewModel {
    let outputs: GIFCellModel.Outputs
    var id: String {
        return gif.id
    }
    
    private(set) var gif: GIF
    private let isFavouriteUpdate: CurrentValueSubject<Bool, Never>
    
    public init(gif: GIF) {
        self.gif = gif
        self.isFavouriteUpdate = .init(gif.isFavourite)
        self.outputs = .init(
            gifURL: Just(gif.url).eraseToAnyPublisher(),
            isFavourite: isFavouriteUpdate.eraseToAnyPublisher()
        )
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
