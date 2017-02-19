//
//  CGRect.swift
//  Hackathon
//
//  Created by Developer on 12/6/16.
//  Copyright © 2016 Developer. All rights reserved.
//

import Foundation
import SpriteKit

extension CGRect {
    public var center: CGPoint {
        return CGPoint(x: self.midX, y: self.midY)
    }
    
    public func move(point: CGPoint, to dest: CGPoint) -> CGRect {
        // The 2 points must be relative to the same origin
        
        var origin = self.origin
        
        let diff = dest.add(x: -point.x, y: -point.y)
        origin = origin.add(x: diff.x, y: diff.y)
        
        return CGRect(origin: origin, size: self.size)
    }
    
    public var aspectRatio: CGFloat {
        return self.size.aspectRatio
    }
}
