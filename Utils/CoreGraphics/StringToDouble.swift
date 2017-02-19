//
//  StringToDouble.swift
//  E.Z Lean
//
//  Created by LuanNX on 2/5/17.
//  Copyright © 2017 E.Z Lean. All rights reserved.
//

import Foundation
extension String{
    public func parseDouble() -> Double{
        return NumberFormatter().number(from: self) as! Double
    }
}
