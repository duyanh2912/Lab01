//
//  Category.swift
//  Lab01
//
//  Created by Duy Anh on 2/19/17.
//  Copyright © 2017 Duy Anh. All rights reserved.
//

import Foundation
import SwiftyJSON
import RxSwift

class Category {
    var name: String
    var image: UIImage
    var json: JSON?
    
    init(name: String, image: UIImage) {
        self.name = name
        self.image = image
    }
    
    convenience init(json: JSON) {
        let string = json["feed"]["title"]["label"].stringValue
        let name = string.replacingOccurrences(of: "iTunes Store: Top Songs in ", with: "")
        
        let number = json["feed"]["id"]["label"]
            .stringValue
            .components(separatedBy: "/")
            .filter { return $0.hasPrefix("genre=") }
            .first!
            .replacingOccurrences(of: "genre=", with: "")
        let image = UIImage(named: "genre-\(number)")
        self.init(name: name, image: image!)
    }
    
    //    lazy var songs: Observable<[Song]> = {
    //        return Observable<JSON?>.create { [unowned self] o in
    //            o.onNext(self.json)
    //            o.onCompleted()
    //            return Disposables.create()
    //            }
    //            .unwrap()
    //            .flatMapLatest { Song.parse(json: $0) }
    //            .scan([]) { (acc: [Song], value: Song) in
    //                var array = acc
    //                array.append(value)
    //                return array
    //        }
    //    }()
    
    
    deinit {
        print("deinit-Category")
    }
}

struct CategoryController {
    static var disposeBag = DisposeBag()
    
    static var all: Variable<[Category?]> = {
        var array: [Category?] = []
        for i in 1...LinkGenerator.links.count {
            array.append(nil)
        }
        return Variable(array)
    }()
    
    static func getCategories() {
        for (index, link) in LinkGenerator.links.enumerated() {
            guard all.value[index] == nil else { return }
            LinkGenerator.json(from: link)
                .subscribe(onNext: { json in
                    CategoryController.all.value[index] = Category(json: json)
                    CategoryController.all.value[index]?.json = json
                })
                .addDisposableTo(disposeBag)
        }
    }
}
