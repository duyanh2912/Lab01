//
//  UIImage.swift
//  Day03
//
//  Created by Duy Anh on 1/1/17.
//  Copyright © 2017 Duy Anh. All rights reserved.
//

import Foundation

extension UIImage {
    static public func thumbnail(of image: UIImage, scaledToFillSize size: CGSize) -> UIImage {
        let scale = max(size.width/image.size.width, size.height/image.size.height)
        let width = image.size.width * scale
        let height = image.size.height * scale
        let imageRect = CGRect(x: (size.width - width) / 2,
                               y: (size.height - height) / 2,
                               width: width,
                               height: height)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        image.draw(in: imageRect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
