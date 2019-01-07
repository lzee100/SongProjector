//
//  Theme.swift
//  SongProjector
//
//  Created by Leo van der Zee on 08-01-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import Foundation
import UIKit

var isThemeLight: Bool {
	let defaults = UserDefaults.standard
	if let isThemeLight = defaults.object(forKey: "theme") as? Bool {
		return isThemeLight
	} else {
		return false
	}
}

var themeWhiteBlackTextColor: UIColor {
	return isThemeLight ? .black : .white
}


var themeWhiteBlackBackground: UIColor {
	return isThemeLight ? .white : .black
}

var themeHighlighted: UIColor {
	return isThemeLight ? .primary : UIColor(hex: "FF8324") ?? .primary
}

var themeMainColor: UIColor {
	return UIColor(hex: "FF8324") ?? .primary
}

class AppTheme {
	
	static func setup(){
		
		
		let navigationbar = UINavigationBar.appearance()
 		navigationbar.barTintColor = .black
		navigationbar.isTranslucent = false
		navigationbar.titleTextAttributes = [.foregroundColor : UIColor(hex: "FF8324") ?? .white]
		let barbuttons = UIBarButtonItem.appearance()
		barbuttons.tintColor = UIColor(hex: "FF8324")
		
		let tabbar = UITabBar.appearance()
		tabbar.barTintColor = .black
		tabbar.isTranslucent = false
		tabbar.tintColor = UIColor(hex: "FF8324")

		
		let segment = UISegmentedControl.appearance()
		segment.tintColor = UIColor(hex: "FF8324")
		segment.backgroundColor = .black
		
		let tableView = UITableView.appearance()
		tableView.backgroundColor = .black
		
		let collectionView = UICollectionView.appearance()
		collectionView.backgroundColor = .black
		let collectionCell = UICollectionViewCell.appearance()
		collectionCell.backgroundColor = .black
		collectionCell.tintColor = UIColor(hex: "FF8324")
		
		let textField = UITextField.appearance()
		textField.backgroundColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.15)
		textField.textColor = .white
		
		let picker = UIPickerView.appearance()
		picker.backgroundColor = .black
		picker.tintColor = .white

		let searchBar = UISearchBar.appearance()
		searchBar.backgroundColor = .black
		searchBar.searchBarStyle = .minimal

		let tableViewCell = UITableViewCell.appearance()
		tableViewCell.backgroundColor = .black

		let button = UIButton.appearance(whenContainedInInstancesOf: [UITableViewCell.self, UISearchBar.self])
		button.setTitleColor(UIColor(hex: "FF8324"), for: .normal)

		let mySwitch = UISwitch.appearance()
		mySwitch.tintColor = UIColor(hex: "FF8324")
		mySwitch.onTintColor = UIColor(hex: "FF8324")
		mySwitch.backgroundColor = .black

		let label = UILabel.appearance(whenContainedInInstancesOf: [UITableViewCell.self])
		label.textColor = .white

		let cellLabel = UILabel.appearance(whenContainedInInstancesOf: [UITableViewCell.self, BasicCell.self, AddButtonCell.self, NewSongSheetCell.self, LabelSwitchCell.self, LabelColorPickerCell.self, LabelNumberCell.self, LabelPickerCell.self, LabelTextFieldCell.self, LabelPhotoPickerCell.self, LabelDoubleSwitchCell.self])
		cellLabel.textColor = .white

	}
}
