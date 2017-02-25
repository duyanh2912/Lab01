//
//  ReactiveCollectionViewDataSource.swift
//  Lab01
//
//  Created by Duy Anh on 2/19/17.
//  Copyright © 2017 Duy Anh. All rights reserved.
//

import Foundation
import RxSwift

protocol ReactiveCollectionViewDataSource {
    var collectionView: UICollectionView! { get set }
    
    func config()
    func bindDataSource()
    func configUnBind()
    func getData()
    
    var binding: Variable<Bool> { get set }
    var bind: Disposable? { get set }
}

extension ReactiveCollectionViewDataSource {
    func config() {
        bindDataSource()
        getData()
        configUnBind()
        binding.value = true
    }
}
