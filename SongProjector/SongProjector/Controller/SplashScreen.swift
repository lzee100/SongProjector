//
//  SplashScreen.swift
//  SongViewer
//
//  Created by Leo van der Zee on 05-12-17.
//  Copyright © 2017 Topicus Onderwijs BV. All rights reserved.
//

import UIKit

class SplashScreen: ChurchBeamViewController {
	
	var isRegistered: Bool {
		return CoreUser.getEntities().first != nil
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		UserFetcher.addObserver(self)
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		if isRegistered {
			UserFetcher.fetch(force: true)
		} else {
			let intro = Storyboard.Intro.instantiateViewController(withIdentifier: IntroPageViewContainer.identifier) as! IntroPageViewContainer
			intro.setup(controllers: IntroPageViewContainer.introControllers())
			self.present(intro, animated: true, completion: nil)
		}
	}
	
	override func handleRequestFinish(result: AnyObject?) {
		if let _ = result as? [User] {
			performSegue(withIdentifier: "showMenu", sender: self)
		}
	}
	
	

}
