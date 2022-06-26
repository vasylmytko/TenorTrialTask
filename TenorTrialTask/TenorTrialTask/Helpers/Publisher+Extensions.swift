//
//  Publisher+Extensions.swift
//  TenorTrialTask
//
//  Created by Vasyl Mytko on 26.06.2022.
//

import Combine

extension Publisher {
    func mapToVoid() -> AnyPublisher<Void, Failure> {
        return map { _ in }.eraseToAnyPublisher()
    }
    
    func mapToOptional() -> AnyPublisher<Output?, Failure> {
        map { Optional<Output>.some($0) }.eraseToAnyPublisher()
    }
}

extension Publisher where Output == Bool {
    func toggle() -> Publishers.Map<Self, Bool> {
        map(!)
    }
}

extension Publisher where Output: Collection {
    func replaceEmpty(with defaultValue: Output) -> AnyPublisher<Output, Failure> {
        map { $0.isEmpty ? defaultValue : $0 }.eraseToAnyPublisher()
    }
}

extension Publisher where Output == Optional<String> {
    func filterOutEmpty() -> AnyPublisher<String, Failure> {
        self.compactMap { $0 }
            .filter { !$0.isEmpty }
            .eraseToAnyPublisher()
    }
}
