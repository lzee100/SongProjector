//
//  CheckLineShape.swift
//  SongProjector
//
//  Created by Leo van der Zee on 17/04/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import SwiftUI

struct CheckLineShape: Shape {
    
    func path(in rect: CGRect) -> Path {
        let start = CGPoint(x: rect.size.width * 0.1, y: rect.size.height * 0.5)
        let mid = CGPoint(x: rect.size.width * 0.4, y: rect.size.height * 0.8)
        let end = CGPoint(x: rect.size.width * 0.9, y: rect.size.height * 0.2)
        
        
        var path = Path()
        path.move(to: start)
        path.addLine(to: mid)
        path.addLine(to: end)
        return path
    }
    
}
