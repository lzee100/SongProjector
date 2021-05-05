//
//  DefaultPopUpController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 28/07/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import UIKit

class DefaultPopUpController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet var buttonsStackView: UIStackView!
    
    @IBOutlet var titleTopConstraint: NSLayoutConstraint!
    @IBOutlet var titleHeightConstraint: NSLayoutConstraint!
    @IBOutlet var contentTopConstraint: NSLayoutConstraint!
    @IBOutlet var contentHeightConstraint: NSLayoutConstraint!
    @IBOutlet var buttonStackViewHeightConstraint: NSLayoutConstraint!
    
    typealias PopUpAction = (() -> Void)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func setupWith(title: String?, content: String?, actions: [ActionButton]) {
        for view in buttonsStackView.arrangedSubviews {
            buttonsStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        titleLabel.text = title
        contentLabel.text = content
        
        titleTopConstraint.constant = title == nil ? 0 : 20
        titleHeightConstraint.constant = title == nil ? 0 : title!.height(withConstrainedWidth: titleLabel.bounds.width, font: titleLabel.font)
        contentHeightConstraint.constant = content == nil ? 0 : content!.height(withConstrainedWidth: contentLabel.bounds.width, font: contentLabel.font)
        buttonStackViewHeightConstraint.constant = actions.count == 0 ? 0 : 60
        actions.forEach({ buttonsStackView.addArrangedSubview($0) })
    }
    
}
