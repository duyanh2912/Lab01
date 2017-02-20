//
//  SongListTableViewCell.swift
//  Lab01
//
//  Created by Duy Anh on 2/20/17.
//  Copyright © 2017 Duy Anh. All rights reserved.
//

import UIKit
import SDWebImage

class SongConfigurableTableViewCell: BaseTableViewCell, CellIdentifiable {
    func configWith(song: Song) {
        fatalError()
    }
}

class SongListTableViewCell: SongConfigurableTableViewCell {
    @IBOutlet weak var songImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        addButton.backgroundColor = .clear
        addButton.tintColor = .black
    }
    
    override func configWith(song: Song) {
        titleLabel.text = song.title
        artistLabel.text = song.artist
        
        songImageView.sd_setShowActivityIndicatorView(true)
        songImageView.sd_setIndicatorStyle(.gray)
        songImageView
            .sd_setImage(with: URL(string: song.imageLink),
                         placeholderImage: nil,
                         options: [.refreshCached])
            { [weak self] params in
                self?.songImageView.image = params.0
            }
    }
}
