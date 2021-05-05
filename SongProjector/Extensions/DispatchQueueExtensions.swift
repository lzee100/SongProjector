//
//  DispatchQueueExtensions.swift
//  SongProjector
//
//  Created by Leo van der Zee on 30/05/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import Foundation

extension DispatchQueue {
    static func onMain(completion:@escaping (() -> Void)) {
        DispatchQueue.main.async(execute: completion)
    }
}
