////
////  TitleLContentViewModel.swift
////  SongProjector
////
////  Created by Leo van der Zee on 03-06-18.
////  Copyright © 2018 iozee. All rights reserved.
////
//
//import Foundation
//import UIKit
//
//class TitleLContentViewModel: NewOrEditViewModel {
//
//	var sheetTitleContentTemp: SheetTitleContentTemp? {
//		return sheet as? SheetTitleContentTemp
//	}
//
//	private let cellName = LabelTextFieldCell.create(id: "cellName", description: Text.NewSheetTitleImage.descriptionTitle, placeholder: Text.NewTag.descriptionTitlePlaceholder)
//	private let cellContent = LabelTextView.create(id: "cellContent", description: Text.NewSheetTitleImage.descriptionContent, placeholder: Text.NewSheetTitleImage.placeholderContent)
//	private var cellTextLeft = LabelTextView.create(id: "cellTextLeft", description: Text.NewSheetTitleImage.descriptionTextLeft, placeholder: Text.NewSheetTitleImage.descriptionTextLeft)
//	private var cellTextRight = LabelTextView.create(id: "cellTextRight", description: Text.NewSheetTitleImage.descriptionTextRight, placeholder: Text.NewSheetTitleImage.descriptionTextRight)
//	private var  cellAsTag = LabelPickerCell()
//	private var  cellPhotoPickerBackground = LabelPhotoPickerCell()
//	private var  cellBackgroundColor = LabelColorPickerCell.create(id: "cellBackgroundColor", description: Text.NewTag.descriptionBackgroundColor)
//	private var  cellHasEmptySheet = LabelDoubleSwitchCell.create(id: "cellHasEmptySheet", descriptionSwitchOne: Text.NewTag.descriptionHasEmptySheet, descriptionSwitchTwo: Text.NewTag.descriptionPositionEmptySheet)
//	private let cellAllHaveTitlle = LabelSwitchCell.create(id: "cellAllHaveTitle", description: Text.NewTag.descriptionAllTitle, initialValueIsOn: false)
//	private let cellBackgroundTransparency = LabelSliderCell.create(id: "cellBackgroundTransparency", description: Text.NewTag.descriptionBackgroundTransparency, initialValue: 100)
//	private let cellDisplayTime = LabelSwitchCell.create(id: "cellDisplayTime", description: Text.NewTag.descriptionDisplayTime)
//
//
//
//	enum CellTitle: String {
//		case fontFamily
//		case fontSize
//		case backgroundColor
//		case alignment
//		case borderSize
//		case textColor
//		case borderColor
//		case bold
//		case italic
//		case underlined
//
//		static let all = [fontFamily, fontSize, backgroundColor, alignment, borderSize, textColor, borderColor, bold, italic, underlined]
//
//
//		static func `for`(_ indexPath: IndexPath) -> CellTitle {
//			return all[indexPath.row]
//		}
//
//	}
//
//	override func registerCells() {
//		tableView.register(cell: "")
//	}
//
//	override func numberOfSections(in tableView: UITableView) -> Int {
//		return super.numberOfSections(in: tableView) + CellTitle.all.count
//	}
//
//	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//		return 0
//	}
//
//	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//		return UITableViewCell()
//	}
//
//	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//		return 10
//	}
//
//	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//		return CGFloat.leastNonzeroMagnitude
//	}
//
//	override func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
//		return CGFloat.leastNonzeroMagnitude
//	}
//
//	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//		return nil
//	}
//
//	override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
//		return .none
//	}
//
//	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//
//	}
//
//	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//	}
//
//
//
//}
