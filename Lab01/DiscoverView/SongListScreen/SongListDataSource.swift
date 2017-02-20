//
//  SongListDataSource.swift
//  Lab01
//
//  Created by Duy Anh on 2/20/17.
//  Copyright © 2017 Duy Anh. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol SongDataSource: ReactiveTableViewDataSource {
    var category: Category! { get set }
    var songs: Variable<[Song]>! { get set }
    var cellType: SongConfigurableTableViewCell.Type! { get set }
}

class SongListDataSource: SongDataSource {
    weak var tableView: UITableView!
    var songs: Variable<[Song]>! = Variable([])
    var category: Category!
    var cellType: SongConfigurableTableViewCell.Type!
    
    var disposeBag = DisposeBag()
    
    required init(tableView: UITableView) {
        self.tableView = tableView
    }
    
    func bindDataSource() {
        songs.asObservable()
            .bindTo(tableView
                .rx
                .items(cellIdentifier: cellType.identifier,
                       cellType: cellType))
            { row, song, cell in
                cell.configWith(song: song)
            }
            .addDisposableTo(disposeBag)
    }
    
    func getData() {
        guard let json = category.json else { return }
        Song.parse(json: json)
            .scan([Song]([])) { acc, song in
                var array = acc
                array.append(song)
                return array
            }
            .bindTo(songs)
            .addDisposableTo(disposeBag)
    }
}
