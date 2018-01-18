//
//  NewOrEditIphoneController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 15-01-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import UIKit
import ChromaColorPicker

protocol NewOrEditIphoneControllerDelegate {
	func didCreate(sheet: Sheet)
}

class NewOrEditIphoneController: UIViewController, UITableViewDelegate, UITableViewDataSource, LabelTextFieldCellDelegate, LabelTextViewDelegate, LabelPickerCellDelegate, LabelDoubleSwitchDelegate, LabelNumerCellDelegate, LabelColorPickerCellDelegate, LabelSwitchCellDelegate, LabelPhotoPickerCellDelegate {
	
	
	@IBOutlet var cancel: UIBarButtonItem!
	@IBOutlet var save: UIBarButtonItem!
	@IBOutlet var previewView: UIView!
	@IBOutlet var tableView: UITableView!
	@IBOutlet var sheetContainerView: UIView!
	@IBOutlet var sheetContainerViewHeightConstraint: NSLayoutConstraint!
	@IBOutlet var previewViewRatioConstraint: NSLayoutConstraint!
	
	
	// MARK: - Types
	
	enum Section: String {
		case general
		case title
		case content
		case image
		
		static let all = [general, title, content, image]
		
		static let titleContent = [general, title, content]
		static let titleImage = [general, title, content, image]
		static let sheetSplit = [general, title, content]
		static let sheetEmpty = [general]
		
		static func `for`(_ section: Int, type: SheetType) -> Section {
			switch type {
			case .SheetTitleContent:
				return titleContent[section]
			case .SheetTitleImage:
				return titleImage[section]
			case .SheetSplit:
				return sheetSplit[section]
			case .SheetEmpty:
				return sheetEmpty[section]
			}
		}
	}
	
	enum CellGeneral: String {
		case name
		case content
		case textLeft
		case textRight
		case asTag
		case hasEmptySheet
		case allHaveTitle
		case backgroundColor
		case backgroundImage
		
		static let all = [name, content, textLeft, textRight, asTag, hasEmptySheet, allHaveTitle, backgroundColor, backgroundImage]
		
		static let tag = [name, asTag, hasEmptySheet, allHaveTitle, backgroundColor, backgroundImage]
		static let titleContent = [name, content, asTag, hasEmptySheet, allHaveTitle, backgroundColor, backgroundImage]
		static let titleImage = [name, content, asTag, backgroundColor, backgroundImage]
		static let sheetSplit = [name, textLeft, textRight, asTag, hasEmptySheet, allHaveTitle, backgroundColor, backgroundImage]
		static let sheetEmpty = [name, hasEmptySheet, backgroundColor, backgroundImage]
		
		static func `for`(_ indexPath: IndexPath, type: SheetType) -> CellGeneral {
			switch type {
			case .SheetTitleContent:
				return titleContent[indexPath.row]
			case .SheetTitleImage:
				return titleImage[indexPath.row]
			case .SheetSplit:
				return sheetSplit[indexPath.row]
			case .SheetEmpty:
				return sheetEmpty[indexPath.row]
			}
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
		
		static let titleContent = [fontFamily, fontSize, backgroundColor, alignment, borderSize, textColor, borderColor, bold, italic, underlined]
		static let titleImage = [fontFamily, fontSize, backgroundColor, alignment, borderSize, textColor, borderColor, bold, italic, underlined]
		static let sheetSplit = [fontFamily, fontSize, backgroundColor, alignment, borderSize, textColor, borderColor, bold, italic, underlined]
		static let sheetEmpty: [CellTitle] = []
		
		static func `for`(_ indexPath: IndexPath) -> CellTitle {
			return all[indexPath.row]
		}
		
		static func `for`(_ indexPath: IndexPath, type: SheetType) -> CellTitle? {
			switch type {
			case .SheetTitleContent:
				return titleContent[indexPath.row]
			case .SheetTitleImage:
				return titleImage[indexPath.row]
			case .SheetSplit:
				return sheetSplit[indexPath.row]
			default:
				return nil
			}
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
		
		static let titleContent = [fontFamily, fontSize, alignment, borderSize, textColor, borderColor, bold, italic, underlined]
		static let titleImage = [fontFamily, fontSize, alignment, borderSize, textColor, borderColor, bold, italic, underlined]
		static let sheetSplit = [fontFamily, fontSize, alignment, borderSize, textColor, borderColor, bold, italic, underlined]
		static let sheetEmpty: [CellLyrics] = []
		
		static func `for`(_ indexPath: IndexPath, type: SheetType) -> CellLyrics? {
			switch  type{
			case .SheetTitleContent:
				return titleContent[indexPath.row]
			case .SheetTitleImage:
				return titleImage[indexPath.row]
			case .SheetSplit:
				return sheetSplit[indexPath.row]
			default:
				return nil
			}
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
		
		static func `for`(_ indexPath: IndexPath, type: SheetType) -> CellImage? {
			if type == .SheetTitleImage {
				return all[indexPath.row]
			} else {
				return nil
			}
		}
	}
	
	// MARK: - Properties
	// MARK: General Cells
	
	private let cellName = LabelTextFieldCell.create(id: "cellName", description: Text.NewSheetTitleImage.descriptionTitle, placeholder: Text.NewTag.descriptionTitlePlaceholder)
	private let cellContent = LabelTextView.create(id: "cellContent", description: Text.NewSheetTitleImage.descriptionContent, placeholder: Text.NewSheetTitleImage.placeholderContent)
	private var cellTextLeft = LabelTextView.create(id: "cellTextLeft", description: Text.NewSheetTitleImage.descriptionTextLeft, placeholder: Text.NewSheetTitleImage.descriptionTextLeft)
	private var cellTextRight = LabelTextView.create(id: "cellTextRight", description: Text.NewSheetTitleImage.descriptionTextRight, placeholder: Text.NewSheetTitleImage.descriptionTextRight)
	private var  cellAsTag = LabelPickerCell()
	private var  cellPhotoPickerBackground = LabelPhotoPickerCell()
	private var  cellBackgroundColor = LabelColorPickerCell.create(id: "cellBackgroundColor", description: Text.NewTag.descriptionBackgroundColor)
	private var  cellHasEmptySheet = LabelDoubleSwitchCell.create(id: "cellHasEmptySheet", descriptionSwitchOne: Text.NewTag.descriptionHasEmptySheet, descriptionSwitchTwo: Text.NewTag.descriptionPositionEmptySheet)
	private let cellAllHaveTitlle = LabelSwitchCell.create(id: "cellAllHaveTitle", description: Text.NewTag.descriptionAllTitle, initialValueIsOn: false)
	
	
	// MARK: Title Cells
	
	private var  cellTitleFontFamily = LabelPickerCell()
	private let cellTitleFontSize = LabelNumberCell.create(id: "cellTitleFontSize", description: Text.NewTag.fontSizeDescription, initialValue: 14)
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
	private let cellLyricsFontSize = LabelNumberCell.create(id: "cellLyricsFontSize", description: Text.NewTag.fontSizeDescription, initialValue: 10)
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
	var newTagMode = false // if saved pressed, don't save sheet
	var editTagMode = false // if cancel pressed, don't delete tag
	var tag: Tag!
	var sheet: Sheet!
	var delegate: NewOrEditIphoneControllerDelegate?
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
		switch sheet.type {
		case .SheetTitleContent:
			return Section.titleContent.count
		case .SheetTitleImage:
			return Section.titleImage.count
		case .SheetSplit:
			return Section.sheetSplit.count
		case .SheetEmpty:
			return Section.sheetEmpty.count
		}
		return newTagMode || editTagMode ? Section.titleContent.count : Section.all.count
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch Section.for(section, type: sheet.type) {
		case .general:
			switch sheet.type {
			case .SheetTitleContent: return newTagMode || editTagMode ? CellGeneral.tag.count : CellGeneral.all.count
			case .SheetTitleImage: return CellGeneral.titleImage.count
			case .SheetSplit: return CellGeneral.sheetSplit.count
			case .SheetEmpty: return CellGeneral.sheetEmpty.count
			}
		case .title:
			switch sheet.type {
			case .SheetTitleContent: return CellTitle.titleContent.count
			case .SheetTitleImage: return CellTitle.titleImage.count
			case .SheetSplit: return CellTitle.sheetSplit.count
			case .SheetEmpty: return CellTitle.sheetEmpty.count
			}
		case .content:
			switch sheet.type {
			case .SheetTitleContent: return CellLyrics.titleContent.count
			case .SheetTitleImage: return CellLyrics.titleImage.count
			case .SheetSplit: return CellLyrics.sheetSplit.count
			case .SheetEmpty: return CellLyrics.sheetEmpty.count
			}
		case .image:
			switch sheet.type {
			case .SheetTitleImage: return CellImage.all.count
			default:
				return 0
			}
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch Section.for(indexPath.section, type: sheet.type) {
		case .general: return getGeneralCellFor(indexPath: indexPath)
		case .title: return getTitleCellFor(indexPath: indexPath)
		case .content: return getLyricsCellFor(indexPath: indexPath)
		case .image: return getImageCellFor(indexPath: indexPath)
		}
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		switch Section.for(indexPath.section, type: sheet.type) {
		case .general:
			switch CellGeneral.for(indexPath, type: sheet.type) {
			case .asTag: return cellAsTag.preferredHeight
			case .content: return cellContent.preferredHeight
			case .textLeft: return cellTextLeft.preferredHeight
			case .textRight: return cellTextRight.preferredHeight
			case .hasEmptySheet: return cellHasEmptySheet.preferredHeight
			case .backgroundColor: return cellBackgroundColor.preferredHeight
			case .backgroundImage: return cellPhotoPickerBackground.preferredHeight
			default:
				return 60
			}
		case .title:
			switch CellTitle.for(indexPath, type: sheet.type) {
			case .some(.fontFamily): return cellTitleFontFamily.preferredHeight
			case .some(.fontSize): return cellTitleFontSize.preferredHeight
			case .some(.alignment): return cellTitleAlignment.preferredHeight
			case .some(.textColor): return cellTitleTextColor.preferredHeight
			case .some(.backgroundColor): return cellTitleBackgroundColor.preferredHeight
			case .some(.borderSize): return cellTitleBorderSize.preferredHeight
			case .some(.borderColor): return cellTitleBorderColor.preferredHeight
			case .none: return 60
			default: return 60
			}
		case .content:
			switch CellLyrics.for(indexPath, type: sheet.type) {
			case .some(.fontFamily): return cellLyricsFontFamily.preferredHeight
			case .some(.fontSize): return cellLyricsFontSize.preferredHeight
			case .some(.alignment): return cellLyricslAlignment.preferredHeight
			case .some(.textColor): return cellLyricsTextColor.preferredHeight
			case .some(.borderSize): return cellLyricsBorderSize.preferredHeight
			case .some(.borderColor): return cellLyricsBorderColor.preferredHeight
			case .none: return 60
			default: return 60
			}
		case .image:
			switch CellImage.for(indexPath, type: sheet.type) {
			case .some(.image): return cellImagePicker.preferredHeight
			case .some(.borderColor): return cellImageBorderColor.preferredHeight
			case .some(.contentMode): return cellImageContentMode.preferredHeight
			case .none: return 60
			default: return 60
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
		switch Section.for(section, type: sheet.type) {
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
		switch Section.for(indexPath.section, type: sheet.type) {
		case .general:
			switch CellGeneral.for(indexPath, type: sheet.type) {
			case .backgroundColor:
				return cellBackgroundColor.isActive ? .none : .delete
			case .asTag:
				return cellAsTag.isActive ? .none : .delete
			case .content:
				return .delete
			case .textLeft:
				return cellTextLeft.isActive ? .none : .delete
			case .textRight: return cellTextRight.isActive ? .none: .delete
			case .backgroundImage:
				return cellPhotoPickerBackground.isActive ? .none : cellPhotoPickerBackground.pickedImage != nil ? .delete : .none
			default:
				return .none
			}
		case .title:
			switch CellTitle.for(indexPath, type: sheet.type) {
			case .some(.fontFamily): return cellTitleFontFamily.isActive ? .none: .delete
			case .some(.backgroundColor): return cellTitleBackgroundColor.isActive ? .none : .delete
			case .some(.textColor): return cellTitleTextColor.isActive ? .none : .delete
			case .some(.borderColor): return cellTitleBorderColor.isActive ? .none : .delete
			default: return .none
			}
		case .content:
			switch CellLyrics.for(indexPath, type: sheet.type) {
			case .some(.fontFamily): return cellLyricsFontFamily.isActive ? .none : .delete
			case .some(.textColor): return cellLyricsTextColor.isActive ? .none : .delete
			case .some(.borderColor): return cellLyricsBorderColor.isActive ? .none : .delete
			default: return .none
			}
		case .image:
			switch CellImage.for(indexPath, type: sheet.type) {
			case .some(.image): return cellImagePicker.isActive ? .none : .delete
			case .some(.borderColor): return cellImageBorderColor.isActive ? .none : .delete
			case .some(.contentMode): return cellImageContentMode.isActive ? .none : .delete
			default: return .none
			}
		}
	}
	
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			switch Section.for(indexPath.section, type: sheet.type) {
			case .general:
				switch CellGeneral.for(indexPath, type: sheet.type) {
				case .asTag: cellAsTag.setValue(value: nil, id: nil)
				case .content: cellContent.set(text: nil)
				case .textLeft: cellTextLeft.set(text: nil)
				case .textRight: cellTextRight.set(text: nil)
				case .backgroundColor: cellBackgroundColor.setColor(color: nil)
				case .backgroundImage: cellPhotoPickerBackground.setImage(image: nil)
					if let path = tag.imagePath {
						tag.backgroundImage = nil
					}
				default: break
				}
			case .title:
				switch CellTitle.for(indexPath, type: sheet.type) {
				case .some(.fontFamily): cellTitleFontFamily.setValue(value: nil, id: nil)
				case .some(.backgroundColor): cellTitleBackgroundColor.setColor(color: nil)
				case .some(.textColor): cellTitleTextColor.setColor(color: nil)
				case .some(.borderColor): cellTitleBorderColor.setColor(color: nil)
				default: break
				}
			case .content:
				switch CellLyrics.for(indexPath, type: sheet.type) {
				case .some(.fontFamily): cellLyricsFontFamily.setValue(value: nil, id: nil)
				case .some(.textColor): cellLyricsTextColor.setColor(color: nil)
				case .some(.borderColor): cellLyricsBorderColor.setColor(color: nil)
				default: break
				}
			case .image:
				switch CellImage.for(indexPath, type: sheet.type) {
				case .some(.image): cellImagePicker.setImage(image: nil)
					if let sheet = sheet as? SheetTitleImageEntity, let path = sheet.imagePath {
						sheet.image = nil
					}
				case .some(.borderColor): cellImageBorderColor.setColor(color: nil)
				case .some(.contentMode): cellImageContentMode.setValue(value: nil, id: nil)
				default: break
				}
			}
		}
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch Section.for(indexPath.section, type: sheet.type) {
		case .general:
			switch CellGeneral.for(indexPath, type: sheet.type) {
			case .asTag:
				let cell = cellAsTag
				cell.isActive = !cell.isActive
				reloadDataWithScrollTo(cell)
			case .content:
				let cell = cellContent
				cell.isActive = !cell.isActive
				reloadDataWithScrollTo(cell)
			case .textLeft:
				let cell = cellTextLeft
				cell.isActive = !cell.isActive
				reloadDataWithScrollTo(cell)
			case .textRight:
				let cell = cellTextRight
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
			switch CellTitle.for(indexPath, type: sheet.type) {
			case .some(.fontFamily):
				let cell = cellTitleFontFamily
				cell.isActive = !cell.isActive
				reloadDataWithScrollTo(cell)
			case .some(.alignment):
				let cell = cellTitleAlignment
				cell.isActive = !cell.isActive
				reloadDataWithScrollTo(cell)
			case .some(.textColor):
				let cell = cellTitleTextColor
				cell.isActive = !cell.isActive
				reloadDataWithScrollTo(cell)
			case .some(.backgroundColor):
				let cell = cellTitleBackgroundColor
				cell.isActive = !cell.isActive
				reloadDataWithScrollTo(cell)
			case .some(.borderColor):
				let cell = cellTitleBorderColor
				cell.isActive = !cell.isActive
				reloadDataWithScrollTo(cell)
			default:
				break
			}
		case .content:
			switch CellLyrics.for(indexPath, type: sheet.type) {
			case .some(.fontFamily):
				let cell = cellLyricsFontFamily
				cell.isActive = !cell.isActive
				reloadDataWithScrollTo(cell)
			case .some(.alignment):
				let cell = cellLyricslAlignment
				cell.isActive = !cell.isActive
				reloadDataWithScrollTo(cell)
			case .some(.textColor):
				let cell = cellLyricsTextColor
				cell.isActive = !cell.isActive
				reloadDataWithScrollTo(cell)
			case .some(.borderColor):
				let cell = cellLyricsBorderColor
				cell.isActive = !cell.isActive
				reloadDataWithScrollTo(cell)
			default:
				break
			}
		case .image:
			switch CellImage.for(indexPath, type: sheet.type) {
			case .some(.image):
				let cell = cellImagePicker
				cell.isActive = !cell.isActive
				reloadDataWithScrollTo(cell)
			case .some(.borderColor):
				let cell = cellImageBorderColor
				cell.isActive = !cell.isActive
				reloadDataWithScrollTo(cell)
			case .some(.contentMode):
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
			tag.title = text
			sheet.title = text
		}
		buildPreview(isSetup: isSetup)
	}
	
	func textViewDidChange(cell: LabelTextView, textView: UITextView) {
		if cell.id == "cellContent" {
			if let sheet = sheet as? SheetTitleImageEntity {
				sheet.content = textView.text
			} else if let sheet = sheet as? SheetTitleContentEntity {
				sheet.lyrics = textView.text
			}
		} else if cell.id == "cellTextLeft", let sheet = sheet as? SheetSplitEntity {
			sheet.textLeft = textView.text
		} else if cell.id == "cellTextRight",  let sheet = sheet as? SheetSplitEntity {
			sheet.textRight = textView.text
		}
		buildPreview(isSetup: isSetup)
	}
	
	func textViewDidResign(cell: LabelTextView, textView: UITextView) {
		if cell.id == "cellContent" {
			if let sheet = sheet as? SheetTitleImageEntity {
				sheet.content = textView.text
			} else if let sheet = sheet as? SheetTitleContentEntity {
				sheet.lyrics = textView.text
			}
		} else if cell.id == "cellTextLeft", let sheet = sheet as? SheetSplitEntity {
			sheet.textLeft = textView.text
		} else if cell.id == "cellTextRight",  let sheet = sheet as? SheetSplitEntity {
			sheet.textRight = textView.text
		}

		tableView.beginUpdates()
		tableView.endUpdates()
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
		if cell.id == "cellImageContentMode", let sheet = sheet as? SheetTitleImageEntity {
			sheet.imageContentMode = Int16(item.0)
		}
		buildPreview(isSetup: isSetup)
		tableView.beginUpdates()
		tableView.endUpdates()
	}
	
	func didSelectSwitch(first: Bool?, second: Bool?, cell: LabelDoubleSwitchCell) {
		if cell.id == "cellHasEmptySheet" {
			if let first = first {
				tag.hasEmptySheet = first
				let cell = cellHasEmptySheet
				reloadDataWithScrollTo(cell)
			}
			if let second = second {
				tag.isEmptySheetFirst = second
			}
		}
		if !isSetup  {
			cell.isActive = !cell.isActive
		}
		reloadDataWithScrollTo(cell)
		buildPreview(isSetup: isSetup)
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
		if cell.id == "cellImageBorderSize", let sheet = sheet as? SheetTitleImageEntity {
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
		
		if cell.id == "cellImageBorderColor", let sheet = sheet as? SheetTitleImageEntity {
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
			if let sheet = sheet as? SheetTitleImageEntity {
				sheet.imageHasBorder = uiSwitch.isOn
				
				if !uiSwitch.isOn {
					sheet.imageHasBorder = uiSwitch.isOn
					cellImageBorderSize.setValue(value: 0)
					cellImageBorderColor.setColor(color: nil)
				}
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
			tag.backgroundImage = image
			tableView.beginUpdates()
			tableView.endUpdates()
			tableView.reloadData()
			buildPreview(isSetup: isSetup)
		}
		if cell.id == "cellImagePicker", let sheet = sheet as? SheetTitleImageEntity {
			if !isSetup {
				cell.isActive = !cell.isActive
			}
			sheet.image = image
			tableView.beginUpdates()
			tableView.endUpdates()
			tableView.reloadData()
			buildPreview(isSetup: isSetup)
		}
	}
	
	
	
	// MARK: - Private Functions
	
	private func setup() {
		
		if sheet == nil {
			sheet = CoreSheetTitleContent.createEntity()
		}
		
		if editTagMode {
			
		} else if let tag = sheet.hasTag  {
			self.tag = tag
		} else {
			tag = CoreTag.createEntity()
			tag.isHidden = newTagMode // this tag will not show up in the tag list for users
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
		
		cellName.setup()
		cellName.delegate = self
		cellAsTag.delegate = self
		cellContent.delegate = self
		cellTextLeft.delegate = self
		cellTextRight.delegate = self
		cellHasEmptySheet.delegate = self
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
		
		cellTitleTextColor.setColor(color: .black)
		cellLyricsTextColor.setColor(color: .black)
		cellTitleFontSize.setValue(value: 14)
		cellLyricsFontSize.setValue(value: 10)
		
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
		switch CellLyrics.for(indexPath, type: sheet.type) {
		case .some(.fontFamily): return cellLyricsFontFamily
		case .some(.fontSize): return cellLyricsFontSize
		case .some(.alignment): return cellLyricslAlignment
		case .some(.textColor): return cellLyricsTextColor
		case .some(.borderSize): return cellLyricsBorderSize
		case .some(.borderColor): return cellLyricsBorderColor
		case .some(.bold): return cellLyricsBold
		case .some(.italic): return cellLyricsItalic
		case .some(.underlined): return cellLyricsUnderLined
		case .none: return UITableViewCell()
		}
	}
	
	private func getGeneralCellFor(indexPath: IndexPath) -> UITableViewCell {
		switch CellGeneral.for(indexPath, type: sheet.type) {
		case .name: return cellName
		case .content: return cellContent
		case .textLeft: return cellTextLeft
		case .textRight: return cellTextRight
		case .asTag: return cellAsTag
		case .hasEmptySheet: return cellHasEmptySheet
		case .allHaveTitle: return cellAllHaveTitlle
		case .backgroundColor: return cellBackgroundColor
		case .backgroundImage: return cellPhotoPickerBackground
		}
	}
	
	private func getImageCellFor(indexPath: IndexPath) -> UITableViewCell {
		switch CellImage.for(indexPath, type: sheet.type) {
		case .some(.image): return cellImagePicker
		case .some(.hasBorder): return cellImageHasBorder
		case .some(.borderSize): return cellImageBorderSize
		case .some(.borderColor): return cellImageBorderColor
		case .some(.contentMode): return cellImageContentMode
		case .none: return UITableViewCell()
		}
	}
	
	private func loadTagAttributes(_ tag: Tag) {
		isSetup = true
		
		if editExtistingSheet || editTagMode {
			cellName.setName(name: sheet.title ?? "")
		}
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
		
		// GENERAL ATTRIBUTES
		cellName.setName(name: sheet.title ?? "")

		if newTagMode || editTagMode {
			cellName.setName(name: tag.title ?? "")
			sheet.title = Text.NewTag.sampleTitle
		} else {
			cellName.setName(name: sheet.title ?? "")
		}
		
		switch sheet.type {
		case .SheetTitleContent:
			if let sheet = sheet as? SheetTitleContentEntity {
				if !editExtistingSheet {
					sheet.lyrics = Text.NewTag.sampleLyrics
				} else {
					cellContent.set(text: sheet.lyrics ?? "")
				}
			}
		case .SheetTitleImage:
			if let sheet = sheet as? SheetTitleImageEntity {
				if !editExtistingSheet {
					cellContent.set(text: Text.NewTag.sampleLyrics)
				} else {
					cellContent.set(text: sheet.content ?? "")
					cellImagePicker.setImage(image: sheet.image)
					cellImageHasBorder.setSwitchValueTo(value: sheet.imageHasBorder)
					cellImageBorderSize.setValue(value: Int(sheet.imageBorderSize))
					if let color = sheet.imageBorderColor {
						cellImageBorderColor.setColor(color: UIColor(hex: color))
					}
					cellImageContentMode.setValue(value: nil, id: sheet.imageContentMode)
				}
			}
		case .SheetSplit:
			if let sheet = sheet as? SheetSplitEntity {
				if !editExtistingSheet {
					cellTextLeft.set(text: Text.NewTag.sampleLyrics)
					cellTextRight.set(text: Text.NewTag.sampleLyrics)
				} else {
					cellTextLeft.set(text: sheet.textLeft ?? "")
					cellTextRight.set(text: sheet.textRight ?? "")
				}
			}
		default:
			break
		}
		isSetup = false
	}
	
	private func buildPreview(isSetup: Bool) {
		if !isSetup {
			
			for subview in previewView.subviews {
				subview.removeFromSuperview()
			}
			
			generateTag()

			var newPreviewView = UIView()
			
			switch sheet.type {
			case .SheetTitleContent:
				if let sheet = sheet as? SheetTitleContentEntity {
					newPreviewView = SheetTitleContent.createWith(frame: previewView.bounds, title: sheet.title, sheet: sheet, tag: tag)
					if externalDisplayWindow != nil {
						_ = SheetTitleContent.createWith(frame: previewView.bounds, title: sheet.title, sheet: sheet, tag: tag, scaleFactor: externalDisplayWindowWidth / previewView.bounds.width).toExternalDisplay()
					}
				}
			case .SheetTitleImage:
				if let sheet = sheet as? SheetTitleImageEntity {
					newPreviewView = SheetTitleImage.createWith(frame: previewView.bounds, sheet: sheet, tag: tag)
					if externalDisplayWindow != nil {
						_ = SheetTitleImage.createWith(frame: previewView.bounds, sheet: sheet, tag: tag, scaleFactor: externalDisplayWindowWidth / previewView.bounds.width).toExternalDisplay()
					}
				}
			case .SheetSplit:
				if let sheet = sheet as? SheetSplitEntity {
					newPreviewView = SheetSplit.createWith(frame: previewView.bounds, sheet: sheet, tag: tag)
					if externalDisplayWindow != nil {
						_ = SheetSplit.createWith(frame: previewView.bounds, sheet: sheet, tag: tag, scaleFactor: externalDisplayWindowWidth / previewView.bounds.width).toExternalDisplay()
					}
				}
			case .SheetEmpty:
				newPreviewView = SheetEmpty.createWith(frame: previewView.bounds, tag: tag)
				if externalDisplayWindow != nil {
					_ = SheetEmpty.createWith(frame: previewView.bounds, tag: tag, scaleFactor: externalDisplayWindowWidth / previewView.bounds.width).toExternalDisplay()
				}
			}
			
			previewView.addSubview(newPreviewView)
			

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
			tag.backgroundImage = image
		} else {
			if let path = tag.imagePath {
				tag.backgroundImage = nil
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
		
		if !editExtistingSheet && !editTagMode {
			if tag.imagePath != nil {
				tag.backgroundImage = nil
			}
			
			let _ = CoreTag.delete(entity: tag) // delete temp tag
			
			if let sheet = sheet as? SheetTitleImageEntity, let path = sheet.imagePath {
				sheet.image = nil
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
			
			if let image = cellImagePicker.pickedImage, let sheet = sheet as? SheetTitleImageEntity {
				sheet.image = image
			}
			
			// if new or edit tag, don't save preview sheet and isHidden is false (show tag in list)
			if newTagMode || editTagMode {
				sheet = nil
				tag.isHidden = false
			} else {
				sheet.hasTag = tag
				tag.isHidden = true
			}
			let _ = CoreTag.saveContext()
//			let _ = CoreSheetTitleImage.saveContext()
			
			delegate?.didCreate(sheet: sheet)
			dismiss(animated: true)
			
		}
		
	}
}

