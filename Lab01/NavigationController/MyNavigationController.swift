//
//  MyNavigationController.swift
//  Lab01
//
//  Created by Duy Anh on 2/19/17.
//  Copyright © 2017 Duy Anh. All rights reserved.
//

import UIKit
import Utils

class MyNavigationController: UINavigationController {

    override func viewDidLoad() {
        navigationBar.isOpaque = true
        navigationBar.isTranslucent = false
        
        navigationBar.barTintColor = UIColor.init("#4990E2")
        navigationBar.barStyle = .black
        navigationBar.tintColor = .white
        
        UIApplication.shared.statusBarStyle = .lightContent
    }
}
