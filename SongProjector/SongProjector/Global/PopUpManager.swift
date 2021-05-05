//
//  PopUpManager.swift
//  SongProjector
//
//  Created by Leo van der Zee on 27/07/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import Foundation
import UIKit

struct PopUpTimeManager {
    
    private let lastShownAt = "lastShownAt"
    private let numberOfTimesDisplayed = "numberOfTimesDisplayed"
    private let dontShowAgain = "dontShowAgain"
    let key: Keys
    /// numberOfTimes: if 0, no limit
    let numberOfTimes: Int
    let showAgainAfterHours: Int
    
    func needsTrigger(butNotWhen: (() -> Bool)? = nil) -> Bool {
        
        guard let butNotWhen = butNotWhen, !butNotWhen() else {
            return false
        }
        
        let key = self.key.rawValue
        if UserDefaults.standard.bool(forKey: dontShowAgain + key) {
            return false
        }
        let lastShowAtInt = UserDefaults.standard.integer(forKey: lastShownAt + key)
        if lastShowAtInt != 0 {
            let lastShownAt = Date(timeIntervalSince1970: TimeInterval(lastShowAtInt))
            let isNeeded = Date().isAfter(lastShownAt.dateByAddingHours(showAgainAfterHours))
            let numberOfTimesDisplayed = UserDefaults.standard.integer(forKey: self.numberOfTimesDisplayed + key)
            
            if isNeeded, (numberOfTimes == 0 || numberOfTimesDisplayed < numberOfTimes) {
                UserDefaults.standard.setValue(Date().intValue, forKey: self.lastShownAt + key)
                UserDefaults.standard.setValue(numberOfTimesDisplayed + 1, forKey: self.lastShownAt + key)
                return isNeeded
            }
            return isNeeded
        }
        UserDefaults.standard.setValue(Date().intValue, forKey: lastShownAt + key)
        return true
    }
    
    static func setDontShowAgainFor(key: Keys) {
        UserDefaults.standard.setValue(true, forKey: "dontShowAgain" + key.rawValue)
    }
    
    static func resetAll() {
        let dontShowAgain = "dontShowAgain"
        let lastShownAt = "lastShownAt"
        PopUpTimeManager.Keys.allCases.map({ $0.rawValue }).forEach({
            UserDefaults.standard.removeObject(forKey: $0)
            UserDefaults.standard.removeObject(forKey: dontShowAgain + $0)
            UserDefaults.standard.removeObject(forKey: lastShownAt + $0)
        })
    }
}

extension PopUpTimeManager {
    
    enum Keys: String, CaseIterable {
        case createSongServiceSettings
        case deleteSongFromNewSongService
        case deleteSongFromSongs
        case shakeToGenerateSongService
    }
    
}


enum PopUpOrigin {
    case barButton(button: UIBarButtonItem)
    case view(source: UIView, sourceRect: CGRect)
}

class PopUpManager: NSObject {
    
    class func present(_ message: String, textColor: UIColor = .whiteColor, backgroundColor: UIColor = .whiteColor, origin: PopUpOrigin, viewController: UIViewController) {
        showWith(message, textColor: textColor, backgroundColor: backgroundColor, origin: origin, viewController: viewController)
    }
    
    private class func showWith(_ message: String, textColor: UIColor, backgroundColor: UIColor, origin: PopUpOrigin, viewController: UIViewController) {
        let font: UIFont = .normal
        let marginSmall: CGFloat = 8
        let marginBig: CGFloat = 15
        let marginsBig: CGFloat = marginBig * 2
        let marginsSmall: CGFloat = marginSmall * 2
        let lineHeight: CGFloat = 21
        let messageWidth = message.width(withConstrainedHeight: lineHeight, font: font)
        let tipMargin: CGFloat = 20
        
        // example:
        
        //        ----------totalFrame-----------
        //        |              8                |
        //        |     -------Label------        |
        //        | 15 | 15           15 |     15 |
        //        |     ------------------        |
        //        |              8                |
        //        ----------totalFrame-----------

        
        let totalRequiredWidth = messageWidth + marginsBig + marginsBig + marginsSmall + tipMargin
        
        let label: UILabel
        let totalFrame: CGRect
        
        // if one line fits
        if totalRequiredWidth < viewController.view.bounds.width {
            
            label = UILabel(frame: CGRect(x: marginBig, y: marginSmall, width: messageWidth + marginsSmall, height: lineHeight))
            label.text = message
            label.font = font
            label.textColor = textColor
            totalFrame = CGRect(x: 0, y: 0, width: messageWidth + marginsSmall + marginsBig, height: lineHeight + marginsSmall)
            
        }
        // if multi-line
        else {
            
            let maxWidth = viewController.view.bounds.width - marginsBig - marginsBig - marginsSmall - tipMargin
            let height = message.height(withConstrainedWidth: maxWidth, font: font)
            
            label = UILabel(frame: CGRect(x: marginBig, y: marginSmall, width: maxWidth, height: height))
            label.text = message
            label.font = font
            label.textColor = textColor
            label.numberOfLines = 0
            
            totalFrame = CGRect(x: 0, y: 0, width: viewController.view.bounds.width - marginsBig - tipMargin, height: height + marginsSmall)

        }
        
        let controller = UIViewController()
        controller.view.backgroundColor = backgroundColor
        controller.preferredContentSize = totalFrame.size

        controller.view.addSubview(label)
        
        controller.modalPresentationStyle = .popover
        controller.popoverPresentationController?.delegate = PopUpManagerReceiver
        
        switch origin {
        case .barButton(button: let barButton):
            controller.popoverPresentationController?.barButtonItem = barButton
        case .view(source: let sourceView, sourceRect: let sourceRect):
            controller.popoverPresentationController?.sourceRect = sourceRect
            controller.popoverPresentationController?.sourceView = sourceView
        }
        controller.popoverPresentationController?.backgroundColor = backgroundColor
        
        viewController.present(controller, animated: true, completion: nil)
    }
    
    class func present(_ vc: UIViewController, presentingViewController: UIViewController, origin: PopUpOrigin) {
        
        vc.modalPresentationStyle = .popover
        vc.popoverPresentationController?.delegate = PopUpManagerReceiver
        switch origin {
        case .barButton(button: let barButton):
            vc.popoverPresentationController?.barButtonItem = barButton
        case .view(source: let sourceView, sourceRect: let sourceRect):
            vc.popoverPresentationController?.sourceRect = sourceRect
            vc.popoverPresentationController?.sourceView = sourceView
        }
        presentingViewController.present(vc, animated: true, completion: nil)
    }
    
    
    private func postMetrics() {
        
    }
    
}

private let PopUpManagerReceiver = PpUpManagerReceiver()

class PpUpManagerReceiver: NSObject, UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
}

