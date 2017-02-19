//
//  Functional.swift
//  Day06
//
//  Created by Duy Anh on 2/2/17.
//  Copyright © 2017 Duy Anh. All rights reserved.
//

import Foundation

precedencegroup ChainFunction {
    associativity: left
}
precedencegroup CompositeFunction {
    associativity: left
    higherThan: ChainFunction
}


infix operator |> : ChainFunction

public func |> <T, U>(value: T, function: ((T) -> U)) -> U {
    return function(value)
}

infix operator >> : CompositeFunction
public func >> <T1, T2, T3> (left: @escaping (T1)->T2, right: @escaping (T2)->T3) -> (T1)->T3 {
    return { (t1: T1) -> T3 in return right(left(t1)) }
}
