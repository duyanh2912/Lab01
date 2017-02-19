//
//  SKTextureAtlas.swift
//  Hackathon
//
//  Created by Developer on 12/6/16.
//  Copyright © 2016 Developer. All rights reserved.
//

import Foundation
import SpriteKit

extension SKTextureAtlas {
    public func toTextures() -> [SKTexture] {
        var textures = [SKTexture]()
        for name in self.textureNames.sorted() {
            textures.append(self.textureNamed(name))
        }
        return textures
    }
}
