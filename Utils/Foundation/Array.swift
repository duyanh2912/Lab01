//
//  Array.swift
//  Day06
//
//  Created by Duy Anh on 1/25/17.
//  Copyright © 2017 Duy Anh. All rights reserved.
//
import GameplayKit
import Foundation

extension Array {
    public var randomMember: Element {
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }
    
    public var randomizedArray: [Element] {
        return GKRandomSource.sharedRandom().arrayByShufflingObjects(in: self) as! [Element]
    }
    
}

// Becareful with this method
public func getValueFrom<T: Equatable>(_ closure: ()->(T), notIncludedIn array: [T]) -> T {
    var value = closure()
    while array.contains(value) {
        value = closure()
    }
    return value
}
