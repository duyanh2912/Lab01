//
//  Status.swift
//  Lab01
//
//  Created by Duy Anh on 2/23/17.
//  Copyright © 2017 Duy Anh. All rights reserved.
//

import Foundation
import RxSwift
import ReachabilitySwift
import MaterialControls

struct Status {
    static var reachable: Variable<Bool> = Variable(true)
    static var reachability = Reachability()
    
    static var snackBar = MDSnackbar(text: "Can't connect to internet", actionTitle: nil, duration: 0)
    
    static func startReachability() {
        reachability?.whenReachable = { _ in
            Status.reachable.value = true
        }
        reachability?.whenUnreachable = { _ in
            Status.reachable.value = false
        }
        try! reachability?.startNotifier()
    }
}
