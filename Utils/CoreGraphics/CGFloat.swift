//
//  CGFloat.swift
//  Hackathon
//
//  Created by Developer on 12/6/16.
//  Copyright © 2016 Developer. All rights reserved.
//

import Foundation
import SpriteKit

extension CGFloat {
    static public func angleHeadTowardDestination(current position: CGPoint, destination: CGPoint, spriteAngle: CGFloat) -> CGFloat{
        let dx = destination.x - position.x
        let dy = destination.y - position.y
        
        var angle = atan(dy / dx)
        angle = (dx < 0) ? (angle + CGFloat.pi) : angle
        return angle - spriteAngle
    }
    
    public var abs: CGFloat {
        if self > 0 {return self}
        return -self
    }
}
