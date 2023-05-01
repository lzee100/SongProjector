//
//  RoundedCornerShape.swift
//  SongProjector
//
//  Created by Leo van der Zee on 25/04/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import SwiftUI

struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
