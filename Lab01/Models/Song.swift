//
//  Song.swift
//  Lab01
//
//  Created by Duy Anh on 2/19/17.
//  Copyright © 2017 Duy Anh. All rights reserved.
//

import Foundation
import SwiftyJSON

class Song {
    var name = ""
    var artist = ""
    
    init(name: String, artist: String) {
        self.name = name
        self.artist = artist
    }
    
    class func parse(json: JSON) -> [Song] {
        var songs = [Song]()
        let feed = json["feed"]
        let entries = feed["entry"].array!
        for entry in entries {
            let name = entry["title"]["label"].string!
            let artist = entry["im:artist"]["label"].string!
            let song = Song(name: name, artist: artist)
            songs.append(song)
        }
        return songs
    }
}
