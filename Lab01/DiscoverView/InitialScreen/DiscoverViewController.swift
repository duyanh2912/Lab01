//
//  ViewController.swift
//  Lab01
//
//  Created by Duy Anh on 2/19/17.
//  Copyright © 2017 Duy Anh. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Alamofire
import SwiftyJSON
import SlideMenuControllerSwift
import ReachabilitySwift
import MaterialControls

class DiscoverViewController: UIViewController, ImageTransitionAnimatable {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var leftBarButton: UIBarButtonItem!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var dataSource: ReactiveCollectionViewDataSource!
    var imageViewForTransition: UIImageView!
    var preCalculatedCellSize: CGSize?
    
    var snackBar = Status.snackBar
    
    static var instance: DiscoverViewController!
    let disposeBag = DisposeBag()
    let animator = ImageTransitionAnimator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configNavigation()
        configDataSource()
        configSelectingModel()
        
        Status.reachable
            .asObservable()
            .subscribe(onNext: { [unowned self] in
                if $0 {
                    self.snackBar.dismiss()
                    self.bottomConstraint.constant = 0
                    CategoryController.getCategories()
                } else {
                    self.snackBar.show()
                    self.bottomConstraint.constant = self.snackBar.height
                }
            })
            .addDisposableTo(disposeBag)
        
        AudioController.instance
            .isPlaying
            .asObservable()
            .subscribe(onNext: {
                if $0 {
                    self.collectionView.contentInset.bottom = 50
                }
            })
            .addDisposableTo(disposeBag)
    }
    
    func configNavigation() {
        DiscoverViewController.instance = self
        navigationController?.delegate = self
        navigationItem.leftBarButtonItem?.rx
            .tap
            .subscribe(onNext: { [weak self] _ in
                self?.slideMenuController()?.openLeft()
            })
            .addDisposableTo(disposeBag)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifier.CategoryToSongList {
            let vc = segue.destination as! SongListViewController
            let category = sender as! Category
            vc.category.value = category
            return
        }
    }
    
    func configSelectingModel() {
        collectionView.rx
            .modelSelected(Category.self)
            .subscribe(onNext: { [unowned self] category in
                self.performSegue(withIdentifier: SegueIdentifier.CategoryToSongList,
                                  sender: category)
            })
            .addDisposableTo(disposeBag)
    }
    
    func configDataSource() {
        CategoryCell.registerFor(collectionView: collectionView)
        dataSource = DiscoverDataSource(collectionView: collectionView)
        dataSource.config()
        collectionView.rx.setDelegate(self).addDisposableTo(disposeBag)
    }
}

extension DiscoverViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if (toVC is SongListViewController && fromVC is DiscoverViewController) || (fromVC is SongListViewController && toVC is DiscoverViewController) {
            return animator
        }
        return nil
    }
}
