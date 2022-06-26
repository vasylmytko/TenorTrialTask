//
//  ErrorMessage.swift
//  TenorTrialTask
//
//  Created by Vasyl Mytko on 26.06.2022.
//

import Foundation

public struct ErrorMessage: LocalizedError, Equatable {
    private let message: String

    public init(_ message: String = "") {
        self.message = message
    }

    public init(_ error: Error) {
        self.message = error.localizedDescription
    }
}
