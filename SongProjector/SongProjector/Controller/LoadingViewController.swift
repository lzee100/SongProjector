//
//  LoadingViewController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 10-01-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import UIKit
//import Machete

class LoadingViewController : UIViewController{
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var message: UILabel!
	@IBOutlet weak var messageTitle: UILabel!
	@IBOutlet weak var messageView: UIView!{
		didSet{
			messageView.layer.cornerRadius = 10.0
			messageView.layer.shadowOffset = CGSize(width: 0,height: 2.0)
			messageView.layer.shadowRadius = 5.0
			messageView.layer.shadowOpacity = 0.7
			messageView.layer.shadowColor = UIColor.gray.cgColor
		}
	}
	
	func showMessage(_ seconds : Double, withBlurEffect: Bool = false){
		let afterTime = TimeInterval.seconds(seconds)
		
		if withBlurEffect {
			let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
			let blurEffectView = UIVisualEffectView(effect: blurEffect)
			blurEffectView.frame = view.bounds
			blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
			messageView.addSubview(blurEffectView)
		}
		
		messageView.alpha = 0
		messageView.isHidden = false
		UIView.animate(withDuration: 0.2, animations: {
			self.messageView.alpha = 1
		})
		
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + afterTime) {
			UIView.animate(withDuration: 0.5, animations: {
				self.messageView.alpha = 0
			}, completion: { (finished) in
				self.messageView.isHidden = true
				if self.activityIndicator.isHidden == true{
					self.view.isHidden = true
				}
			})
		}
	}
}

