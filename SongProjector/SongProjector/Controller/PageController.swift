//
//  PageController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 15/02/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import UIKit

protocol PageControllerDelegate {
	var index: Int { get }
}

class PageController: ChurchBeamViewController, PageControllerDelegate {
	
	var index: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

    }
	

}
