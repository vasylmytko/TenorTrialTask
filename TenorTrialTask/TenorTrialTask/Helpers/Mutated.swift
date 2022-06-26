//
//  Mutated.swift
//  TenorTrialTask
//
//  Created by Vasyl Mytko on 26.06.2022.
//

import Foundation

@discardableResult
public func mutated<T>(_ value: T, configure: (inout T) -> Void) -> T {
    var copy = value
    configure(&copy)
    return copy
}
