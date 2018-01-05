//
//  PlayersController.swift
//  SongViewer
//
//  Created by Leo van der Zee on 15-12-17.
//  Copyright © 2017 Topicus Onderwijs BV. All rights reserved.
//

import UIKit

class PlayersController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

	private func setup() {
		title = Text.Players.title
	}

}
