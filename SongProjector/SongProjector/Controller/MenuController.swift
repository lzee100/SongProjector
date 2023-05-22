//
//  MenuController.swift
//  SongViewer
//
//  Created by Leo van der Zee on 05-12-17.
//  Copyright © 2017 Topicus Onderwijs BV. All rights reserved.
//

import UIKit
import SwiftUI

class MenuController: UITabBarController {
	
	// MARK: - Constants
	
	fileprivate struct Constants {
		static let MaxRootFeatures = 4
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
        
		NotificationCenter.default.addObserver(forName: .secretChanged, object: nil, queue: nil) { [weak self] (notification) in
			DispatchQueue.main.async {
				self?.dismiss()
			}
		}
        NotificationCenter.default.addObserver(forName: .signedOut, object: nil, queue: nil) { [weak self] (notification) in
			DispatchQueue.main.async {
				self?.dismiss()
			}
		}
	}
	
    override var preferredStatusBarStyle: UIStatusBarStyle {
        switch selected {
        case .songService: return .lightContent
        default: return .darkContent
        }
    }
	
	override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
		return UIInterfaceOrientationMask.portrait
	}
	
	override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {

		if let index = tabBar.items?.firstIndex(of: item) {
			selected = features[index]
		} else {
			selected = nil
		}
        if case .dev = ChurchBeamConfiguration.environment {
            tabBar.barTintColor = UIColor(hex: "#891938")
            return
        }
        switch selected {
        case .songService: tabBar.barTintColor = UIColor(hex: "2E2C2C")
        default: tabBar.barTintColor = .grey2
        }

	}
	
	func activeController() -> UIViewController? {
		if let selected = selected {
			return controllers[selected] != nil ? controllers[selected] : nil // else return optional features controller (not build yet)
		}
		return nil
	}
    
	private func setup() {
        
        let appearance = tabBar.standardAppearance
        appearance.configureWithDefaultBackground()
        appearance.shadowImage = nil
        appearance.shadowColor = nil
        
        appearance.backgroundColor = .systemBackground
        
        setTabBarItemColors(appearance.stackedLayoutAppearance)
        setTabBarItemColors(appearance.inlineLayoutAppearance)
        setTabBarItemColors(appearance.compactInlineLayoutAppearance)

        tabBar.scrollEdgeAppearance = appearance
        tabBar.standardAppearance = appearance
        
		tabBar.barTintColor = UIColor(hex: "#2E2C2C")
        
        switch ChurchBeamConfiguration.environment {
        case .dev: tabBar.barTintColor = UIColor(hex: "#891938")
        case .production: tabBar.barTintColor = UIColor(hex: "2E2C2C")
        }

        tabBar.tintColor = .orange

        var tabFeatures: [Feature] = []
        var moreFeatures: [Feature] = []


		if let storyboard = storyboard {
			if let name = storyboard.value(forKey: "name") as? String, name == "StoryboardiPad" {
				UserDefaults.standard.setValue("ipad", forKey: "device")
			}
            
            var contr: [UIViewController] = []
            
            Feature.all.prefix(Constants.MaxRootFeatures).forEach({
                if $0 == .songService {
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        contr.append(Storyboard.Ipad.instantiateViewController(identifier: $0.identifier))
                    } else {
                        contr.append(Storyboard.MainStoryboard.instantiateViewController(identifier: $0.identifier))
                    }
                }
                if $0 == .songs {
                    let view = CollectionsViewUI(editingSection: nil, songServiceEditorModel: WrappedOptionalStruct<SongServiceEditorModel>(withItem: nil))
                    contr.append(UIHostingController(rootView: view))
                } else {
                    contr.append(Storyboard.MainStoryboard.instantiateViewController(identifier: $0.identifier))
                }
            })
            viewControllers = contr
                       
            
            for (index, controller) in (viewControllers ?? []).enumerated() {
                tabFeatures.append(Feature.all[index])
                if Feature.all[index] != .more {
                    controllers[Feature.all[index]] = controller
                }
            }

            Feature.all.filter({ $0.isActief == true }).forEach {
                if !tabFeatures.contains($0) {
                    moreFeatures.append($0)
                    controllers[$0] = $0.storyBoard.instantiateViewController(withIdentifier: $0.identifier)
                }
			}
            
            tabBar.items?.enumerated().forEach {
                index, item in
                
                let feature = tabFeatures[index]
                            
                item.title = feature.titleForDisplay
                item.image = feature.image.normal
                item.selectedImage = feature.image.selected
                
            }
            
            splitController = viewControllers?.last as? UISplitViewController

            if let navMaster = splitController?.viewControllers[0] as? UINavigationController, let master = navMaster.topViewController as? MoreController {
                master.features = moreFeatures.map{ ($0, controller($0)!) }
            }

            menuFeatures = tabFeatures
//			update()
		}
	}
	
	private func update() {
		
		self.menuFeatures = Feature.all.filter({ $0.isActief })
		
		var menuFeatures = self.menuFeatures
		var moreFeatures = menuFeatures
		
		// remove meer from menu
        let moreIndex = menuFeatures.firstIndex(of: .more) ?? 0
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
            if let index = moreFeatures.firstIndex(of: .more) {
				moreFeatures.remove(at: index)
			}
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
                nav.view.backgroundColor = .whiteColor
			}
		}
		

		
		menuFeatures.append(.more)
		tabBar.items?.enumerated().forEach {
			index, item in
			
			let feature = menuFeatures[index]
						
			item.title = feature.titleForDisplay
			item.image = feature.image.normal
			item.selectedImage = feature.image.selected
            
		}

    }
	
	private func controller(_ feature: Feature) -> UIViewController? {
		
		return controllers[feature] != nil ? controllers[feature] : nil // else return optional features controller (not build yet)
		
	}
	
	private func dismiss() {
		dismiss(animated: true)
	}
    
    private func setTabBarItemColors(_ itemAppearance: UITabBarItemAppearance) {
        itemAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.clear]
        itemAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.clear]
    }

}
