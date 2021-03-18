//
//  AppTheme.swift
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
		return true
	}
}

var themeWhiteBlackBackground: UIColor {
	return isThemeLight ? .whiteColor : .blackColor
}

var themeHighlighted: UIColor {
    return .orange
}

var themeMainColor: UIColor {
	return UIColor(hex: "FF8324") ?? .primary
}

class AppTheme {
	
	static func setup(){
		
		
		let navigationbar = UINavigationBar.appearance()
        navigationbar.barTintColor = .blackColor
		navigationbar.isTranslucent = false
		navigationbar.titleTextAttributes = [.foregroundColor : UIColor(hex: "FF8324") ?? .whiteColor]
		let barbuttons = UIBarButtonItem.appearance()
		barbuttons.tintColor = UIColor(hex: "FF8324")
		
		let tabbar = UITabBar.appearance()
		tabbar.barTintColor = .blackColor
		tabbar.isTranslucent = false
		tabbar.tintColor = UIColor(hex: "FF8324")

		
		let segment = UISegmentedControl.appearance()
		segment.tintColor = UIColor(hex: "FF8324")
		segment.backgroundColor = .blackColor
		
		let tableView = UITableView.appearance()
		tableView.backgroundColor = .blackColor
		
		let collectionView = UICollectionView.appearance()
		collectionView.backgroundColor = .blackColor
		let collectionCell = UICollectionViewCell.appearance()
		collectionCell.backgroundColor = .blackColor
		collectionCell.tintColor = UIColor(hex: "FF8324")
		
		let textField = UITextField.appearance()
		textField.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.15)
		textField.textColor = .whiteColor
		
		let picker = UIPickerView.appearance()
		picker.backgroundColor = .blackColor
		picker.tintColor = .whiteColor

		let searchBar = UISearchBar.appearance()
		searchBar.backgroundColor = .blackColor
		searchBar.searchBarStyle = .minimal

		let tableViewCell = UITableViewCell.appearance()
		tableViewCell.backgroundColor = .blackColor

		let button = UIButton.appearance(whenContainedInInstancesOf: [UITableViewCell.self, UISearchBar.self])
		button.setTitleColor(UIColor(hex: "FF8324"), for: .normal)

//		let mySwitch = UISwitch.appearance()
//		mySwitch.tintColor = UIColor(hex: "FF8324")
//		mySwitch.onTintColor = UIColor(hex: "FF8324")
//		mySwitch.backgroundColor = .black

		let label = UILabel.appearance(whenContainedInInstancesOf: [UITableViewCell.self])
		label.textColor = .whiteColor

		let cellLabel = UILabel.appearance(whenContainedInInstancesOf: [UITableViewCell.self, BasicCell.self, AddButtonCell.self, NewSongSheetCell.self, LabelSwitchCell.self, LabelColorPickerNewCell.self, LabelNumberCell.self, LabelPickerCell.self, LabelTextFieldCell.self, LabelPhotoPickerCell.self, LabelDoubleSwitchCell.self])
		cellLabel.textColor = .whiteColor

	}
}
