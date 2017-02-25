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
import RxSwiftExt

protocol SongDataSource: ReactiveTableViewDataSource {
    var category: Variable<Category?>! { get set }
    var songs: Variable<[Song]>! { get set }
    var cellType: SongConfigurableTableViewCell.Type! { get set }
}

class SongListDataSource: SongDataSource {
    weak var tableView: UITableView!
    var songs: Variable<[Song]>! = Variable([])
    var category: Variable<Category?>!
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
                if song == AudioController.instance.selectedSong.value {
                    self.tableView.selectRow(at: IndexPath(row: row, section: 0), animated: true, scrollPosition: .none)
                    cell.isSelected = true
                }
            }
            .addDisposableTo(disposeBag)
        
        songs.asObservable()
            .bindTo(AudioController.instance.songs)
            .addDisposableTo(disposeBag)
        
        tableView.rx
            .modelSelected(Song.self)
            .subscribeOn(ConcurrentDispatchQueueScheduler.init(qos: .userInteractive))
            .observeOn(MainScheduler.instance)
            .bindTo(AudioController.instance.selectedSong)
            .addDisposableTo(disposeBag)
        
        AudioController.instance.selectedSong
            .asObservable()
            .unwrap()
            .distinctUntilChanged { $0 == $1 }
            .map { [unowned self] song -> Array<Any>.Index? in
                return self.songs.value.index(where: { $0 == song })
            }
            .unwrap()
            .map { IndexPath(row: $0, section: 0) }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] index in
                if let selectedIndex = self.tableView.indexPathForSelectedRow {
                    self.tableView.cellForRow(at: selectedIndex)?.isSelected = false
                }
                self.tableView.cellForRow(at: index)?.isSelected = true
                self.tableView.selectRow(at: index, animated: true, scrollPosition: .none)
            })
            .addDisposableTo(disposeBag)
    }
    
    func getData() {
        category.asObservable()
            .subscribeOn(ConcurrentDispatchQueueScheduler.init(qos: .userInteractive))
            .unwrap()
            .map { $0.json }
            .unwrap()
            .flatMapLatest { Song.parse(json: $0) }
            .scan([]) { (acc: [Song], value: Song) in
                var array = acc
                array.append(value)
                return array
            }
            .observeOn(MainScheduler.instance)
            .bindTo(songs)
            .addDisposableTo(disposeBag)
    }
    
    
    deinit {
        print("Deinit-SongListDataSource")
    }
}
