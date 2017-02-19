//
//  UIImageView.swift
//  Hackathon
//
//  Created by Developer on 12/15/16.
//  Copyright © 2016 Developer. All rights reserved.
//
import UIKit
import Foundation

@IBDesignable
public class CustomUIImageView: UIImageView {
    
    // Blend Properties
    public var originalImage: UIImage? = nil
    
    @IBInspectable public var blendMode: Int32 = 0 {didSet{setNeedsLayout()}}
    @IBInspectable public var blendAlpha: CGFloat = 0 {didSet{setNeedsLayout()}}
    @IBInspectable public var blendColor: UIColor = .clear {didSet{setNeedsLayout()}}
    
    func blendedImage(_ image: UIImage) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(image.size, false, 0)
        
        let rect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        let ctx = UIGraphicsGetCurrentContext()!
        image.draw(at: .zero)
        
        ctx.translateBy(x: 0, y: rect.size.height)
        ctx.scaleBy(x: 1, y: -1)
        ctx.clip(to: rect, mask: image.cgImage!)
        
        blendColor.withAlphaComponent(blendAlpha).setFill()
        UIRectFillUsingBlendMode(rect, CGBlendMode.init(rawValue: blendMode) ?? .multiply)
        
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result!
    }
    
    //  Inset Properties
    @IBInspectable var insetAmount: CGFloat = 0 {didSet{setNeedsLayout()}}
    
    func inset(image: UIImage) -> UIImage {
        guard insetAmount != 0 else {
            return image
        }
        
        let size = self.bounds.size.add(dx: self.bounds.width * insetAmount / 100, dy: self.bounds.height * insetAmount / 100)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        let xRatio = size.width / image.size.width
        let yRatio = size.height / image.size.height
        
        let imageOrigin: CGPoint
        let imageSize: CGSize
        
        if xRatio < yRatio {
            imageSize = image.size.scale(by: xRatio)
            imageOrigin = CGPoint(x: 0, y: size.height / 2 - imageSize.height / 2)
        } else {
            imageSize = image.size.scale(by: yRatio)
            imageOrigin = CGPoint(x: size.width / 2 - imageSize.width / 2, y: 0)
        }
        
        image.draw(in: CGRect(origin: imageOrigin, size: imageSize))
        
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return result!
    }
    
    // Circle
    @IBInspectable public var cornerCircle: Bool = false {
        didSet{ if cornerCircle {
            configCornerCircle()
            }
        }
    }
    
    func configCornerCircle() {
        cornerRadius = (self.bounds.width + self.bounds.height) / 4
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        if originalImage == nil {
            originalImage = self.image?.copy() as! UIImage?
        }
        
        if cornerCircle {
            self.configCornerCircle()
        }
        
        var image: UIImage
        image = blendedImage(originalImage!)
        image = inset(image: image)
        
        self.image = image
    }
    
    public func changeImage(_ image: UIImage) {
        originalImage = image
    }
}

