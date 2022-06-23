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
    func setIsFavourite(_ isFavourite: Bool)
}

final class DefaultGIFCellViewModel: GIFCellViewModel {
    let outputs: GIFCellModel.Outputs
    var id: String {
        return gif.id
    }
    
    var gif: GIF
    private let isFavouriteUpdate: PassthroughSubject<Bool, Never> = .init()
    
    public init(gif: GIF) {
        self.gif = gif
        self.outputs = .init(
            gifURL: Just(gif.url).eraseToAnyPublisher(),
            isFavourite: Publishers.Merge(Just(gif.isFavourite), isFavouriteUpdate).eraseToAnyPublisher()
        )
    }
    
    func setIsFavourite(_ isFavourite: Bool) {
        gif.isFavourite = isFavourite
        isFavouriteUpdate.send(isFavourite)
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
