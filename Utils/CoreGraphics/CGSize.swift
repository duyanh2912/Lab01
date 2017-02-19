//
//  CGSize.swift
//  Hackathon
//
//  Created by Developer on 12/6/16.
//  Copyright © 2016 Developer. All rights reserved.
//

import Foundation
import SpriteKit

extension CGSize {
    public func scale(by factor: CGFloat) -> CGSize {
        let width = self.width * factor
        let height = self.height * factor
        return CGSize(width: width, height: height)
    }
    
    public func add(dx: CGFloat, dy: CGFloat) -> CGSize {
        let x = self.width + dx
        let y = self.height + dy
        return CGSize(width: x, height: y)
    }
    
    public var aspectRatio: CGFloat {
        return (self.width / self.height)
    }
}
