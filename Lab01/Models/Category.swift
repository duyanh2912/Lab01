//
//  Category.swift
//  Lab01
//
//  Created by Duy Anh on 2/19/17.
//  Copyright © 2017 Duy Anh. All rights reserved.
//

import Foundation
import SwiftyJSON

class Category {
    var name: String
    var image: UIImage
    
    init(name: String, image: UIImage) {
        self.name = name
        self.image = image
    }
    
    convenience init(json: JSON) {
        let string = json["feed"]["title"]["label"].stringValue
        let name = string.replacingOccurrences(of: "iTunes Store: Top Songs in ", with: "")
        
        let number = json["feed"]["id"]["label"]
            .stringValue
            .components(separatedBy: "/")
            .filter { return $0.hasPrefix("genre=") }
            .first!
            .replacingOccurrences(of: "genre=", with: "")
        let image = UIImage(named: "genre-\(number)")
        self.init(name: name, image: image!)
    }
}
