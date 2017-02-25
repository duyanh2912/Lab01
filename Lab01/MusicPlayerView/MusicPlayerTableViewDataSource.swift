//
//  MusicPlayerTableViewDataSource.swift
//  Lab01
//
//  Created by Duy Anh on 2/24/17.
//  Copyright © 2017 Duy Anh. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class MusicPlayerTableViewDataSource: ReactiveTableViewDataSource {
    required init(tableView: UITableView) {
        self.tableView = tableView
    }
    
    typealias cellClass = SongListTableViewCell
    weak var tableView: UITableView!
    
    var selectedSong: Variable<Song?> = Variable(nil)
    var selectedIndexPath: IndexPath? = nil
    
    var songs: Variable<[Song]> = Variable([])
    var disposeBag: DisposeBag = DisposeBag()
    
    func bindDataSource() {
        songs.asObservable()
            .bindTo(tableView
                .rx
                .items(cellIdentifier: cellClass.identifier, cellType: cellClass.self))
            { [unowned self] row, song, cell in
                cell.configWith(song: song)
                if song == self.selectedSong.value {
                    cell.isSelected = true
                    self.selectedIndexPath = IndexPath(row: row, section: 0)
                } else {
                    cell.isSelected = false
                }
            }
            .addDisposableTo(disposeBag)
        
        tableView.rx
            .modelSelected(Song.self)
            .bindTo(AudioController.instance.selectedSong)
            .addDisposableTo(disposeBag)
        
        AudioController.instance.selectedSong
            .asObservable()
            .unwrap()
            .bindTo(selectedSong)
            .addDisposableTo(disposeBag)
        
        self.selectedSong
            .asObservable()
            .map { [unowned self] song in
                return self.songs.value.index(where: {$0==song})
            }
            .unwrap()
            .map { IndexPath(row: $0, section: 0) }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] in
                if let indexPath = self.selectedIndexPath {
                    self.tableView.cellForRow(at: indexPath)?.isSelected = false
                }
                self.tableView.cellForRow(at: $0)?.isSelected = true
                self.selectedIndexPath = $0
            })
            .addDisposableTo(disposeBag)
    }
    
    func getData() {
        AudioController.instance
            .songs
            .asObservable()
            .bindTo(songs)
            .addDisposableTo(disposeBag)
    }
}
