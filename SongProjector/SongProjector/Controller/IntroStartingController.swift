//
//  IntroStartingController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 09/03/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import UIKit

class IntroStartingController: PageController {

	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var contentLabel: UILabel!
	@IBOutlet var newUserButton: UIButton!
	@IBOutlet var inviteCodeButton: UIButton!
	
	override func viewDidLoad() {
        super.viewDidLoad()
    }
	
	static let identifier = "IntroStartingController"

	

}
