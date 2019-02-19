//
//  IntroController1.swift
//  SongProjector
//
//  Created by Leo van der Zee on 16/02/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import UIKit

class IntroPageController1: PageController {

	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var ContentLabel: UILabel!
	
	@IBOutlet var titleLeftConstraint: NSLayoutConstraint!
	@IBOutlet var contentRightConstraint: NSLayoutConstraint!
	
	static let identifier = "IntroPageController1"
	
	override func viewDidLoad() {
        super.viewDidLoad()
		titleLabel.text = Text.Intro.IntroHalloTitle
		ContentLabel.text = Text.Intro.IntroHalloContent
		titleLabel.textColor = .white
		ContentLabel.textColor = .white
		view.backgroundColor = .black
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		Queues.main.asyncAfter(deadline: .now() + 1) {
			self.titleLeftConstraint.constant = 40
			UIView.animate(withDuration: 0.7, animations: {
				self.view.layoutIfNeeded()
			}) { _ in
				self.contentRightConstraint.constant = 40
				UIView.animate(withDuration: 0.7, animations: {
					self.view.layoutIfNeeded()
				})
			}
		}
	}
	
	
}
