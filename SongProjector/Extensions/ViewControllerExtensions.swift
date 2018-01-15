//
//  ViewControllerExtensions.swift
//  SongProjector
//
//  Created by Leo van der Zee on 13-01-18.
//  Copyright © 2018 iozee. All rights reserved.
//
import UIKit

extension UIViewController {
	func hideKeyboardWhenTappedAround() {
		let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
		tap.cancelsTouchesInView = false
		view.addGestureRecognizer(tap)
	}
	
	@objc func dismissKeyboard() {
		view.endEditing(true)
	}
}
