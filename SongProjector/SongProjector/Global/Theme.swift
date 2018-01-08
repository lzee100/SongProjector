//
//  Theme.swift
//  SongProjector
//
//  Created by Leo van der Zee on 08-01-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import Foundation
import UIKit

class Theme {
	
	static func setup(){
		let defaults = UserDefaults.standard
		if let isThemeLight = defaults.object(forKey: "theme") as? Bool {
			print(isThemeLight)
		}
		
		let navigationbar = UINavigationBar.appearance()
 		navigationbar.barTintColor = UIColor(hex: "9F4500")
		navigationbar.titleTextAttributes = [.foregroundColor : UIColor(hex: "FF8324") ?? .white]
		let barbuttons = UIBarButtonItem.appearance()
		barbuttons.tintColor = UIColor(hex: "FF8324")
		
		let tabbar = UITabBar.appearance()
		tabbar.barTintColor = UIColor(hex: "9F4500")
		tabbar.tintColor = UIColor(hex: "FF8324")

		UIApplication.shared.statusBarStyle = .lightContent
		
		let segment = UISegmentedControl.appearance()
		segment.tintColor = UIColor(hex: "FF8324")
		let tableView = UITableView.appearance()
		tableView.separatorColor = UIColor(hex: "9F4500")
		tableView.backgroundColor = .black
		let tableViewCell = UITableViewCell.appearance()
		tableViewCell.backgroundColor = .black
		let button = UIButton.appearance()
		button.setTitleColor(UIColor(hex: "FF8324"), for: .normal)
		
		let label = UILabel.appearance()
		label.textColor = .white
		
		let textView = UITextView.appearance()
		textView.backgroundColor = .black
		textView.textColor = .white
	}
}
