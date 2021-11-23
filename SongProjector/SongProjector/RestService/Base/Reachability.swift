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


class CheckInternet {
    
    typealias HasInternet = Bool
    
    static func checkInternet() async -> HasInternet {
        
        guard let url = URL(string: "https://www.google.nl") else { return false }
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 2
        let session = URLSession(configuration: config)
        
        do {
            let (_, response) = try await session.data(for: URLRequest(url: url), delegate: nil)
            if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                return (200..<300).contains(statusCode)
            } else {
                return false
            }
        } catch {
            return false
        }
        
    }
    
}
