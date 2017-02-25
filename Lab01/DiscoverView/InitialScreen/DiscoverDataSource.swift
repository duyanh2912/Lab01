//
//  DiscoverDataSource.swift
//  Lab01
//
//  Created by Duy Anh on 2/19/17.
//  Copyright © 2017 Duy Anh. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class DiscoverDataSource: ReactiveCollectionViewDataSource {
    weak var collectionView: UICollectionView!
    
    var categories: Variable<[Category?]> = Variable([])
    
    var binding: Variable<Bool> = Variable(false)
    var bind: Disposable?
    
    var disposeBag = DisposeBag()
    
    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
    }
    
    func configUnBind() {
        binding.asObservable()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] in
                if $0 {
                    guard self.bind == nil else { return }
                    self.bind = CategoryController.all
                        .asObservable()
                        .bindTo(self.categories)
                    self.bind?.addDisposableTo(self.disposeBag)
                } else {
                    self.bind?.dispose()
                    self.bind = nil
                    self.categories.value = []
                }
            })
            .addDisposableTo(disposeBag)
    }
    
    func bindDataSource() {
        categories.asObservable()
            .observeOn(MainScheduler.instance)
            .bindTo(collectionView
                .rx
                .items(cellIdentifier: CategoryCell.identifier, cellType: CategoryCell.self)
            ) {
                row, category, cell in
                cell.configWith(category: category)
            }
            .addDisposableTo(disposeBag)
    }
    
    func getData() {
        CategoryController.all
        .asObservable()
        .bindTo(self.categories)
        .addDisposableTo(disposeBag)
    }
}
