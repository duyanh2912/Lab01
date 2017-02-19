//
//  SKNode.swift
//  Hackathon
//
//  Created by Developer on 12/6/16.
//  Copyright © 2016 Developer. All rights reserved.
//
import SpriteKit
import Foundation

extension SKNode {
    public func configPhysicsMask(category: UInt32, collision: UInt32, contact: UInt32) {
        physicsBody?.categoryBitMask = category
        physicsBody?.collisionBitMask = collision
        physicsBody?.contactTestBitMask = contact
    }
}
