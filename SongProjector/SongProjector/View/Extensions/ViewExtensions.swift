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
    
    func setBackgroundImage(isForExternalDisplay: Bool, sheetViewModel: SheetViewModel) -> some View {
        self.modifier(SheetBackgroundImageModifier(
            image: sheetViewModel.themeModel.getImage(thumb: !isForExternalDisplay)?.image,
            backgroundTransparancy: sheetViewModel.themeModel.theme.backgroundTransparancyNumber)
        )
    }
    
    func setBackgroundImage(image: UIImage?, backgroundTransparancy: CGFloat = 100) -> some View {
        self.modifier(SheetBackgroundImageModifier(
            image: image?.image,
            backgroundTransparancy: backgroundTransparancy)
        )
    }
    
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
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

extension View {
  // sync block on a DispatchQueue at specified deadline
  func perform(on queue: DispatchQueue = .main,
               at deadline: DispatchTime,
               action: @escaping () -> Void) -> some View {
    onAppear {
      queue.asyncAfter(deadline: deadline, execute: action)
    }
  }

  // sync block on a DispatchQueue after the specified interval
  func perform(on queue: DispatchQueue = .main,
               after interval: TimeInterval,
               action: @escaping () -> Void) -> some View {
    perform(on: queue, at: .now() + interval, action: action)
  }

  // async block on main thread after the specified interval
  func perform(after interval: TimeInterval,
               action: @escaping @Sendable () async -> Void) -> some View {
    task {
      try? await Task.sleep(nanoseconds: UInt64(interval * 1E9))
      await action()
    }
  }
}

