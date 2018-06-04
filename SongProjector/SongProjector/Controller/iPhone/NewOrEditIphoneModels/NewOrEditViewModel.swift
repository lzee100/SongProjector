////
////  NewOrEditViewModel.swift
////  SongProjector
////
////  Created by Leo van der Zee on 03-06-18.
////  Copyright © 2018 iozee. All rights reserved.
////
//
//import UIKit
//import Foundation
//
//
//
//class NewOrEditViewModel {
//
//
//
//	var cellGeneralArray: [CellGeneral]!
//	var cellTitleArray: [CellTitle]
//
//	var isTag = true
//	var tableView: UITableView
//	var tag: TagTemp
//	var sheet: SheetTemp?
//	var reloadDataAndScrollTo: ((UITableViewCell?) -> Void)
//
//	init(tag: TagTemp, sheet: SheetTemp?, tableView: UITableView, reloadDataAndScrollTo: @escaping ((UITableViewCell?) -> Void)) {
//		self.tag = tag
//		self.sheet = sheet
//		self.tableView = tableView
//		self.reloadDataAndScrollTo = reloadDataAndScrollTo
//		registerCells()
//	}
//
//	// MARK: UITableview functions
//
//	func numberOfSections(in tableView: UITableView) -> Int {
//		return 1
//	}
//
//	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//		return 0
//	}
//
//	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//		return UITableViewCell()
//	}
//
//	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//		return 10
//	}
//
//	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//		return CGFloat.leastNonzeroMagnitude
//	}
//
//	func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
//		return CGFloat.leastNonzeroMagnitude
//	}
//
//	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//		return nil
//	}
//
//	func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
//		return .none
//	}
//
//	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//
//	}
//
//	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//	}
//
//	func registerCells() {
//
//	}
//
//}
//
//enum Section: String {
//	case general
//	case title
//	case content
//	case image
//
//	static let all = [general, title, content, image]
//
//	static let titleContent = [general, title, content]
//	static let titleImage = [general, title, content, image]
//	static let sheetSplit = [general, title, content]
//	static let sheetEmpty = [general]
//	static let activity = [general, title, content]
//
//	static func `for`(_ section: Int, type: SheetType) -> Section {
//		switch type {
//		case .SheetTitleContent:
//			return titleContent[section]
//		case .SheetTitleImage:
//			return titleImage[section]
//		case .SheetSplit:
//			return sheetSplit[section]
//		case .SheetEmpty:
//			return sheetEmpty[section]
//		case .SheetActivities:
//			return activity[section]
//		}
//	}
//}
//
//enum CellNewOrEdit: String {
//	case name
//	case content
//	case asTag
//	case hasEmptySheet
//	case allHaveTitle
//	case backgroundColor
//	case backgroundImage
//	case backgroundTransparency
//	case displayTime
//
//	case fontFamily
//	case fontSize
//	case backgroundColor
//	case alignment
//	case borderSize
//	case textColor
//	case borderColor
//	case bold
//	case italic
//	case underlined
//
//	case textLeft
//	case textRight
//	case fontFamily
//	case fontSize
//	case alignment
//	case borderSize
//	case textColor
//	case borderColor
//	case bold
//	case italic
//	case underlined
//
//	case image
//	case hasBorder
//	case borderSize
//	case borderColor
//	case contentMode
//
//	static func `for`(_ indexPath: IndexPath, cellGenerals: [CellGeneral]) -> CellGeneral {
//		return cellGenerals[indexPath.row]
//	}
//
//	static func identifierFor(indexPath: IndexPath, cellArray: [CellGeneral]) -> String {
//		switch Section.all[indexPath.section] {
//		case .general:
//
//		default:
//			<#code#>
//		}
//
//		switch cellArray[indexPath.row] {
//		case .name: return "cellName"
//		case .content: return "cellContent"
//		case .asTag: return ""
//		case .hasEmptySheet: return "cellHasEmptySheet"
//		case .allHaveTitle: return "cellAllHaveTitle"
//		case .backgroundColor: return "cellBackgroundColor"
//		case .backgroundImage: return ""
//		case .backgroundTransparency: return "cellBackgroundTransparency"
//		case .displayTime: return "cellDisplayTime"
//		}
//	}
//}
