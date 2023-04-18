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
    
    let image: Image
    let backgroundTransparancy: Double
    
    init(image: Image, backgroundTransparancy: CGFloat) {
        self.image = image
        self.backgroundTransparancy = backgroundTransparancy
    }
    
    func body(content: Content) -> some View {
        content.background(
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .opacity(backgroundTransparancy / 100)
                .clipped()
        )
    }
    
}

extension View {
    @ViewBuilder func setBackhgroundImage(isForExternalDisplay: Bool, displayModel: SheetDisplayViewModel?, editModel: WrappedStruct<EditSheetOrThemeViewModel>?) -> some View {
        
        let transparancy = displayModel?.sheetTheme.backgroundTransparancy ?? editModel?.item.backgroundTransparancyNumber ?? 100
       
        let image = displayModel?.sheetTheme.backgroundImage ?? editModel?.item.newSelectedThemeImage ?? editModel?.item.themeImage
        if isForExternalDisplay, let image = image {
            self.modifier(SheetBackgroundImageModifier(image: Image(uiImage: image), backgroundTransparancy: transparancy))
        } else if !isForExternalDisplay, let image = displayModel?.sheetTheme.thumbnailAsImage ?? editModel?.item.newSelectedThemeImageThumb?.image ?? editModel?.item.themeImageThumb?.image {
            self.modifier(SheetBackgroundImageModifier(image: image, backgroundTransparancy: transparancy))
        } else {
            self
        }
            
    }
}

