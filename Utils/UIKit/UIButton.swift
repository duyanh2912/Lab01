//
//  UIButton.swift
//  Hackathon
//
//  Created by Developer on 12/8/16.
//  Copyright © 2016 Developer. All rights reserved.
//
import UIKit
import Foundation

@IBDesignable
public class CustomUIButton: UIButton {
    @IBInspectable var cornerCircle: Bool = false {didSet{configCornerCircle()}}
    
    func configCornerCircle() {
        if cornerCircle {
            cornerRadius = (self.bounds.width + self.bounds.height) / 4
        }
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        configCornerCircle()
    }
}

@IBDesignable
class ButtonWithShadow: CustomUIButton {
    
    @IBInspectable var shadow: Bool = true {
        didSet {
            if shadow {
                updateLayerProperties()
            } else {
                layer.shadowOpacity = 0
            }
        }
    }
    
    func updateLayerProperties() {
        self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0
        self.layer.masksToBounds = false
    }
    
}
