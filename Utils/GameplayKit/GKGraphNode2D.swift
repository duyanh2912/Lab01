//
//  GKGraphNode2D.swift
//  Hackathon
//
//  Created by Developer on 12/6/16.
//  Copyright © 2016 Developer. All rights reserved.
//
import GameplayKit
import SpriteKit
import Foundation

extension GKGraphNode2D {
    public func toCGPoint() -> CGPoint {
        return CGPoint(x: CGFloat(self.position.x), y: CGFloat(self.position.y))
    }
}
