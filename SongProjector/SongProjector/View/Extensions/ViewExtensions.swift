//
//  ViewExtensions.swift
//  SongProjector
//
//  Created by Leo van der Zee on 22-12-17.
//  Copyright © 2017 iozee. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

extension View {
    // This function changes our View to UIView, then calls another function
    // to convert the newly-made UIView to a UIImage.
    public func asUIImage() -> UIImage {
        let controller = UIHostingController(rootView: self)
        
        controller.view.frame = CGRect(x: 0, y: CGFloat(Int.max), width: 1, height: 1)
        UIApplication.shared.windows.first!.rootViewController?.view.addSubview(controller.view)
        
        let size = controller.sizeThatFits(in: UIScreen.main.bounds.size)
        controller.view.bounds = CGRect(origin: .zero, size: size)
        controller.view.sizeToFit()
        
        // here is the call to the function that converts UIView to UIImage: `.asUIImage()`
        let image = controller.view.asUIImage()
        controller.view.removeFromSuperview()
        return image
    }
    
    func setBackgroundImage(isForExternalDisplay: Bool, editModel: WrappedStruct<EditSheetOrThemeViewModel>) -> some View {
        self.modifier(SheetBackgroundImageModifier(
            image: editModel.item.getThemeImage(thumb: !isForExternalDisplay)?.image,
            backgroundTransparancy: editModel.item.backgroundTransparancyNumber)
        )
    }
    
    func setBackgroundImage(isForExternalDisplay: Bool, theme: ThemeCodable?) -> some View {
        self.modifier(SheetBackgroundImageModifier(
            image: isForExternalDisplay ? theme?.uiImage?.image : theme?.uiImageThumb?.image,
            backgroundTransparancy: theme?.backgroundTransparancy ?? 100)
        )
    }

    
}

extension UIView {
    // This is the function to convert UIView to UIImage
    public func asUIImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
