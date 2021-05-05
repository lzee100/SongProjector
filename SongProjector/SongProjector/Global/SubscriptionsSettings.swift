//
//  SubscriptionsSettings.swift
//  SongProjector
//
//  Created by Leo van der Zee on 01/11/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import Foundation
import UIKit

struct SubscriptionsSettings {
    
    private static var contractsAreActive: Bool {
        switch AppConfiguration.mode {
        case .TestFlight, .AppStore: return false
        case .Debug: return true
        }
    }

    static var hasLimitedAccess: Bool {
        return false
        // check app delegate
        
        guard SubscriptionsSettings.contractsAreActive else {
            return false
        }
        if let user = VUser.first(moc: moc) {
            return !user.hasActiveBeamContract && !user.hasActiveSongContract
        } else {
            return false
        }
    }
    
    static func showSubscriptionsViewController(presentingViewController: UIViewController) {
        let vc = Storyboard.MainStoryboard.instantiateViewController(identifier: SubscriptionOffersContainerController.identifier)
        presentingViewController.present(vc, animated: true)

    }
    
}
