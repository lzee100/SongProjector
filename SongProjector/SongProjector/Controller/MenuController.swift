//
//  MenuController.swift
//  SongViewer
//
//  Created by Leo van der Zee on 05-12-17.
//  Copyright © 2017 Topicus Onderwijs BV. All rights reserved.
//

import UIKit

class MenuController: UITabBarController {
	
	// MARK: - Constants
	
	fileprivate struct Constants {
		static let MaxRootFeatures = 3
		static let roomForMore = 1
	}
	
	var splitController: UISplitViewController?
	
	// MARK: - Private Properties
	
	/// De huidig geselecteerde feature.
	private var selected : Feature?
	
	/// Alle features die momenteel actief zijn.
	private var features : [Feature] {
		return menuFeatures
	}
	
	/// De features momenteel actief als root in het menu.
	private var menuFeatures : [Feature] = []
	
	/// De features momenteel actief in het meermenu.
	private var moreFeatures : [Feature] {
		return moreController?.features.map{ $0.feature } ?? []
	}
	
	/// De controllers voor elke feature.
	private var controllers : [Feature: UIViewController] = [:]
	
	/// De controller voor het meermenu.
	private var moreController : MoreController? {
		
		return controller(.more) as? MoreController
		
	}
	

	override func viewDidLoad() {
		super.viewDidLoad()
		setup()
		NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: NotificationIdentifier.noContract), object: nil, queue: nil) { [weak self] (notification) in
			DispatchQueue.main.async {
				self?.dismiss()
			}
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		tabBar.tintColor = .barColor
	}
	
	
	
	override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
		return UIInterfaceOrientationMask.portrait
	}
	
	override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
		
		if let index = tabBar.items?.index(of: item) {
			selected = features[index]
		} else {
			selected = nil
		}
		
	}
	
	private func setup() {
		
		// Maak controllers
		let storyboard = UIStoryboard(name: "StoryboardiPad", bundle: nil)
		

		Feature.all.forEach{
			controllers[$0] = storyboard.instantiateViewController(withIdentifier: $0.identifier)
		}
		// remove more UIViewController, more will become split viewController
		controllers.removeValue(forKey: .more)
		
		splitController = UISplitViewController()
		
		let master = storyboard.instantiateViewController(withIdentifier: "Master")
		let navMaster = UINavigationController(rootViewController: master)
		
		splitController?.viewControllers = [navMaster]
		
		controllers[.more] = splitViewController
		update()
		
	}
	
	private func update() {
		
		self.menuFeatures = Feature.all
		
		var menuFeatures = self.menuFeatures
		var moreFeatures = menuFeatures
		
		// remove meer from menu
		let moreIndex = menuFeatures.index(of: .more) ?? 0
		menuFeatures.remove(at: moreIndex)
		
		// get tabbar menu items
		let maxFeatures : Int = Constants.MaxRootFeatures
		
		if menuFeatures.count > maxFeatures {
			let removeLastNumber = (menuFeatures.count - maxFeatures)
			menuFeatures.removeLast(removeLastNumber)
			menuFeatures.append(.more)
		} else {
			moreFeatures = []
		}
		
		// get meer menu items
		if !moreFeatures.isEmpty {
			moreFeatures.removeFirst(maxFeatures)
			let index = moreFeatures.index(of: .more) as! Int
			moreFeatures.remove(at: index)
			print(index)
		}
		
		
		// build viewcontrollers for tabbar menu
		menuFeatures.removeLast()
		viewControllers = menuFeatures.map {
			UINavigationController(rootViewController: controller($0)!)
		}
		
		// build viewcontrollers for Meer TableViewController
		if let navMaster = splitController?.viewControllers[0] as? UINavigationController, let master = navMaster.topViewController as? MoreController {
			master.features = moreFeatures.map{ ($0, controller($0)!) }
		}
		
		viewControllers?.append(splitController!)
		// set custom navigationbar color
		for viewController in viewControllers ?? [] {
			if let nav = viewController as? UINavigationController {
//				nav.navigationBar.barTintColor = .barColor
			}
		}
		

		
		menuFeatures.append(.more)
		tabBar.items?.enumerated().forEach {
			index, item in
			
			let feature = menuFeatures[index]
			
			let image = feature.image.selected
			let selectedImage = feature.image.selected
			
			item.title = feature.titel
			item.image = image
			item.selectedImage = selectedImage
			
		}
		
	}
	
	private func controller(_ feature: Feature) -> UIViewController? {
		
		return controllers[feature] != nil ? controllers[feature] : nil // else return optional features controller (not build yet)
		
	}
	
	private func dismiss() {
		dismiss(animated: true)
	}

}
