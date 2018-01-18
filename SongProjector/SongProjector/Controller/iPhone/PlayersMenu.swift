//
//  PlayersMenu.swift
//  SongProjector
//
//  Created by Leo van der Zee on 10-01-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import UIKit


//
//  LoadingIndicator.swift
//  SongProjector
//
//  Created by Leo van der Zee on 10-01-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import UIKit

let Menu = PlayerMenu()

class PlayerMenu {
	
	private var menu : PlayersMenu?

	private func createMenu(_ sender: NewOrEditIphoneControllerDelegate, playerMenu: PlayerMenu) -> PlayersMenu?{
		if let window = UIApplication.shared.keyWindow{
			let playersMenu = window.rootViewController?.storyboard?.instantiateViewController(withIdentifier: "PlayersMenu") as? PlayersMenu
			playersMenu?.sender = sender
			playersMenu?.menu = playerMenu
			playersMenu?.view?.frame = window.frame
			
			if let view = playersMenu?.view{
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
			return playersMenu
		}
		return nil
	}
	
	private func getMenu(_ sender: NewOrEditIphoneControllerDelegate) -> PlayersMenu?{
		if menu == nil{
			menu = createMenu(sender, playerMenu: self)
			let tab = UITapGestureRecognizer(target: self, action: #selector(self.dismissMenu(_:)))
			tab.numberOfTapsRequired = 1
			menu?.view.addGestureRecognizer(tab)
		}
		return menu
	}
	
	func showMenu(sender: NewOrEditIphoneControllerDelegate){
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

class PlayersMenu: UIViewController {

	@IBOutlet var button1: UIButton!
	@IBOutlet var button2: UIButton!
	@IBOutlet var button3: UIButton!
	
	private var blurEffectView: UIVisualEffectView?
	private var isSetupDone = false
	var sender: NewOrEditIphoneControllerDelegate?
	var menu: PlayerMenu?
	
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
			button3.backgroundColor = themeWhiteBlackBackground
			button1.tintColor = themeHighlighted
			button2.tintColor = themeHighlighted
			button3.tintColor = themeHighlighted

			button1.setTitle(Text.CustomSheetsMenu.sheetEmpty, for: .normal)
			button2.setTitle(Text.CustomSheetsMenu.sheetTitleImage, for: .normal)
			button3.setTitle(Text.CustomSheetsMenu.sheetSplit, for: .normal)

			
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
		let controller = storyboard?.instantiateViewController(withIdentifier: "NewOrEditIphoneController") as! NewOrEditIphoneController
		let sheet = CoreSheetEmptySheet.createEntity()
		controller.sheet = sheet
		let nav = UINavigationController(rootViewController: controller)
		controller.delegate = self.sender
		DispatchQueue.main.async {
			self.present(nav, animated: true)
		}
		menu?.hideMenu()
	}
	
	@IBAction func menuitem2(_ sender: UIButton) {
		let controller = storyboard?.instantiateViewController(withIdentifier: "NewOrEditIphoneController") as! NewOrEditIphoneController
		let sheet = CoreSheetTitleImage.createEntity()
		controller.sheet = sheet
		let nav = UINavigationController(rootViewController: controller)
		controller.delegate = self.sender
		DispatchQueue.main.async {
			self.present(nav, animated: true)
		}
		menu?.hideMenu()
	}
	
	@IBAction func menuitem3(_ sender: UIButton) {
		let controller = storyboard?.instantiateViewController(withIdentifier: "NewOrEditIphoneController") as! NewOrEditIphoneController
		let sheet = CoreSheetSplit.createEntity()
		controller.sheet = sheet
		let nav = UINavigationController(rootViewController: controller)
		controller.delegate = self.sender
		DispatchQueue.main.async {
			self.present(nav, animated: true)
		}
		menu?.hideMenu()
	}
	
	
}
