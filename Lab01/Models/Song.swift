//
//  Song.swift
//  Lab01
//
//  Created by Duy Anh on 2/19/17.
//  Copyright © 2017 Duy Anh. All rights reserved.
//

import Foundation
import SwiftyJSON
import RxSwift
import RxCocoa

class Song {
    var title: String
    var artist: String
    var imageLink: String
    
    init(title: String, artist: String, imageLink: String) {
        self.title = title
        self.artist = artist
        self.imageLink = imageLink
    }
    
    class func parse(json: JSON) -> Observable<Song> {
        return Observable<Song>.create { observer in
            let feed = json["feed"]
            if let entries = feed["entry"].array {
            for entry in entries {
                let title = entry["title"]["label"].stringValue
                let artist = entry["im:artist"]["label"].stringValue
                let imageLink = entry["im:image"][2]["label"].stringValue
                
                let song = Song(title: title, artist: artist, imageLink: imageLink)
                observer.onNext(song)
                print("shit")
            }
                observer.onCompleted()
            } else {
                observer.onError(SongParseError.noArray)
            }
            return Disposables.create()
        }
    }
}

enum SongParseError: Error, CustomStringConvertible {
    case noArray
    var description: String {
        return "Fail at getting entry array"
    }
}
