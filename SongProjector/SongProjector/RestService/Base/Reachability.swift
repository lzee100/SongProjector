//
//  Reachability.swift
//  SongProjector
//
//  Created by Leo van der Zee on 27/11/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import Foundation
import SystemConfiguration
import Network

let monitor = NWPathMonitor()

let Reachability = Rchability()

public class Rchability {
    
    var isReachable = true
    
    init() {
        monitor.start(queue: .global(qos: .background))
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                Queues.main.async {
                    self.isReachable = true
                }
            } else {
                Queues.main.async {
                    self.isReachable = false
                }
            }
            print(path.isExpensive)
        }
    }
}
