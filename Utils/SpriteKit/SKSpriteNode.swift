//
//  SKSpriteNode.swift
//  Hackathon
//
//  Created by Developer on 12/6/16.
//  Copyright © 2016 Developer. All rights reserved.
//
import SpriteKit
import Foundation

extension SKSpriteNode {
    public func configLightningMask(mask: UInt32) {
        self.lightingBitMask = mask
        self.shadowedBitMask = mask
        self.shadowCastBitMask = mask
    }
    
    public var height: CGFloat { return self.size.height }
    public var width: CGFloat { return self.size.width }
    
    public func headToward(_ destination: CGPoint, spriteAngle: CGFloat, speed: CGFloat) {
        let angle = CGFloat.angleHeadTowardDestination(current: self.position, destination: destination, spriteAngle: spriteAngle)
        self.zRotation = angle
        
        let vector = CGVector(dx: destination.x - self.position.x, dy: destination.y - self.position.y).scale(by: speed / destination.distance(to: self.position))
        self.physicsBody?.velocity = vector
        self.physicsBody?.angularVelocity = 0
    }
}
