//
//  SheetBackgroundImageModifier.swift
//  SongProjector
//
//  Created by Leo van der Zee on 12/04/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import SwiftUI

struct SheetBackgroundImageModifier: ViewModifier {
    
    let image: Image?
    let backgroundTransparancy: Double
    
    init(image: Image?, backgroundTransparancy: CGFloat) {
        self.image = image
        self.backgroundTransparancy = backgroundTransparancy
    }
    
    func body(content: Content) -> some View {
        if let image {
            content.background(
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .opacity(backgroundTransparancy)
                    .clipped()
            )
        } else {
            content
        }
    }
    
}
//
//extension View {
//    @ViewBuilder func setBackhgroundImage(isForExternalDisplay: Bool, displayModel: SheetDisplayViewModel?, sheetViewModel: SheetViewModel?) -> some View {
//
//        let transparancy = displayModel?.sheetTheme.backgroundTransparancy ?? editModel?.item.backgroundTransparancyNumber ?? 100
//
//        let image = displayModel?.sheetTheme.backgroundImage ?? editModel?.item.getThemeImage(thumb: !isForExternalDisplay)
//        if isForExternalDisplay, let image = image {
//            self.modifier(SheetBackgroundImageModifier(image: Image(uiImage: image), backgroundTransparancy: transparancy))
//        } else {
//            self
//        }
//
//    }
//}
//
