//
//  LinkGenerator.swift
//  Lab01
//
//  Created by Duy Anh on 2/19/17.
//  Copyright © 2017 Duy Anh. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxAlamofire
import Alamofire
import SwiftyJSON

class LinkGenerator {
    static var prefix = "https://itunes.apple.com/us/rss/topsongs/limit=10/genre="
    static var suffix = "/explicit=true/json"
    static var disposeBag = DisposeBag()
    
    static var links: [String] {
        var array: [String] = []
        [2,3,4,5,6,7,9,10,11,12,14,15,16,17,18,19,20,21,22,24,34,50,51].forEach {
            array.append(prefix + $0.description + suffix)
        }
        return array
    }
    
    static var streams: Variable<[JSON]> {
        let variable = Variable<[JSON]>([])
        Observable<String>.create { o in
            links.forEach { link in
                o.onNext(link)
            }
            return Disposables.create()
            }
            .flatMap { link in
                return json(from: link)
            }
            .scan([JSON]([])) { acc, value in
                var array = acc
                array.append(value)
                return array
            }
            .subscribe(onNext: {
                variable.value = $0
            })
            .addDisposableTo(disposeBag)
        return variable
    }
    
    static func json(from link: URLConvertible) -> Observable<JSON> {
        return RxAlamofire.requestJSON(.get, link)
            .map { response, json in
                return JSON(json)
        }
    }
}
