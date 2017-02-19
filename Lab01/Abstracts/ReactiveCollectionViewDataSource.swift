//
//  ReactiveCollectionViewDataSource.swift
//  Lab01
//
//  Created by Duy Anh on 2/19/17.
//  Copyright © 2017 Duy Anh. All rights reserved.
//

import Foundation

protocol ReactiveCollectionViewDataSource {
    var collectionView: UICollectionView! { get set }
    
    func config()
    func bindDataSource()
    func getData()
}

extension ReactiveCollectionViewDataSource {
    func config() {
        bindDataSource()
        getData()
    }
}
