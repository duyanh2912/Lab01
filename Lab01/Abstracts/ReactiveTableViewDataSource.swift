//
//  ReactiveTableViewDataSource.swift
//  Lab01
//
//  Created by Duy Anh on 2/20/17.
//  Copyright © 2017 Duy Anh. All rights reserved.
//

import Foundation
import RxSwift

protocol ReactiveTableViewDataSource {
    var tableView: UITableView! { get set }
    var disposeBag: DisposeBag { get }
    
    func config()
    func bindDataSource()
    func getData()
    
    init(tableView: UITableView)
}

extension ReactiveTableViewDataSource {
    func config() {
        bindDataSource()
        getData()
    }
}
