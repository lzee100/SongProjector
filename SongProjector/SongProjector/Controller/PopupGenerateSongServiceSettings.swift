//
//  PopupGenerateSongServiceSettings.swift
//  SongProjector
//
//  Created by Leo van der Zee on 22/10/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import UIKit

class PopupGenerateSongServiceSettings: ChurchBeamViewController {
    
    static let identifier = "PopupGenerateSongServiceSettings"
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var dontShowAgainButton: ActionButton!
    @IBOutlet var showMeLater: ActionButton!
    
    @IBOutlet var titleLabelHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // automatische gegenereerde (zang)dienst
        titleLabel.font = .xxNormalBold
        descriptionTextView.font = .xNormal
        titleLabelHeightConstraint.constant = AppText.NewSongService.popupGenerateSongServiceTitle.height(withConstrainedWidth: titleLabel.bounds.width, font: .xxNormalBold)
        titleLabel.text = AppText.NewSongService.popupGenerateSongServiceTitle
        descriptionTextView.text = AppText.NewSongService.popupGenerateSongServiceDescription
        
        dontShowAgainButton.setTitle(AppText.NewSongService.dontShowAgain, for: UIControl.State())
        showMeLater.setTitle(AppText.NewSongService.showMeLater, for: UIControl.State())
        
        dontShowAgainButton.backgroundColor = .red1
        showMeLater.backgroundColor = .green1
        [dontShowAgainButton, showMeLater].forEach({
            $0?.setTitleColor(.white, for: UIControl.State())
            $0?.layer.cornerRadius = 5
        })
        
        dontShowAgainButton.add {
            PopUpTimeManager.setDontShowAgainFor(key: .createSongServiceSettings)
            self.dismiss(animated: true)
        }
        showMeLater.add {
            self.dismiss(animated: true)
        }
    }
    
}
