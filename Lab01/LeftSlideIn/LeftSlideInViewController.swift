//
//  LeftSlideInViewController.swift
//  Lab01
//
//  Created by Duy Anh on 2/19/17.
//  Copyright © 2017 Duy Anh. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class LeftSlideInViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var selectedIndex = 0
    var menus = Variable<[String]>(["Discover", "Local"])
    var viewControllers: [UIViewController] = []
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        menus.asObservable()
            .bindTo(tableView.rx
                .items(cellIdentifier: "Cell"))
            { row, menu, cell in
                cell.textLabel?.text = menu
            }
            .addDisposableTo(disposeBag)
        
        tableView.rx
            .itemSelected
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] in
                self.tableView.deselectRow(at: $0, animated: true)
                self.slideMenuController()?.closeLeft()
                
                if self.selectedIndex == $0.row {
                    MyNavigationController.instance.popToRootViewController(animated: true)
                    return
                }
                
                MyNavigationController.instance.viewControllers.removeAll()
                MyNavigationController.instance.viewControllers.append(self.viewControllers[$0.row])
                self.selectedIndex = $0.row
            })
            .addDisposableTo(disposeBag)
    }
}
