//
//  NewSheetTitleImage.swift
//  SongProjector
//
//  Created by Leo van der Zee on 12-01-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import UIKit
import ChromaColorPicker

protocol NewSheetTitleImageDelegate {
	func didCreate(sheet: Sheet)
}

class NewSheetTitleImage: UIViewController, UITableViewDelegate, UITableViewDataSource, LabelTextFieldCellDelegate, LabelPickerCellDelegate, LabelDoubleSwitchDelegate, LabelNumerCellDelegate, LabelColorPickerCellDelegate, LabelSwitchCellDelegate, LabelPhotoPickerCellDelegate {
	
	@IBOutlet var cancel: UIBarButtonItem!
	@IBOutlet var save: UIBarButtonItem!
	@IBOutlet var previewView: UIView!
	@IBOutlet var tableView: UITableView!
	@IBOutlet var sheetContainerView: UIView!
	@IBOutlet var sheetContainerViewHeightConstraint: NSLayoutConstraint!
	@IBOutlet var previewViewRatioConstraint: NSLayoutConstraint!
	
	var sheetType: SheetType!
	
	// MARK: - Types
	
	enum Section: String {
		case general
		case title
		case content
		case image
		
		static let all = [general, title, content, image]
		
		static func `for`(_ section: Int) -> Section {
			return all[section]
		}
	}
	
	enum CellGeneral: String {
		case name
		case content
		case asTag
//		case emptySheet
//		case allHaveTitle
		case backgroundColor
		case backgroundImage
		
		static let all = [name, content, asTag, backgroundColor, backgroundImage]
		
		static func `for`(_ indexPath: IndexPath) -> CellGeneral {
			return all[indexPath.row]
		}
	}
	
	enum CellTitle: String {
		case fontFamily
		case fontSize
		case backgroundColor
		case alignment
		case borderSize
		case textColor
		case borderColor
		case bold
		case italic
		case underlined
		
		static let all = [fontFamily, fontSize, backgroundColor, alignment, borderSize, textColor, borderColor, bold, italic, underlined]
		
		static func `for`(_ indexPath: IndexPath) -> CellTitle {
			return all[indexPath.row]
		}
	}
	
	enum CellLyrics: String {
		case fontFamily
		case fontSize
		case alignment
		case borderSize
		case textColor
		case borderColor
		case bold
		case italic
		case underlined
		
		static let all = [fontFamily, fontSize, alignment, borderSize, textColor, borderColor, bold, italic, underlined]
		
		static func `for`(_ indexPath: IndexPath) -> CellLyrics {
			return all[indexPath.row]
		}
	}
	
	enum CellImage: String {
		case image
		case hasBorder
		case borderSize
		case borderColor
		case contentMode
		
		static let all = [image, hasBorder, borderSize, borderColor, contentMode]
		
		static func `for`(_ indexPath: IndexPath) -> CellImage {
			return all[indexPath.row]
		}
	}
	
	// MARK: - Properties
	// MARK: General Cells
	
	private let cellName = LabelTextFieldCell.create(id: "cellName", description: Text.NewSheetTitleImage.descriptionTitle, placeholder: Text.NewTag.descriptionTitlePlaceholder)
	private let cellContent = LabelTextFieldCell.create(id: "cellContent", description: Text.NewSheetTitleImage.descriptionContent, placeholder: Text.NewSheetTitleImage.placeholderContent)
	private var  cellAsTag = LabelPickerCell()
	private var  cellPhotoPickerBackground = LabelPhotoPickerCell()
	private var  cellBackgroundColor = LabelColorPickerCell.create(id: "cellBackgroundColor", description: Text.NewTag.descriptionBackgroundColor)
//	private var  cellHasEmptySheet = LabelDoubleSwitchCell.create(id: "cellHasEmptySheet", descriptionSwitchOne: Text.NewTag.descriptionHasEmptySheet, descriptionSwitchTwo: Text.NewTag.descriptionPositionEmptySheet)
//	private let cellAllHaveTitlle = LabelSwitchCell.create(id: "cellAllHaveTitle", description: Text.NewTag.descriptionAllTitle, initialValueIsOn: false)
	
	
	
	// MARK: Title Cells
	
	private var  cellTitleFontFamily = LabelPickerCell()
	private let cellTitleFontSize = LabelNumberCell.create(id: "cellTitleFontSize", description: Text.NewTag.fontSizeDescription, initialValue: 17)
	private let cellTitleAlignment = LabelPickerCell.create(id: "cellTitleFontAlignment", description: Text.NewTag.descriptionAlignment, initialValueName: Text.NewTag.alignLeft, pickerValues: [(Int64(0), Text.NewTag.alignLeft), (Int64(0), Text.NewTag.alignCenter), (Int64(0), Text.NewTag.alignRight)])
	private let cellTitleBorderSize = LabelNumberCell.create(id: "cellTitleBorderSize", description: Text.NewTag.borderSizeDescription, initialValue: 0, positive: false)
	private let cellTitleTextColor = LabelColorPickerCell.create(id: "cellTitleTextColor", description: Text.NewTag.textColor)
	private let cellTitleBackgroundColor = LabelColorPickerCell.create(id: "cellTitleBackgroundColor", description: Text.NewTag.descriptionTitleBackgroundColor)
	private let cellTitleBorderColor = LabelColorPickerCell.create(id: "cellTitleBorderColor", description: Text.NewTag.borderColor)
	private let cellTitleBold = LabelSwitchCell.create(id: "cellTitleBold", description: Text.NewTag.bold)
	private let cellTitleItalic = LabelSwitchCell.create(id: "cellTitleItalic", description: Text.NewTag.italic)
	private let cellTitleUnderLined = LabelSwitchCell.create(id: "cellTitleUnderlined", description: Text.NewTag.underlined)
	
	
	// MARK: Lyrics Cells
	
	private var  cellLyricsFontFamily = LabelPickerCell()
	private let cellLyricsFontSize = LabelNumberCell.create(id: "cellLyricsFontSize", description: Text.NewTag.fontSizeDescription, initialValue: 17)
	private let cellLyricslAlignment = LabelPickerCell.create(id: "cellLyricsFontAlignment", description: Text.NewTag.descriptionAlignment, initialValueName: "Left", pickerValues: [(Int64(0), Text.NewTag.alignLeft), (Int64(0), Text.NewTag.alignCenter), (Int64(0), Text.NewTag.alignRight)])
	private let cellLyricsBorderSize = LabelNumberCell.create(id: "cellLyricsBorderSize", description: Text.NewTag.borderSizeDescription, initialValue: 0, positive: false)
	private let cellLyricsTextColor = LabelColorPickerCell.create(id: "cellLyricsTextColor", description: Text.NewTag.textColor)
	private let cellLyricsBorderColor = LabelColorPickerCell.create(id: "cellLyricsBorderColor", description: Text.NewTag.borderColor)
	private let cellLyricsBold = LabelSwitchCell.create(id: "cellLyricsBold", description: Text.NewTag.bold)
	private let cellLyricsItalic = LabelSwitchCell.create(id: "cellLyricsItalic", description: Text.NewTag.italic)
	private let cellLyricsUnderLined = LabelSwitchCell.create(id: "cellLyricsUnderlined", description: Text.NewTag.underlined)
	
	private var  cellImagePicker = LabelPhotoPickerCell()
	private let cellImageHasBorder = LabelSwitchCell.create(id: "cellImageHasBorder", description: Text.NewSheetTitleImage.descriptionImageHasBorder)
	private let cellImageBorderSize = LabelNumberCell.create(id: "cellImageBorderSize", description: Text.NewSheetTitleImage.descriptionImageBorderSize, initialValue: 0)
	private let cellImageBorderColor = LabelColorPickerCell.create(id: "cellImageBorderColor", description: Text.NewSheetTitleImage.descriptionImageBorderColor)
	private var  cellImageContentMode = LabelPickerCell()
	
	var editExtistingSheet = false
	var tag: Tag!
	var sheet: SheetTitleImageEntity!
	var delegate: NewSheetTitleImageDelegate?
	private var isSetup = true
	private var titleAttributes: [NSAttributedStringKey : Any] = [:]
	private var lyricsAttributes: [NSAttributedStringKey: Any] = [:]
	private var externalDisplayRatioConstraint: NSLayoutConstraint?
	private var newSheetContainerViewHeightConstraint: NSLayoutConstraint?
	
	// MARK: - Functions
	
	// MARK: UIViewController functions
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setup()
	}
	
	
	
	// MARK: UITableview functions
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return Section.all.count
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch Section.for(section) {
		case .general:
			return CellGeneral.all.count
		case .title:
			return CellTitle.all.count
		case .content:
			return CellLyrics.all.count
		case .image:
			return CellImage.all.count
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch Section.for(indexPath.section) {
		case .general: return getGeneralCellFor(indexPath: indexPath)
		case .title: return getTitleCellFor(indexPath: indexPath)
		case .content: return getLyricsCellFor(indexPath: indexPath)
		case .image: return getImageCellFor(indexPath: indexPath)
		}
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		switch Section.for(indexPath.section) {
		case .general:
			switch CellGeneral.for(indexPath) {
			case .asTag : return cellAsTag.preferredHeight
			case .backgroundColor: return cellBackgroundColor.preferredHeight
			case .backgroundImage: return cellPhotoPickerBackground.preferredHeight
			default:
				return 60
			}
		case .title:
			switch CellTitle.for(indexPath) {
			case .fontFamily: return cellTitleFontFamily.preferredHeight
			case .fontSize: return cellTitleFontSize.preferredHeight
			case .alignment: return cellTitleAlignment.preferredHeight
			case .textColor: return cellTitleTextColor.preferredHeight
			case .backgroundColor: return cellTitleBackgroundColor.preferredHeight
			case .borderSize: return cellTitleBorderSize.preferredHeight
			case .borderColor: return cellTitleBorderColor.preferredHeight
			default:
				return 60
			}
		case .content:
			switch CellLyrics.for(indexPath) {
			case .fontFamily: return cellLyricsFontFamily.preferredHeight
			case .fontSize: return cellLyricsFontSize.preferredHeight
			case .alignment: return cellLyricslAlignment.preferredHeight
			case .textColor: return cellLyricsTextColor.preferredHeight
			case .borderSize: return cellLyricsBorderSize.preferredHeight
			case .borderColor: return cellLyricsBorderColor.preferredHeight
			default:
				return 60
			}
		case .image:
			switch CellImage.for(indexPath) {
			case .image: return cellImagePicker.preferredHeight
			case .borderColor: return cellImageBorderColor.preferredHeight
			case .contentMode: return cellImageContentMode.preferredHeight
			default:
				return 60
			}
		}
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 60
	}
	
	func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
		return 60
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let frame = CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 60)
		let view = HeaderView(frame: frame)
		switch Section.for(section) {
		case .general:
			view.descriptionLabel.text = Text.NewTag.sectionGeneral.uppercased()
		case .title:
			view.descriptionLabel.text = Text.NewTag.sectionTitle.uppercased()
		case .content:
			view.descriptionLabel.text = Text.NewTag.sectionLyrics.uppercased()
		case .image:
			view.descriptionLabel.text = Text.NewSheetTitleImage.title.uppercased()
		}
		return view
	}
	
	func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
		switch Section.for(indexPath.section) {
		case .general:
			switch CellGeneral.for(indexPath) {
			case .backgroundColor:
				return cellBackgroundColor.isActive ? .none : .delete
			case .asTag:
				return cellAsTag.isActive ? .none : .delete
			case .backgroundImage:
				return cellPhotoPickerBackground.isActive ? .none : cellPhotoPickerBackground.pickedImage != nil ? .delete : .none
			default:
				return .none
			}
		case .title:
			switch CellTitle.for(indexPath) {
			case .fontFamily:
				return cellTitleFontFamily.isActive ? .none: .delete
			case .backgroundColor:
				return cellTitleBackgroundColor.isActive ? .none : .delete
			case .textColor:
				return cellTitleTextColor.isActive ? .none : .delete
			case .borderColor:
				return cellTitleBorderColor.isActive ? .none : .delete
			default:
				return .none
			}
		case .content:
			switch CellLyrics.for(indexPath) {
			case .fontFamily:
				return cellLyricsFontFamily.isActive ? .none : .delete
			case .textColor:
				return cellLyricsTextColor.isActive ? .none : .delete
			case .borderColor:
				return cellLyricsBorderColor.isActive ? .none : .delete
			default:
				return .none
			}
		case .image:
			switch CellImage.for(indexPath) {
			case .image:
				return cellImagePicker.isActive ? .none : .delete
			case .borderColor:
				return cellImageBorderColor.isActive ? .none : .delete
			case .contentMode:
				return cellImageContentMode.isActive ? .none : .delete
			default:
				return .none
			}
		}
	}
	
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			switch Section.for(indexPath.section) {
			case .general:
				switch CellGeneral.for(indexPath) {
				case .asTag:
					cellAsTag.setValue(value: nil, id: nil)
				case .backgroundColor:
					cellBackgroundColor.setColor(color: nil)
				case .backgroundImage:
					cellPhotoPickerBackground.setImage(image: nil)
					if let path = tag.imagePath {
						let _ = deleteImageFor(path: path)
					}
				default:
					break
				}
			case .title:
				switch CellTitle.for(indexPath) {
				case .fontFamily:
					cellTitleFontFamily.setValue(value: nil, id: nil)
				case .backgroundColor:
					cellTitleBackgroundColor.setColor(color: nil)
				case .textColor:
					cellTitleTextColor.setColor(color: nil)
				case .borderColor:
					cellTitleBorderColor.setColor(color: nil)
				default:
					break
				}
			case .content:
				switch CellLyrics.for(indexPath) {
				case .fontFamily:
					cellLyricsFontFamily.setValue(value: nil, id: nil)
				case .textColor:
					cellLyricsTextColor.setColor(color: nil)
				case .borderColor:
					cellLyricsBorderColor.setColor(color: nil)
				default:
					break
				}
			case .image:
				switch CellImage.for(indexPath) {
				case .image:
					cellImagePicker.setImage(image: nil)
					if let path = sheet.imagePath {
						let _ = deleteImageFor(path: path)
					}
				case .borderColor:
					cellImageBorderColor.setColor(color: nil)
				case .contentMode:
					cellImageContentMode.setValue(value: nil, id: nil)
				default:
					break
				}
			}
		}
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch Section.for(indexPath.section) {
		case .general:
			switch CellGeneral.for(indexPath) {
			case .asTag:
				let cell = cellAsTag
				cell.isActive = !cell.isActive
				reloadDataWithScrollTo(cell)
			case .backgroundColor:
				let cell = cellBackgroundColor
				cell.isActive = !cell.isActive
				reloadDataWithScrollTo(cell)
			case .backgroundImage:
				let cell = cellPhotoPickerBackground
				cell.isActive = !cell.isActive
				reloadDataWithScrollTo(cell)
			default:
				break
			}
		case .title:
			switch CellTitle.for(indexPath) {
			case .fontFamily:
				let cell = cellTitleFontFamily
				cell.isActive = !cell.isActive
				reloadDataWithScrollTo(cell)
			case .alignment:
				let cell = cellTitleAlignment
				cell.isActive = !cell.isActive
				reloadDataWithScrollTo(cell)
			case .textColor:
				let cell = cellTitleTextColor
				cell.isActive = !cell.isActive
				reloadDataWithScrollTo(cell)
			case .backgroundColor:
				let cell = cellTitleBackgroundColor
				cell.isActive = !cell.isActive
				reloadDataWithScrollTo(cell)
			case .borderColor:
				let cell = cellTitleBorderColor
				cell.isActive = !cell.isActive
				reloadDataWithScrollTo(cell)
			default:
				break
			}
		case .content:
			switch CellLyrics.for(indexPath) {
			case .fontFamily:
				let cell = cellLyricsFontFamily
				cell.isActive = !cell.isActive
				reloadDataWithScrollTo(cell)
			case .alignment:
				let cell = cellLyricslAlignment
				cell.isActive = !cell.isActive
				reloadDataWithScrollTo(cell)
			case .textColor:
				let cell = cellLyricsTextColor
				cell.isActive = !cell.isActive
				reloadDataWithScrollTo(cell)
			case .borderColor:
				let cell = cellLyricsBorderColor
				cell.isActive = !cell.isActive
				reloadDataWithScrollTo(cell)
			default:
				break
			}
		case .image:
			switch CellImage.for(indexPath) {
			case .image:
				let cell = cellImagePicker
				cell.isActive = !cell.isActive
				reloadDataWithScrollTo(cell)
			case .borderColor:
				let cell = cellImageBorderColor
				cell.isActive = !cell.isActive
				reloadDataWithScrollTo(cell)
			case .contentMode:
				let cell = cellImageContentMode
				cell.isActive = !cell.isActive
				reloadDataWithScrollTo(cell)
			default:
				break
			}
		}
	}
	
	
	// MARK: - Delegate functions
	
	func textFieldDidChange(cell: LabelTextFieldCell ,text: String?) {
		if cell.id == "cellName" {
			sheet.title = text
		}
		if cell.id == "cellContent" {
			sheet.content = text
		}
		buildPreview(isSetup: isSetup)
	}
	
	func didSelect(item: (Int64, String), cell: LabelPickerCell) {
		if cell.id == "cellTitleFontFamily" {
			var size: CGFloat = 17
			if let font = titleAttributes[.font] as? UIFont {
				size = font.pointSize
			}
			titleAttributes[.font] = UIFont(name: item.1, size: size)
			buildPreview(isSetup: isSetup)
			if !isSetup {
				cell.isActive = !cell.isActive
			}
		}
		if cell.id == "cellLyricsFontFamily" {
			var size: CGFloat = 17
			if let font = lyricsAttributes[.font] as? UIFont {
				size = font.pointSize
			}
			lyricsAttributes[.font] = UIFont(name: item.1, size: size)
			buildPreview(isSetup: isSetup)
			if !isSetup {
				cell.isActive = !cell.isActive
			}
		}
		if cell.id == "cellAsTag" {
			CoreTag.predicates.append("id", equals: item.0)
			let name = cellName.textField.text ?? ""
			let tag = CoreTag.getEntities().first
			if let tag = tag {
				loadTagAttributes(tag)
			}
			cellName.setName(name: name)
			if !isSetup {
				cell.isActive = !cell.isActive
			}
		}
		if cell.id == "cellTitleFontAlignment" {
			let paragraph = NSMutableParagraphStyle()
			if item.1 == Text.NewTag.alignLeft {
				paragraph.alignment = .left
				titleAttributes[.paragraphStyle] = paragraph
			} else if item.1 == Text.NewTag.alignRight {
				paragraph.alignment = .right
				titleAttributes[.paragraphStyle] = paragraph
			} else if item.1 == Text.NewTag.alignCenter {
				paragraph.alignment = .center
				titleAttributes[.paragraphStyle] = paragraph
			}
			if !isSetup {
				cell.isActive = !cell.isActive
			}
		}
		if cell.id == "cellLyricsFontAlignment" {
			let paragraph = NSMutableParagraphStyle()
			if item.1 == Text.NewTag.alignLeft {
				paragraph.alignment = .left
				lyricsAttributes[.paragraphStyle] = paragraph
			} else if item.1 == Text.NewTag.alignRight {
				paragraph.alignment = .right
				lyricsAttributes[.paragraphStyle] = paragraph
			} else if item.1 == Text.NewTag.alignCenter {
				paragraph.alignment = .center
				lyricsAttributes[.paragraphStyle] = paragraph
			}
			if !isSetup {
				cell.isActive = !cell.isActive
			}
		}
		if cell.id == "cellImageContentMode" {
			sheet.imageContentMode = Int16(item.0)
		}
		buildPreview(isSetup: isSetup)
		tableView.beginUpdates()
		tableView.endUpdates()
	}
	
	func didSelectSwitch(first: Bool?, second: Bool?, cell: LabelDoubleSwitchCell) {
		
	}
	
	func numberChangedForCell(cell: LabelNumberCell) {
		
		if cell.id == "cellTitleFontSize" {
			if let family = titleAttributes[.font] as? UIFont {
				titleAttributes[.font] = UIFont(name: family.fontName, size: CGFloat(cell.value))
			} else {
				titleAttributes[.font] = UIFont(name: UIFont.systemFont(ofSize: 1).fontName, size: CGFloat(cell.value))
			}
			buildPreview(isSetup: isSetup)
		}
		if cell.id == "cellTitleBorderSize" {
			titleAttributes[.strokeWidth] = cell.value
		}
		
		if cell.id == "cellLyricsFontSize"{
			if let family = lyricsAttributes[.font] as? UIFont {
				lyricsAttributes[.font] = UIFont(name: family.fontName, size: CGFloat(cell.value))
			} else {
				lyricsAttributes[.font] = UIFont(name: UIFont.systemFont(ofSize: 1).fontName, size: CGFloat(cell.value))
			}
		}
		if cell.id == "cellLyricsBorderSize" {
			lyricsAttributes[.strokeWidth] = cell.value
		}
		if cell.id == "cellImageBorderSize" {
			sheet.imageBorderSize = Int16(cell.value)
		}
		buildPreview(isSetup: isSetup)
	}
	
	func colorPickerDidChooseColor(cell: LabelColorPickerCell, colorPicker: ChromaColorPicker, color: UIColor?) {
		if cell.id == "cellTitleTextColor" {
			if let color = color {
				titleAttributes[.foregroundColor] = color
				titleAttributes[.underlineColor] = color
			} else {
				titleAttributes[.foregroundColor] = UIColor.black
				titleAttributes[.underlineColor] = UIColor.black
			}
		} else if cell.id == "cellTitleBorderColor" {
			if let color = color {
				titleAttributes[.strokeColor] = color
			} else {
				cellTitleBorderSize.setValue(value: 0)
				titleAttributes.removeValue(forKey: .strokeColor)
			}
		} else if cell.id == "cellTitleBackgroundColor" {
			if let color = color {
				tag.backgroundColorTitle = color
			} else {
				tag.backgroundColorTitle = .clear
			}
		}
		
		if cell.id == "cellLyricsTextColor" {
			if let color = color {
				lyricsAttributes[.foregroundColor] = color
				lyricsAttributes[.underlineColor] = color
			} else {
				lyricsAttributes[.foregroundColor] = UIColor.black
				lyricsAttributes[.underlineColor] = UIColor.black
			}
		} else if cell.id == "cellLyricsBorderColor" {
			if let color = color {
				lyricsAttributes[.strokeColor] = color
			} else {
				cellLyricsBorderSize.setValue(value: 0)
				lyricsAttributes.removeValue(forKey: .strokeColor)
			}
		}
		if cell.id == "cellBackgroundColor" {
			if let color = color {
				tag.sheetBackgroundColor = color
			} else {
				tag.sheetBackgroundColor = .white
			}
		}
		
		if cell.id == "cellImageBorderColor" {
			if let color = color {
				sheet.imageBorderColor = color.hexCode
			}
		}
		
		buildPreview(isSetup: isSetup)
		tableView.beginUpdates()
		tableView.endUpdates()
		
	}
	
	func valueChangedFor(cell: LabelSwitchCell, uiSwitch: UISwitch) {
		
		switch cell.id {
		case "cellAllHaveTitle":
			tag.allHaveTitle = uiSwitch.isOn ? true : false
		case "cellTitleBold":
			if let font = titleAttributes[.font] as? UIFont {
				if uiSwitch.isOn {
					titleAttributes[.font] = font.setBoldFnc()
				} else {
					titleAttributes[.font] = font.detBoldFnc()
				}
			}
		case "cellTitleItalic":
			if let font = titleAttributes[.font] as? UIFont {
				if uiSwitch.isOn {
					titleAttributes[.font] = font.setItalicFnc()
				} else {
					titleAttributes[.font] = font.detItalicFnc()
				}
			}
		case "cellTitleUnderlined":
			if uiSwitch.isOn {
				titleAttributes[.underlineStyle] = NSUnderlineStyle.styleSingle.rawValue
			} else {
				titleAttributes.removeValue(forKey: .underlineStyle)
			}
		default:
			break
		}
		
		switch cell.id {
		case "cellLyricsBold":
			if let font = lyricsAttributes[.font] as? UIFont {
				if uiSwitch.isOn {
					lyricsAttributes[.font] = font.setBoldFnc()
				} else {
					lyricsAttributes[.font] = font.detBoldFnc()
				}
			}
		case "cellLyricsItalic":
			if let font = lyricsAttributes[.font] as? UIFont {
				if uiSwitch.isOn {
					lyricsAttributes[.font] = font.setItalicFnc()
				} else {
					lyricsAttributes[.font] = font.detItalicFnc()
				}
			}
		case "cellLyricsUnderlined":
			if uiSwitch.isOn {
				lyricsAttributes[.underlineStyle] = NSUnderlineStyle.styleSingle.rawValue
			} else {
				lyricsAttributes.removeValue(forKey: .underlineStyle)
			}
		default:
			break
		}
		
		switch cell.id {
		case "cellImageHasBorder":
			sheet.imageHasBorder = uiSwitch.isOn

			if !uiSwitch.isOn {
				sheet.imageHasBorder = uiSwitch.isOn
				cellImageBorderSize.setValue(value: 0)
				cellImageBorderColor.setColor(color: nil)
			}
		default:
			break
		}
		
		buildPreview(isSetup: isSetup)
		
	}
	
	func didSelectImage(cell: LabelPhotoPickerCell, image: UIImage) {
		if cell.id == "cellPhotoPickerBackground" {
			if !isSetup {
				cell.isActive = !cell.isActive
			}
			tag.imagePath = saveImage(image: image, id: tag.id)
			tableView.beginUpdates()
			tableView.endUpdates()
			tableView.reloadData()
			buildPreview(isSetup: isSetup)
		}
		if cell.id == "cellImagePicker" {
			if !isSetup {
				cell.isActive = !cell.isActive
			}
			sheet.imagePath = saveImage(image: image, id: sheet.id)
			tableView.beginUpdates()
			tableView.endUpdates()
			tableView.reloadData()
			buildPreview(isSetup: isSetup)
		}
	}
	
	
	
	// MARK: - Private Functions
	
	private func setup() {
		
		if let sheet = sheet, let tag = sheet.hasTag {
			self.tag = tag
		} else {
			sheet = CoreSheetTitleImage.createEntity()
		}

		if tag == nil {
			tag = CoreTag.createEntity()
			tag.isHidden = true // this tag will not show up in the tag list for users
		}
		
		
		NotificationCenter.default.addObserver(forName: NotificationNames.externalDisplayDidChange, object: nil, queue: nil, using: externalDisplayDidChange)
		
		tableView.register(cell: Cells.labelNumberCell)
		tableView.register(cell: Cells.LabelPickerCell)
		tableView.register(cell: Cells.LabelSwitchCell)
		tableView.register(cell: Cells.labelTextFieldCell)
		tableView.register(cell: Cells.LabelPhotoPickerCell)
		
		// create cells
		
		let fontFamilyValues = UIFont.familyNames.map{ (Int64(0), $0) }.sorted { $0.1 < $1.1 }
		cellTitleFontFamily = LabelPickerCell.create(id: "cellTitleFontFamily", description: Text.NewTag.fontFamilyDescription, initialValueName: "Avenir", pickerValues: fontFamilyValues)
		cellLyricsFontFamily = LabelPickerCell.create(id: "cellLyricsFontFamily", description: Text.NewTag.fontFamilyDescription, initialValueName: "Avenir", pickerValues: fontFamilyValues)
		
		CoreTag.setSortDescriptor(attributeName: "title", ascending: true)
		let tags = CoreTag.getEntities().map{ ($0.id, $0.title ?? "") }
		cellAsTag = LabelPickerCell.create(id: "cellAsTag", description: Text.NewTag.descriptionAsTag, initialValueName: "", pickerValues: tags)
		
		cellPhotoPickerBackground = LabelPhotoPickerCell.create(id: "cellPhotoPickerBackground", description: Text.NewTag.backgroundImage, sender: self)
		cellPhotoPickerBackground.setup()
		
		cellImagePicker = LabelPhotoPickerCell.create(id: "cellImagePicker", description: Text.NewSheetTitleImage.descriptionImage, sender: self)
		cellImagePicker.setup()
		
		var modeValues: [(Int64, String)] = []
		for (index, mode) in dutchContentMode().enumerated() {
			modeValues.append((Int64(index), mode))
		}
		
		// set delegates
		
		cellAsTag.delegate = self
		cellContent.delegate = self
		cellName.setup()
		cellContent.setup()
		cellName.delegate = self
		cellPhotoPickerBackground.delegate = self
		cellBackgroundColor.delegate = self
		
		cellTitleFontFamily.delegate = self
		cellTitleFontSize.delegate = self
		cellTitleAlignment.delegate = self
		cellTitleBorderSize.delegate = self
		cellTitleBorderColor.delegate = self
		cellTitleBackgroundColor.delegate = self
		cellTitleTextColor.delegate = self
		cellTitleBold.delegate = self
		cellTitleItalic.delegate = self
		cellTitleUnderLined.delegate = self
		
		cellLyricsFontFamily.delegate = self
		cellLyricsFontSize.delegate = self
		cellLyricslAlignment.delegate = self
		cellLyricsBorderSize.delegate = self
		cellLyricsBorderColor.delegate = self
		cellLyricsTextColor.delegate = self
		cellLyricsBold.delegate = self
		cellLyricsItalic.delegate = self
		cellLyricsUnderLined.delegate = self
		
		cellImagePicker.delegate = self
		cellImageHasBorder.delegate = self
		cellImageBorderSize.delegate = self
		cellImageBorderColor.delegate = self
		cellImageContentMode.delegate = self
		
		cellImageHasBorder.setSwitchValueTo(value: true)
		cellImageContentMode = LabelPickerCell.create(id: "cellImageContentMode", description: Text.NewSheetTitleImage.descriptionImageContentMode, initialValueName: dutchContentMode()[2], pickerValues: modeValues)
		cellTitleFontFamily.setValue(value: "Avenir", id: nil)
		cellLyricsFontFamily.setValue(value: "Avenir", id: nil)

		refineSheetRatio()
		
		titleAttributes[.font] = UIFont(name: "Avenir", size: 17)
		cellTitleTextColor.setColor(color: .black)
		lyricsAttributes[.font] = UIFont(name: "Avenir", size: 17)
		cellLyricsTextColor.setColor(color: .black)
		
		cancel.title = Text.Actions.cancel
		save.title = Text.Actions.save
		
		hideKeyboardWhenTappedAround()
		
		tableView.keyboardDismissMode = .interactive
		
		isSetup = false
		loadSheetAttributes()
		loadTagAttributes(tag)
	}
	
	private func reloadDataWithScrollTo(_ cell: UITableViewCell) {
		tableView.reloadData()
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
			self.tableView.scrollRectToVisible(cell.frame, animated: true)
		}
	}
	
	
	private func getTitleCellFor(indexPath: IndexPath) -> UITableViewCell {
		switch CellTitle.for(indexPath) {
		case .fontFamily: return cellTitleFontFamily
		case .fontSize: return cellTitleFontSize
		case .textColor: return cellTitleTextColor
		case .backgroundColor: return cellTitleBackgroundColor
		case .alignment: return cellTitleAlignment
		case .borderSize: return cellTitleBorderSize
		case .borderColor: return cellTitleBorderColor
		case .bold: return cellTitleBold
		case .italic: return cellTitleItalic
		case .underlined: return cellTitleUnderLined
		}
	}
	
	private func getLyricsCellFor(indexPath: IndexPath) -> UITableViewCell {
		switch CellLyrics.for(indexPath) {
		case .fontFamily: return cellLyricsFontFamily
		case .fontSize: return cellLyricsFontSize
		case .alignment: return cellLyricslAlignment
		case .textColor: return cellLyricsTextColor
		case .borderSize: return cellLyricsBorderSize
		case .borderColor: return cellLyricsBorderColor
		case .bold: return cellLyricsBold
		case .italic: return cellLyricsItalic
		case .underlined: return cellLyricsUnderLined
		}
	}
	
	private func getGeneralCellFor(indexPath: IndexPath) -> UITableViewCell {
		switch CellGeneral.for(indexPath) {
		case .name: return cellName
		case .content: return cellContent
		case .asTag: return cellAsTag
		case .backgroundColor: return cellBackgroundColor
		case .backgroundImage: return cellPhotoPickerBackground
		}
	}
	
	private func getImageCellFor(indexPath: IndexPath) -> UITableViewCell {
		switch CellImage.for(indexPath) {
		case .image: return cellImagePicker
		case .hasBorder: return cellImageHasBorder
		case .borderSize: return cellImageBorderSize
		case .borderColor: return cellImageBorderColor
		case .contentMode: return cellImageContentMode
		}
	}
	
	
	private func loadTagAttributes(_ tag: Tag) {
		isSetup = true

		cellName.setName(name: sheet.title ?? "")
		cellTitleFontFamily.setValue(value: tag.titleFontName ?? "Avenir")
		cellTitleFontSize.setValue(value: Int(tag.titleTextSize))
		cellTitleAlignment.setValue(value: tag.titleAlignment, id: nil)
		cellTitleBorderSize.setValue(value: Int(tag.titleBorderSize))
		cellTitleBorderColor.setColor(color: tag.borderColorTitle)
		cellTitleTextColor.setColor(color: tag.textColorTitle)
		cellTitleBold.setSwitchValueTo(value: tag.isTitleBold)
		cellTitleItalic.setSwitchValueTo(value: tag.isTitleItalian)
		cellTitleUnderLined.setSwitchValueTo(value: tag.isTitleUnderlined)
		
		cellLyricsFontFamily.setValue(value: tag.lyricsFontName ?? "Avenir")
		cellLyricsFontSize.setValue(value: Int(tag.lyricsTextSize))
		cellLyricslAlignment.setValue(value: tag.lyricsAlignment, id: nil)
		cellLyricsBorderSize.setValue(value: Int(tag.lyricsBorderSize))
		cellLyricsBorderColor.setColor(color: tag.borderColorLyrics)
		cellLyricsTextColor.setColor(color: tag.textColorLyrics)
		cellLyricsBold.setSwitchValueTo(value: tag.isLyricsBold)
		cellLyricsItalic.setSwitchValueTo(value: tag.isLyricsItalian)
		cellLyricsUnderLined.setSwitchValueTo(value: tag.isLyricsUnderlined)
		
		if let image = tag.backgroundImage {
			cellPhotoPickerBackground.setImage(image: image)
		}
		
		for subview in previewView.subviews {
			subview.removeFromSuperview()
		}
		isSetup = false
		buildPreview(isSetup: isSetup)
	}
	
	private func loadSheetAttributes() {
		isSetup = true
		
		cellName.setName(name: sheet.title ?? "")
		cellContent.setName(name: sheet.content ?? "")
		cellImagePicker.setImage(image: sheet.image)
		cellImageHasBorder.setSwitchValueTo(value: sheet.imageHasBorder)
		cellImageBorderSize.setValue(value: Int(sheet.imageBorderSize))
		if let color = sheet.imageBorderColor {
			cellImageBorderColor.setColor(color: UIColor(hex: color))
		}
		cellImageContentMode.setValue(value: nil, id: sheet.imageContentMode)
		isSetup = false
	}
	
	private func buildPreview(isSetup: Bool) {
		if !isSetup {
			if let externalDisplayWindow = externalDisplayWindow {
				
				for subview in previewView.subviews {
					subview.removeFromSuperview()
				}
				
				generateTag()
				
				let view = SheetTitleImage.createSheetTitleImageWith(frame: previewView.frame, sheet: sheet, tag: tag)
				
				previewView.addSubview(view)
				let beamerView = SheetTitleImage.createSheetTitleImageWith(frame: externalDisplayWindow.frame, sheet: self.sheet, tag: self.tag, scaleFactor: externalDisplayWindowWidth / self.previewView.bounds.width)
				externalDisplayWindow.addSubview(beamerView)
				
			} else {
				
				for subview in previewView.subviews {
					subview.removeFromSuperview()
				}
				
				generateTag()
				let view = SheetTitleImage.createSheetTitleImageWith(frame: previewView.bounds, sheet: sheet, tag: tag)
				previewView.addSubview(view)
				
			}
		}
	}
	
	
	private func saveImage(image: UIImage, id: Int64) -> String? {
		if let data = UIImagePNGRepresentation(image) {
			let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
			let imagePath = String(id) + ".png"
			let filename = documentsDirectory.appendingPathComponent(imagePath)
			try? data.write(to: filename)
			return imagePath
		}
		return nil
	}
	
	private func deleteImageFor(path: String) -> Bool {
		let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
		let url = documentsDirectory.appendingPathComponent(path)
		do {
			try FileManager.default.removeItem(at: url)
			return true
		} catch let error as NSError {
			print("Error: \(error.domain)")
			return false
		}
	}
	
	@objc func externalDisplayDidChange(_ notification: Notification) {
		refineSheetRatio()
	}
	
	private func refineSheetRatio() {
		
		// sheet ratio ajustments
		
		// deactivate standard constraint
		previewViewRatioConstraint.isActive = false
		
		// remove previous constraint
		if let externalDisplayRatioConstraint = externalDisplayRatioConstraint {
			previewView.removeConstraint(externalDisplayRatioConstraint)
		}
		
		// add new constraint
		externalDisplayRatioConstraint = NSLayoutConstraint(item: previewView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: previewView, attribute: NSLayoutAttribute.width, multiplier: externalDisplayWindowRatio, constant: 0)
		previewView.addConstraint(externalDisplayRatioConstraint!)
		
		
		// Container view height ajustments
		
		// remove previous active constraint
		if let newHeightconstraint = newSheetContainerViewHeightConstraint {
			sheetContainerView.removeConstraint(newHeightconstraint)
		}
		// deactivate standard constraint
		sheetContainerViewHeightConstraint.isActive = false
		
		// add new constraint
		newSheetContainerViewHeightConstraint = NSLayoutConstraint(item: sheetContainerView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: (UIScreen.main.bounds.width - 20) * externalDisplayWindowRatio)
		sheetContainerView.addConstraint(newSheetContainerViewHeightConstraint!)
		previewView.layoutIfNeeded()
		buildPreview(isSetup: isSetup)
		
	}
	
	private func generateTag() {
		CoreTag.predicates.append("id", equals: tag.id)
		if CoreTag.getEntities().count == 0 {
			tag.id = CoreTag.getNewIDForEntityNOTsave()
		}
		
		if let titleFont = titleAttributes[.font] as? UIFont {
			tag.titleFontName = titleFont.familyName
			tag.titleTextSize = Float(titleFont.pointSize)
			tag.isTitleBold = titleFont.isBold
			tag.isTitleItalian = titleFont.isItalic
		}
		
		if let titleAlignment = titleAttributes[.paragraphStyle] as? NSMutableParagraphStyle {
			switch titleAlignment.alignment {
			case .left:
				tag.titleAlignment = Text.NewTag.alignLeft
			case .center:
				tag.titleAlignment = Text.NewTag.alignCenter
			case .right:
				tag.titleAlignment = Text.NewTag.alignRight
			default:
				break
			}
		}
		
		if let lyricsAlignment = lyricsAttributes[.paragraphStyle] as?  NSMutableParagraphStyle {
			switch lyricsAlignment.alignment {
			case .left:
				tag.lyricsAlignment = Text.NewTag.alignLeft
			case .center:
				tag.lyricsAlignment = Text.NewTag.alignCenter
			case .right:
				tag.lyricsAlignment = Text.NewTag.alignRight
			default:
				break
			}
		}
		
		if let titleBorderSize = titleAttributes[.strokeWidth] as? Int {
			tag.titleBorderSize = Int16(titleBorderSize)
		} else {
			tag.titleBorderSize = Int16(0)
		}
		
		if let titleColor = titleAttributes[.foregroundColor] as? UIColor {
			tag.textColorTitle = titleColor
		} else {
			tag.textColorTitle = nil
		}
		
		if let titleStrokeColor = titleAttributes[.strokeColor] as? UIColor {
			tag.borderColorTitle = titleStrokeColor
		} else {
			tag.borderColorTitle = nil
		}
		
		if let _ = titleAttributes[.underlineStyle] as? Int {
			tag.isTitleUnderlined = true
		} else {
			tag.isTitleUnderlined = false
		}
		
		if let lyricsFont = lyricsAttributes[.font] as? UIFont {
			tag.lyricsFontName = lyricsFont.familyName
			tag.lyricsTextSize = Float(lyricsFont.pointSize)
			tag.isLyricsBold = lyricsFont.isBold
			tag.isLyricsItalian = lyricsFont.isItalic
		}
		
		if let lyricsBorderSize = lyricsAttributes[.strokeWidth] as? Int {
			tag.lyricsBorderSize = Int16(lyricsBorderSize)
		} else {
			tag.lyricsBorderSize = Int16(0)
		}
		
		if let lyricsColor = lyricsAttributes[.foregroundColor] as? UIColor {
			tag.textColorLyrics = lyricsColor
		} else {
			tag.textColorLyrics = nil
		}
		
		if let lyricsStrokeColor = lyricsAttributes[.strokeColor] as? UIColor {
			tag.borderColorLyrics = lyricsStrokeColor
		} else {
			tag.borderColorLyrics = nil
		}
		
		if let _ = lyricsAttributes[.underlineStyle] as? Int {
			tag.isLyricsUnderlined = true
		} else {
			tag.isLyricsUnderlined = false
		}
		
		if let image = cellPhotoPickerBackground.pickedImage {
			tag.imagePath = saveImage(image: image, id: tag.id)
		} else {
			if let path = tag.imagePath {
				if deleteImageFor(path: path) {
					tag.imagePath = nil
				}
			}
		}
	}
	
	private func dutchContentMode() -> [String] {
		
		return ["vul, maar verlies verhouding", "vul maar behoud verhouding", "vul alles", "vullen", "midden", "boven", "onder", "links", "rechts", "links boven", "rechts boven", "links onder", "rechts onder"]

	}
	
	
	
	
	
	@IBAction func cancelPressed(_ sender: UIBarButtonItem) {
		
		if let externalDisplayWindow = externalDisplayWindow {
			let view = UIView(frame: externalDisplayWindow.frame)
			view.backgroundColor = .black
			externalDisplayWindow.addSubview(view)
		}
		
		if editExtistingSheet {
			if let path = tag.imagePath {
				let _ = deleteImageFor(path: path)
			}
			
			let _ = CoreTag.delete(entity: tag) // delete temp tag
			
			if let path = sheet.imagePath {
				let _ = deleteImageFor(path: path)
			}
			
			let _ = CoreSheet.delete(entity: sheet)
		}
		
		dismiss(animated: true)
	}
	
	@IBAction func savePressed(_ sender: UIBarButtonItem) {
		
		if sheet.title == nil || sheet.title == "" {
			let message = UIAlertController(title: Text.NewTag.errorTitle, message:
				Text.NewTag.errorMessage, preferredStyle: UIAlertControllerStyle.alert)
			message.addAction(UIAlertAction(title: Text.Actions.close, style: UIAlertActionStyle.default,handler: nil))
			
			self.present(message, animated: true, completion: nil)
			
		} else {
			
			generateTag()

			if let image = cellImagePicker.pickedImage {
				sheet.imagePath = saveImage(image: image, id: sheet.id)
			}
			
			sheet.hasTag = tag
			
			let _ = CoreSheetTitleImage.saveContext()
			
			delegate?.didCreate(sheet: sheet)
			dismiss(animated: true)
			
		}
		
	}
}
