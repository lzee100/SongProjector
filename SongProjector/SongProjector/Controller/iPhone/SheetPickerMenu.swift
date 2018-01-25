//
//  SheetPickerMenu.swift
//  SongProjector
//
//  Created by Leo van der Zee on 10-01-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import UIKit

let SheetPickerMenu = SheetPickerMen()

class SheetPickerMen {
	
	private var menu : SheetPickMenuVC?
	
	private func createMenu(_ sender: SongsController, sheetPickersMen: SheetPickerMen) -> SheetPickMenuVC?{
		if let window = UIApplication.shared.keyWindow{
			let sheetPickersController = window.rootViewController?.storyboard?.instantiateViewController(withIdentifier: "SheetPickMenuVC") as? SheetPickMenuVC
			sheetPickersController?.sender = sender
			sheetPickersController?.menu = sheetPickersMen
			sheetPickersController?.view?.frame = window.frame
			
			if let view = sheetPickersController?.view{
				view.isHidden = true
				view.backgroundColor = .clear
				
				let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
				let blurEffectView = UIVisualEffectView(effect: blurEffect)
				blurEffectView.frame = view.bounds
				blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
				view.addSubview(blurEffectView)
				view.sendSubview(toBack: blurEffectView)
				window.addSubview(view)
			}
			return sheetPickersController
		}
		return nil
	}
	
	private func getMenu(_ sender: SongsController) -> SheetPickMenuVC?{
		if menu == nil{
			menu = createMenu(sender, sheetPickersMen: self)
			let tab = UITapGestureRecognizer(target: self, action: #selector(self.dismissMenu(_:)))
			tab.numberOfTapsRequired = 1
			menu?.view.addGestureRecognizer(tab)
		}
		return menu
	}
	
	func showMenu(sender: SongsController){
		DispatchQueue.main.async  {
			if let menu = self.getMenu(sender){
				menu.view.alpha = 0
				menu.view.isHidden = false
				UIView.animate(withDuration: TimeInterval.seconds(0.3), animations: {
					menu.view.alpha = 1
				})
			}
		}
	}
	
	func hideMenu(){
		DispatchQueue.main.async  {
			if let menu = self.menu{
				UIView.animate(withDuration: TimeInterval.seconds(0.3), animations: {
					menu.view.alpha = 0
				}, completion: { _ in
					menu.view.isHidden = true
				})
			}
		}
	}
	
	fileprivate init(){
	}
	
	@objc private func dismissMenu(_ getsture: UIGestureRecognizer) {
		hideMenu()
	}
}

class SheetPickMenuVC: UIViewController {
	
	@IBOutlet var button1: UIButton!
	@IBOutlet var button2: UIButton!
	
	private var blurEffectView: UIVisualEffectView?
	private var isSetupDone = false
	var sender: SongsController?
	var menu: SheetPickerMen?
	
	@IBOutlet var buttonsContainerView: UIView! {
		didSet{
			buttonsContainerView.backgroundColor = themeWhiteBlackBackground
			buttonsContainerView.layer.cornerRadius = 10.0
			buttonsContainerView.layer.shadowOffset = CGSize(width: 0,height: 2.0)
			buttonsContainerView.layer.shadowRadius = 5.0
			buttonsContainerView.layer.shadowOpacity = 0.7
			buttonsContainerView.layer.shadowColor = UIColor.gray.cgColor
			setup()
		}
	}
	
	func setup() {
		if blurEffectView == nil {
			
			button1.backgroundColor = themeWhiteBlackBackground
			button2.backgroundColor = themeWhiteBlackBackground
			
			button1.tintColor = themeHighlighted
			button2.tintColor = themeHighlighted
			
			button1.setTitle(Text.SheetPickerMenu.pickSong, for: .normal)
			button2.setTitle(Text.SheetPickerMenu.pickCustom, for: .normal)
			
			let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
			blurEffectView = UIVisualEffectView(effect: blurEffect)
			if let blurEffectView = blurEffectView {
				blurEffectView.frame = view.bounds
				blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
				let newV = UIView(frame: view.bounds)
				newV.backgroundColor = .red
				view.addSubview(blurEffectView)
				view.sendSubview(toBack: blurEffectView)
			}
		}
	}
	
	@IBAction func menuitem1(_ sender: UIButton) {
		let controller = storyboard?.instantiateViewController(withIdentifier: "NewSongIphoneController") as! NewSongIphoneController
		let nav = UINavigationController(rootViewController: controller)
		DispatchQueue.main.async {
			self.present(nav, animated: true)
		}
		menu?.hideMenu()
	}
	
	@IBAction func menuitem2(_ sender: UIButton) {
		let controller = storyboard?.instantiateViewController(withIdentifier: "CustomSheetsIphoneController") as! CustomSheetsIphoneController
		let nav = UINavigationController(rootViewController: controller)
		DispatchQueue.main.async {
			self.present(nav, animated: true, completion: {
				self.menu?.hideMenu()
			})
		}
	}
	
	
}
