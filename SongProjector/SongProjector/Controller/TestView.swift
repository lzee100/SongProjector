//
//  TestView.swift
//  SongProjector
//
//  Created by Leo van der Zee on 17-06-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import UIKit

class TestView: UIViewController {

	@IBOutlet var sheetDisplayerView: UIView!
	var songServiceController: SongServiceContainerViewController!
	var songService: SongService!
	
	override func viewDidLoad() {
        super.viewDidLoad()

		guard let songServiceController = childViewControllers.first as? SongServiceContainerViewController else  {
			fatalError("Check storyboard for missing SongServiceContainerViewController")
		}

		self.songServiceController = songServiceController
		songServiceController.songService = songService
		
    }

	


}
