//
//  LocalViewController.swift
//  Lab01
//
//  Created by Duy Anh on 2/20/17.
//  Copyright © 2017 Duy Anh. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class LocalViewController: UIViewController {
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        navigationItem.title = "Local"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "menu-discovery"), style: .plain, target: nil, action: nil)
        navigationItem.leftBarButtonItem?
            .rx
            .tap
            .bindNext { [unowned self] _ in
                self.slideMenuController()?.openLeft()
            }
            .addDisposableTo(disposeBag)
    }
}
