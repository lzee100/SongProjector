//
//  NSSortDescriptorExtensions.swift
//  SongProjector
//
//  Created by Leo van der Zee on 17/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation

extension NSSortDescriptor {
    
    static var titleAsc: NSSortDescriptor {
        return NSSortDescriptor(key: "title", ascending: true)
    }
    
    static var positionAsc: NSSortDescriptor {
        return NSSortDescriptor(key: "position", ascending: true)
    }
    
    static var positionDesc: NSSortDescriptor {
        return NSSortDescriptor(key: "position", ascending: false)
    }

}
