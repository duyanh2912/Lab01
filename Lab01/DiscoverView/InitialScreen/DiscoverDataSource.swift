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
    
    var disposeBag = DisposeBag()
    
    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
    }
    
    func bindDataSource() {
        CategoryController.all.asObservable()
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
        for (index, link) in LinkGenerator.links.enumerated() {
            LinkGenerator.json(from: link)
                .subscribe(onNext: { json in
                    CategoryController.all.value[index] = Category(json: json)
                    CategoryController.all.value[index]?.json = json
                })
                .addDisposableTo(disposeBag)
        }
    }
}
