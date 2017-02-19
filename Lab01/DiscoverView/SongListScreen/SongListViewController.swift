//
//  SongListViewController.swift
//  Lab01
//
//  Created by Duy Anh on 2/19/17.
//  Copyright © 2017 Duy Anh. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture
import RxSwiftExt

class SongListViewController: UIViewController, ImageTransitionAnimatable {
    var category: Variable<Category?> = Variable(nil)
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var categoryContainer: UIView!
    
    var imageViewForTransition: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configTransition()
        bindCategory()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        categoryContainer.rx
            .gesture(.tap)
            .subscribe(onNext: { [unowned self] gesture in
                _ = self.navigationController?.popViewController(animated: true)
            })
            .addDisposableTo(disposeBag)
        
        navigationItem.leftBarButtonItem?.rx
            .tap
            .subscribe(onNext: { [weak self] _ in
                self?.slideMenuController()?.openLeft()
            })
            .addDisposableTo(disposeBag)
    }
    
    func configTransition() {
        imageViewForTransition = categoryImageView
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "menu-discovery"), style: .plain, target: nil, action: nil)
    }
    
    func bindCategory() {
        category.asObservable()
            .unwrap()
            .subscribe(onNext: { [unowned self] category in
                self.categoryNameLabel.text = category.name
                self.categoryImageView.image = category.image
            })
            .addDisposableTo(disposeBag)
    }
}
