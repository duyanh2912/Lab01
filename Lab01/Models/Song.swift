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
import RxAlamofire
import SDWebImage

class Song: Equatable {
    var title: String
    var artist: String
    var imageLink: String
    var image: UIImage?
    
    init(title: String, artist: String, imageLink: String) {
        self.title = title
        self.artist = artist
        self.imageLink = imageLink
    }
    
    static func ==(lhs: Song, rhs: Song) -> Bool {
        return lhs.artist == rhs.artist && lhs.title == rhs.title && lhs.imageLink == rhs.imageLink
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
                }
                observer.onCompleted()
            } else {
                observer.onError(SongParseError.noArray)
            }
            return Disposables.create()
        }
    }
    
    static func getLink(songId: Int) -> Observable<String> {
        let request = "http://api.mp3.zing.vn/api/mobile/song/getsonginfo?requestdata="+"{\"id\":\"\(songId)\"}".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        return RxAlamofire.requestJSON(.get, request)
            .map { return JSON($1) }
            .do(onError: { e in
                print(e)
            })
            .flatMapLatest { json in
                return Observable<String>.create { observer in
                    observer.onNext(json["link_download"]["128"].stringValue)
                    observer.onCompleted()
                    return Disposables.create()
                }
        }
    }
    
    // return id of the best matched song, 0 if not found
    static func getBestAlikeSong(to song: Song) -> Observable<Int> {
        return searchZing(song: song)
            .map { _, dict -> Int in
                guard !dict.isEmpty else { return 0 }
                var names = Array(dict.keys)
                var highestMatch = names[0]
                let compared = song.title + " " + song.artist
                
                names.forEach { name in
                    if compared.score(name) > compared.score(highestMatch) {
                        highestMatch = name
                    }
                }
                return dict[highestMatch]!
        }
    }
    
    private static func searchZing(song: Song, limit: Int = 5) -> Observable<(Song,[String:Int])> {
        return searchZing(name: song.title + song.artist, limit: 5)
            .map { dict in
                return (song, dict)
        }
    }
    
    private static func searchZing(name: String, limit: Int = 5) -> Observable<[String:Int]> {
        let dict = ["q":name,
                    "sort": "hot",
                    "start":"0",
                    "length": limit.description]
        let json = JSON(dict)
        let representation = json.rawString()!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        
        let link = "http://api.mp3.zing.vn/api/mobile/search/song?requestdata=" + representation
        
        return RxAlamofire.requestJSON(.get, link)
            .map { return JSON($1) }
            .do(onError: {
                print($0)
            })
            .flatMapLatest { json in
                return Observable<[String: Int]>.create { observer in
                    var array: [String:Int] = [:]
                    json["docs"].arrayValue
                        .forEach { entry in
                            guard entry["link_download"]["128"].stringValue != "" else { return }
                            array[entry["title"].stringValue+" "+entry["artist"].stringValue] = entry["song_id"].intValue
                    }
                    observer.onNext(array)
                    observer.onCompleted()
                    return Disposables.create()
                }
            }
            .asDriver(onErrorJustReturn: [:])
            .asObservable()
    }
}

enum SongParseError: Error, CustomStringConvertible {
    case noArray, noJSON, noResult
    var description: String {
        switch self {
        case .noJSON:
            return "JSON is nil"
        case .noArray:
            return "No array"
        case .noResult:
            return "No result"
        }
    }
}
