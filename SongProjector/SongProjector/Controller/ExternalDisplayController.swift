//
//  ExternalDisplayController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 31-12-17.
//  Copyright © 2017 iozee. All rights reserved.
//

import UIKit

class ExternalDisplayController: UIViewController {
	
	var secondScreenView: UIView?

	var externalLabel = UILabel()
    override func viewDidLoad() {
        super.viewDidLoad()

        setupScreen()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	@objc func setupScreen(){
		
		if UIScreen.screens.count > 1{
			
			//find the second screen
			let secondScreen = UIScreen.screens[1]
			
			//set up a window for the screen using the screens pixel dimensions
			externalDisplayWindow = UIWindow(frame: secondScreen.bounds)
			//windows require a root view controller
			let viewcontroller = UIViewController()
			externalDisplayWindow?.rootViewController = viewcontroller
			
			//tell the window which screen to use
			externalDisplayWindow?.screen = secondScreen
			
			//set the dimensions for the view for the external screen so it fills the screen
//			externalDisplayWindow = UIView(frame: externalDisplayWindow!.frame)
			
			//add the view to the second screens window
			externalDisplayWindow?.addSubview(secondScreenView!)
			
			//unhide the window
			externalDisplayWindow?.isHidden = false
			
			//customised the view
			secondScreenView!.backgroundColor = UIColor.white
			//configure the label
			externalLabel.textAlignment = NSTextAlignment.center
			externalLabel.font = UIFont(name: "Helvetica", size: 50.0)
			externalLabel.frame = secondScreenView!.bounds
			externalLabel.text = "Hello"
			
			//add the label to the view
			secondScreenView!.addSubview(externalLabel)
		}
	}
   

}




