//
//  CGVector.swift
//  Hackathon
//
//  Created by Developer on 12/6/16.
//  Copyright © 2016 Developer. All rights reserved.
//

import Foundation
import SpriteKit

extension CGVector {
    public func scale(by factor: CGFloat) -> CGVector {
        let dx = self.dx * factor
        let dy = self.dy * factor
        return CGVector(dx: dx, dy: dy)
    }
    
    public func subtract(by vector: CGVector) -> CGVector {
        return CGVector(dx: self.dx - vector.dx, dy: self.dy - vector.dy)
    }
}
