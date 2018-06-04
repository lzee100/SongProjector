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

class NewOrEditIphoneController: UIViewController, UITableViewDelegate, UITableViewDataSource, LabelTextFieldCellDelegate, LabelTextViewDelegate, LabelPickerCellDelegate, LabelDoubleSwitchDelegate, LabelNumerCellDelegate, LabelColorPickerCellDelegate, LabelSwitchCellDelegate, LabelPhotoPickerCellDelegate, LabelSliderDelegate {
	
	@IBOutlet var cancel: UIBarButtonItem!
	@IBOutlet var save: UIBarButtonItem!
	@IBOutlet var previewView: UIView!
	@IBOutlet var tableView: UITableView!
	@IBOutlet var sheetContainerView: UIView!
	@IBOutlet var sheetContainerViewHeightConstraint: NSLayoutConstraint!
	@IBOutlet var previewViewRatioConstraint: NSLayoutConstraint!
	
	
	// MARK: - Types
	
	enum ModificationMode: String {
		case newTag
		case editTag
		case newCustomSheet
		case editCustomSheet
	}
	
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
		static let activity = [general, title, content]
		
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
			case .SheetActivities:
				return activity[section]
			}
		}
	}
	
	enum CellGeneral: String {
		case name
		case content
		case asTag
		case hasEmptySheet
		case allHaveTitle
		case backgroundColor
		case backgroundImage
		case backgroundTransparency
		case displayTime
		
		static let all = [name, content, asTag, hasEmptySheet, allHaveTitle, backgroundColor, backgroundImage, backgroundTransparency, displayTime]
		
		static let tag = [name, asTag, hasEmptySheet, allHaveTitle, backgroundColor, backgroundImage, displayTime]
		static let tagTransBackground = [name, asTag, hasEmptySheet, allHaveTitle, backgroundColor, backgroundImage, backgroundTransparency, displayTime]

		static let titleContent = [name, content, asTag, backgroundColor, backgroundImage]
		static let titleImage = [name, content, asTag, backgroundColor, backgroundImage]
		static let sheetSplit = [name, asTag, backgroundColor, backgroundImage]
		static let sheetEmpty = [name, backgroundColor, backgroundImage]
		static let sheetActivities = [name, asTag, backgroundColor, backgroundImage]

		
		static func `for`(_ indexPath: IndexPath, type: SheetType, modificationMode: ModificationMode, hasImage: Bool) -> CellGeneral {
			switch type {
			case .SheetTitleContent:
				if modificationMode == .newTag || modificationMode == .editTag {
					if hasImage {
						return tagTransBackground[indexPath.row]
					} else {
						return tag[indexPath.row]
					}
				} else {
					return titleContent[indexPath.row]
				}
			case .SheetTitleImage:
				return titleImage[indexPath.row]
			case .SheetSplit:
				return sheetSplit[indexPath.row]
			case .SheetEmpty:
				return sheetEmpty[indexPath.row]
			case .SheetActivities:
				return sheetActivities[indexPath.row]
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
		static let sheetActivities = [fontFamily, borderSize, textColor, borderColor, bold, italic, underlined]

		
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
			case .SheetActivities:
				return sheetActivities[indexPath.row]
			default:
				return nil
			}
		}
	}
	
	enum CellLyrics: String {
		case textLeft
		case textRight
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
		static let sheetSplit = [textLeft, textRight, fontFamily, fontSize, alignment, borderSize, textColor, borderColor, bold, italic, underlined]
		static let sheetEmpty: [CellLyrics] = []
		static let sheetActivities = [fontFamily, borderSize, textColor, borderColor, bold, italic, underlined]
		
		static func `for`(_ indexPath: IndexPath, type: SheetType) -> CellLyrics? {
			switch  type{
			case .SheetTitleContent:
				return titleContent[indexPath.row]
			case .SheetTitleImage:
				return titleImage[indexPath.row]
			case .SheetSplit:
				return sheetSplit[indexPath.row]
			case .SheetActivities:
				return sheetActivities[indexPath.row]
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
		static let noBorder = [image, hasBorder, contentMode]
		
		static func `for`(_ indexPath: IndexPath) -> CellImage {
			return all[indexPath.row]
		}
		
		static func `for`(_ indexPath: IndexPath, type: SheetType, hasBorder: Bool) -> CellImage? {
			if type == .SheetTitleImage, hasBorder {
				return all[indexPath.row]
			} else if type == .SheetTitleImage {
				return noBorder[indexPath.row]
			} else {
				return nil
			}
		}
	}
	
	// MARK: - Properties
	// MARK: General Cells
	
	private let cellName = LabelTextFieldCell.create(id: "cellName", description: Text.NewSheetTitleImage.descriptionTitle, placeholder: Text.NewTag.descriptionTitlePlaceholder)
	private let cellContent = LabelTextView.create(id: "cellContent", description: Text.NewSheetTitleImage.descriptionContent, placeholder: Text.NewSheetTitleImage.placeholderContent)
	private var  cellAsTag = LabelPickerCell()
	private var  cellPhotoPickerBackground = LabelPhotoPickerCell()
	private var  cellBackgroundColor = LabelColorPickerCell.create(id: "cellBackgroundColor", description: Text.NewTag.descriptionBackgroundColor)
	private var  cellHasEmptySheet = LabelDoubleSwitchCell.create(id: "cellHasEmptySheet", descriptionSwitchOne: Text.NewTag.descriptionHasEmptySheet, descriptionSwitchTwo: Text.NewTag.descriptionPositionEmptySheet)
	private let cellAllHaveTitlle = LabelSwitchCell.create(id: "cellAllHaveTitle", description: Text.NewTag.descriptionAllTitle, initialValueIsOn: false)
	private let cellBackgroundTransparency = LabelSliderCell.create(id: "cellBackgroundTransparency", description: Text.NewTag.descriptionBackgroundTransparency, initialValue: 100)
	private let cellDisplayTime = LabelSwitchCell.create(id: "cellDisplayTime", description: Text.NewTag.descriptionDisplayTime)
	
	// MARK: Title Cells
	
	private var  cellTitleFontFamily = LabelPickerCell()
	private let cellTitleFontSize = LabelNumberCell.create(id: "cellTitleFontSize", description: Text.NewTag.fontSizeDescription, initialValue: 14, minLimit: 6, maxLimit: 40)
	private let cellTitleAlignment = LabelPickerCell.create(id: "cellTitleFontAlignment", description: Text.NewTag.descriptionAlignment, initialValueName: Text.NewTag.alignLeft, pickerValues: [(Int64(0), Text.NewTag.alignLeft), (Int64(0), Text.NewTag.alignCenter), (Int64(0), Text.NewTag.alignRight)])
	private let cellTitleBorderSize = LabelNumberCell.create(id: "cellTitleBorderSize", description: Text.NewTag.borderSizeDescription, initialValue: 0, positive: false, minLimit: 0, maxLimit: 10)
	private let cellTitleTextColor = LabelColorPickerCell.create(id: "cellTitleTextColor", description: Text.NewTag.textColor)
	private let cellTitleBackgroundColor = LabelColorPickerCell.create(id: "cellTitleBackgroundColor", description: Text.NewTag.descriptionTitleBackgroundColor)
	private let cellTitleBorderColor = LabelColorPickerCell.create(id: "cellTitleBorderColor", description: Text.NewTag.borderColor)
	private let cellTitleBold = LabelSwitchCell.create(id: "cellTitleBold", description: Text.NewTag.bold)
	private let cellTitleItalic = LabelSwitchCell.create(id: "cellTitleItalic", description: Text.NewTag.italic)
	private let cellTitleUnderLined = LabelSwitchCell.create(id: "cellTitleUnderlined", description: Text.NewTag.underlined)
	
	
	// MARK: Lyrics Cells
	private var cellTextLeft = LabelTextView.create(id: "cellTextLeft", description: Text.NewSheetTitleImage.descriptionTextLeft, placeholder: Text.NewSheetTitleImage.descriptionTextLeft)
	private var cellTextRight = LabelTextView.create(id: "cellTextRight", description: Text.NewSheetTitleImage.descriptionTextRight, placeholder: Text.NewSheetTitleImage.descriptionTextRight)
	private var  cellLyricsFontFamily = LabelPickerCell()
	private let cellLyricsFontSize = LabelNumberCell.create(id: "cellLyricsFontSize", description: Text.NewTag.fontSizeDescription, initialValue: 10, minLimit: 6, maxLimit: 40)
	private let cellLyricslAlignment = LabelPickerCell.create(id: "cellLyricsFontAlignment", description: Text.NewTag.descriptionAlignment, initialValueName: "Left", pickerValues: [(Int64(0), Text.NewTag.alignLeft), (Int64(0), Text.NewTag.alignCenter), (Int64(0), Text.NewTag.alignRight)])
	private let cellLyricsBorderSize = LabelNumberCell.create(id: "cellLyricsBorderSize", description: Text.NewTag.borderSizeDescription, initialValue: 0, positive: false, minLimit: 0, maxLimit: 10)
	private let cellLyricsTextColor = LabelColorPickerCell.create(id: "cellLyricsTextColor", description: Text.NewTag.textColor)
	private let cellLyricsBorderColor = LabelColorPickerCell.create(id: "cellLyricsBorderColor", description: Text.NewTag.borderColor)
	private let cellLyricsBold = LabelSwitchCell.create(id: "cellLyricsBold", description: Text.NewTag.bold)
	private let cellLyricsItalic = LabelSwitchCell.create(id: "cellLyricsItalic", description: Text.NewTag.italic)
	private let cellLyricsUnderLined = LabelSwitchCell.create(id: "cellLyricsUnderlined", description: Text.NewTag.underlined)
	
	private var  cellImagePicker = LabelPhotoPickerCell()
	private let cellImageHasBorder = LabelSwitchCell.create(id: "cellImageHasBorder", description: Text.NewSheetTitleImage.descriptionImageHasBorder)
	private let cellImageBorderSize = LabelNumberCell.create(id: "cellImageBorderSize", description: Text.NewSheetTitleImage.descriptionImageBorderSize, initialValue: 0, minLimit: 0, maxLimit: 10)
	private let cellImageBorderColor = LabelColorPickerCell.create(id: "cellImageBorderColor", description: Text.NewSheetTitleImage.descriptionImageBorderColor)
	private var  cellImageContentMode = LabelPickerCell()
	
	var modificationMode: ModificationMode = .newTag
	var tag: Tag! { didSet { tagTemp = TagTemp(tag: tag) }}
	var tagTemp: TagTemp!
	var sheet: Sheet!
	var delegate: NewOrEditIphoneControllerDelegate?
	private var sheetImage: UIImage?
	private var tagImage: UIImage?
	private var editTagMode: Bool { return !tag.isTemp && sheet.isTemp }
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
		case .SheetActivities:
			return Section.titleContent.count
		}
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch Section.for(section, type: sheet.type) {
		case .general:
			switch sheet.type {
			case .SheetTitleContent: return (modificationMode == .newTag || modificationMode == .editTag) ? tagImage != nil ? CellGeneral.tagTransBackground.count : CellGeneral.tag.count : CellGeneral.titleContent.count
			case .SheetTitleImage: return CellGeneral.titleImage.count
			case .SheetSplit: return CellGeneral.sheetSplit.count
			case .SheetEmpty: return CellGeneral.sheetEmpty.count
			case .SheetActivities: return CellGeneral.sheetActivities.count
			}
		case .title:
			switch sheet.type {
			case .SheetTitleContent: return CellTitle.titleContent.count
			case .SheetTitleImage: return CellTitle.titleImage.count
			case .SheetSplit: return CellTitle.sheetSplit.count
			case .SheetEmpty: return CellTitle.sheetEmpty.count
			case .SheetActivities: return CellTitle.sheetActivities.count
			}
		case .content:
			switch sheet.type {
			case .SheetTitleContent: return CellLyrics.titleContent.count
			case .SheetTitleImage: return CellLyrics.titleImage.count
			case .SheetSplit: return CellLyrics.sheetSplit.count
			case .SheetEmpty: return CellLyrics.sheetEmpty.count
			case .SheetActivities: return CellLyrics.sheetActivities.count
			}
		case .image:
			switch sheet.type {
			case .SheetTitleImage: return (sheet as! SheetTitleImageEntity).imageHasBorder ? CellImage.all.count : CellImage.noBorder.count
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
			switch CellGeneral.for(indexPath, type: sheet.type, modificationMode: modificationMode, hasImage: cellPhotoPickerBackground.pickedImage != nil) {
			case .asTag: return cellAsTag.preferredHeight
			case .content: return cellContent.preferredHeight
			case .hasEmptySheet: return cellHasEmptySheet.preferredHeight
			case .backgroundColor: return cellBackgroundColor.preferredHeight
			case .backgroundImage: return cellPhotoPickerBackground.preferredHeight
			case .backgroundTransparency: return cellBackgroundTransparency.preferredHeight
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
			case .some(.textLeft): return cellTextLeft.preferredHeight
			case .some(.textRight): return cellTextRight.preferredHeight
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
			switch CellImage.for(indexPath, type: sheet.type, hasBorder: (sheet as! SheetTitleImageEntity).imageHasBorder) {
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
			switch CellGeneral.for(indexPath, type: sheet.type, modificationMode: modificationMode, hasImage: cellPhotoPickerBackground.pickedImage != nil) {
			case .backgroundColor: return cellBackgroundColor.isActive ? .none : .delete
			case .asTag: return cellAsTag.isActive ? .none : .delete
			case .content: return .delete
			case .backgroundImage: return cellPhotoPickerBackground.isActive ? .none : cellPhotoPickerBackground.pickedImage != nil ? .delete : .none
			default: return .none
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
			case .some(.textLeft): return cellTextLeft.isActive ? .none : .delete
			case .some(.textRight): return cellTextRight.isActive ? .none: .delete
			case .some(.fontFamily): return cellLyricsFontFamily.isActive ? .none : .delete
			case .some(.textColor): return cellLyricsTextColor.isActive ? .none : .delete
			case .some(.borderColor): return cellLyricsBorderColor.isActive ? .none : .delete
			default: return .none
			}
		case .image:
			switch CellImage.for(indexPath, type: sheet.type, hasBorder: (sheet as! SheetTitleImageEntity).imageHasBorder) {
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
				switch CellGeneral.for(indexPath, type: sheet.type, modificationMode: modificationMode, hasImage: cellPhotoPickerBackground.pickedImage != nil) {
				case .asTag: cellAsTag.setValue(value: nil, id: nil)
				case .content: cellContent.set(text: nil)
				case .backgroundColor: cellBackgroundColor.setColor(color: nil)
				case .backgroundImage:
					cellPhotoPickerBackground.setImage(image: nil)
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
				case .some(.textLeft): cellTextLeft.set(text: nil)
				case .some(.textRight): cellTextRight.set(text: nil)
				case .some(.fontFamily): cellLyricsFontFamily.setValue(value: nil, id: nil)
				case .some(.textColor): cellLyricsTextColor.setColor(color: nil)
				case .some(.borderColor): cellLyricsBorderColor.setColor(color: nil)
				default: break
				}
			case .image:
				switch CellImage.for(indexPath, type: sheet.type, hasBorder: (sheet as! SheetTitleImageEntity).imageHasBorder) {
				case .some(.image):
					cellImagePicker.setImage(image: nil)
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
			switch CellGeneral.for(indexPath, type: sheet.type, modificationMode: modificationMode, hasImage: cellPhotoPickerBackground.pickedImage != nil) {
			case .asTag:
				let cell = cellAsTag
				cell.isActive = !cell.isActive
				reloadDataWithScrollTo(cell)
			case .content:
				let cell = cellContent
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
			case .backgroundTransparency:
				let cell = cellBackgroundTransparency
				cell.isActive = !cell.isActive
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
					self.reloadDataWithScrollTo(cell)
				})
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
			case .some(.textLeft):
				let cell = cellTextLeft
				cell.isActive = !cell.isActive
				reloadDataWithScrollTo(cell)
			case .some(.textRight):
				let cell = cellTextRight
				cell.isActive = !cell.isActive
				reloadDataWithScrollTo(cell)
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
			switch CellImage.for(indexPath, type: sheet.type, hasBorder: (sheet as! SheetTitleImageEntity).imageHasBorder) {
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
	
	func sliderValueChanged(cell: LabelSliderCell, value: Float) {
		if cell.id == "cellBackgroundTransparency" {
			tag.backgroundTransparency = value
		}
		changeTransparency()
	}
	
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
		case "cellDisplayTime":
			tag.displayTime = uiSwitch.isOn
			isSetup = true
			updateTime()
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
				if !uiSwitch.isOn {
					cellImageBorderSize.setValue(value: 0)
					cellImageBorderColor.setColor(color: nil)
				}
				sheet.imageHasBorder = uiSwitch.isOn
				reloadDataWithScrollTo(cellImageContentMode)
			}
		default:
			break
		}
		
		buildPreview(isSetup: isSetup)
		
	}
	
	func didSelectImage(cell: LabelPhotoPickerCell, image: UIImage?) {
		if cell.id == "cellPhotoPickerBackground" {
			if !isSetup {
				cell.isActive = !cell.isActive
			}
			tagImage = image
			tableView.reloadData()
			changeBackgroundImage()
		}
		if cell.id == "cellImagePicker" {
			if !isSetup {
				cell.isActive = !cell.isActive
			}
			sheetImage = image
			tableView.reloadData()
			changeSheetImage()
		}
	}
	
	
	
	// MARK: - Private Functions
	
	private func setup() {
		
		switch modificationMode {
		case .newCustomSheet:
			tag = CoreTag.createEntity()
			tag.title = "tag"
			tag.isHidden = true
			tag.isTemp = true
		case .newTag:
			sheet = CoreSheetTitleContent.createEntity()
			sheet.isTemp = true // remove at restart app if user quit app
			tag = CoreTag.createEntity()
			tag.title = "tag"
			tag.isHidden = true
			tag.isTemp = true
		case .editTag:
			sheet = CoreSheetTitleContent.createEntity()
			sheet.isTemp = true // remove at restart app if user quit app
		case .editCustomSheet:
			tag = sheet.hasTag
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
		cellBackgroundTransparency.setup()
		
		CoreTag.setSortDescriptor(attributeName: "title", ascending: true)
		CoreTag.predicates.append("isHidden", notEquals: true)
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
		
		cellName.delegate = self
		cellAsTag.delegate = self
		cellContent.delegate = self
		cellTextLeft.delegate = self
		cellTextRight.delegate = self
		cellAllHaveTitlle.delegate = self
		cellHasEmptySheet.delegate = self
		cellPhotoPickerBackground.delegate = self
		cellBackgroundColor.delegate = self
		cellBackgroundTransparency.delegate = self
		cellDisplayTime.delegate = self
		
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
		
		cellImageHasBorder.setSwitchValueTo(value: false)
		cellImageContentMode = LabelPickerCell.create(id: "cellImageContentMode", description: Text.NewSheetTitleImage.descriptionImageContentMode, initialValueName: dutchContentMode()[2], pickerValues: modeValues)
		cellTitleFontFamily.setValue(value: "Avenir", id: nil)
		cellLyricsFontFamily.setValue(value: "Avenir", id: nil)
		
		refineSheetRatio()
		
		if modificationMode == .newCustomSheet || modificationMode == .newTag {
			cellTitleTextColor.setColor(color: .black)
			cellLyricsTextColor.setColor(color: .black)
			cellTitleFontSize.setValue(value: 14)
			cellLyricsFontSize.setValue(value: 10)
		}
		
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
		switch CellTitle.for(indexPath, type: sheet.type) {
		case .some(.fontFamily): return cellTitleFontFamily
		case .some(.fontSize): return cellTitleFontSize
		case .some(.textColor): return cellTitleTextColor
		case .some(.backgroundColor): return cellTitleBackgroundColor
		case .some(.alignment): return cellTitleAlignment
		case .some(.borderSize): return cellTitleBorderSize
		case .some(.borderColor): return cellTitleBorderColor
		case .some(.bold): return cellTitleBold
		case .some(.italic): return cellTitleItalic
		case .some(.underlined): return cellTitleUnderLined
		case .none: return UITableViewCell()
		}
	}
	
	private func getLyricsCellFor(indexPath: IndexPath) -> UITableViewCell {
		switch CellLyrics.for(indexPath, type: sheet.type) {
		case .some(.textLeft): return cellTextLeft
		case .some(.textRight): return cellTextRight
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
		switch CellGeneral.for(indexPath, type: sheet.type, modificationMode: modificationMode, hasImage: cellPhotoPickerBackground.pickedImage != nil) {
		case .name: return cellName
		case .content: return cellContent
		case .asTag: return cellAsTag
		case .hasEmptySheet: return cellHasEmptySheet
		case .allHaveTitle: return cellAllHaveTitlle
		case .backgroundColor: return cellBackgroundColor
		case .backgroundImage: return cellPhotoPickerBackground
		case .backgroundTransparency: return cellBackgroundTransparency
		case .displayTime: return cellDisplayTime
		}
	}
	
	private func getImageCellFor(indexPath: IndexPath) -> UITableViewCell {
		switch CellImage.for(indexPath, type: sheet.type, hasBorder: (sheet as! SheetTitleImageEntity).imageHasBorder) {
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
		
		cellAllHaveTitlle.setSwitchValueTo(value: tag.allHaveTitle)
		cellHasEmptySheet.setSwitches(first: tag.hasEmptySheet, second: tag.isEmptySheetFirst)
		cellBackgroundColor.setColor(color: tag.sheetBackgroundColor)
		cellBackgroundTransparency.set(sliderValue: tag.backgroundTransparency * 100)
		cellDisplayTime.setSwitchValueTo(value: tag.displayTime)
		
		cellTitleFontFamily.setValue(value: tag.titleFontName ?? "Avenir")
		cellTitleFontSize.setValue(value: Int(tag.titleTextSize))
		cellTitleBackgroundColor.setColor(color: tag.backgroundColorTitle)
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
		
		switch modificationMode {
		case .newTag, .newCustomSheet:
			sheet.title = Text.NewTag.sampleTitle
		case .editTag:
			if let tagTitle = tag.title {
				cellName.setName(name: tagTitle)
			}
		case .editCustomSheet:
			cellName.setName(name: sheet.title ?? "")
		}
		
		switch sheet.type {
		case .SheetTitleContent:
			if let sheet = sheet as? SheetTitleContentEntity {
				if sheet.isTemp && tag.isTemp || sheet.isTemp && !tag.isTemp {
					sheet.lyrics = Text.NewTag.sampleLyrics
				} else {
					cellContent.set(text: sheet.lyrics ?? "")
				}
			}
		case .SheetTitleImage:
			if let sheet = sheet as? SheetTitleImageEntity {
				if sheet.isTemp && tag.isTemp || sheet.isTemp && !tag.isTemp {
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
				if sheet.isTemp && tag.isTemp || sheet.isTemp && !tag.isTemp {
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
					if let externalDisplayWindow = externalDisplayWindow {
						_ = SheetTitleContent.createWith(frame: externalDisplayWindow.bounds, title: sheet.title, sheet: sheet, tag: tag, scaleFactor: externalDisplayWindowWidth / previewView.bounds.width).toExternalDisplay()
					}
				}
			case .SheetTitleImage:
				if let sheet = sheet as? SheetTitleImageEntity {
					newPreviewView = SheetTitleImage.createWith(frame: previewView.bounds, sheet: sheet, tag: tag)
					if let externalDisplayWindow = externalDisplayWindow {
						_ = SheetTitleImage.createWith(frame: externalDisplayWindow.bounds, sheet: sheet, tag: tag, scaleFactor: externalDisplayWindowWidth / previewView.bounds.width).toExternalDisplay()
					}
				}
			case .SheetSplit:
				if let sheet = sheet as? SheetSplitEntity {
					newPreviewView = SheetSplit.createWith(frame: previewView.bounds, sheet: sheet, tag: tag)
					if let externalDisplayWindow = externalDisplayWindow {
						_ = SheetSplit.createWith(frame: externalDisplayWindow.bounds, sheet: sheet, tag: tag, scaleFactor: externalDisplayWindowWidth / previewView.bounds.width).toExternalDisplay()
					}
				}
			case .SheetEmpty:
				newPreviewView = SheetEmpty.createWith(frame: previewView.bounds, tag: tag)
				if let externalDisplayWindow = externalDisplayWindow {
					_ = SheetEmpty.createWith(frame: externalDisplayWindow.bounds, tag: tag, scaleFactor: externalDisplayWindowWidth / previewView.bounds.width).toExternalDisplay()
				}
			case .SheetActivities:
				if let sheet = sheet as? SheetActivities {
					newPreviewView = SheetActivitiesView.createWith(frame: previewView.bounds, sheet: sheet, tag: tag, isPreview: true)
					if let externalDisplayWindow = externalDisplayWindow {
						_ = SheetActivitiesView.createWith(frame: externalDisplayWindow.bounds, sheet: sheet, tag: tag, scaleFactor: externalDisplayWindowWidth / previewView.bounds.width, isPreview: true).toExternalDisplay()
					}
				}
			}
			
			previewView.addSubview(newPreviewView)
			changeBackgroundImage()
			changeSheetImage()
		}
	}
	
	private func changeTransparency() {
		if let view = previewView.subviews.first {
			
			generateTag(skipImage: true)
			
			if let sheet = view as? SheetTitleContent {
				sheet.changeOpacity(newValue: tag.backgroundTransparency)
			} else if let sheet = view as? SheetTitleImage {
				sheet.changeOpacity(newValue: tag.backgroundTransparency)
			} else if let sheet = view as? SheetSplit {
				sheet.changeOpacity(newValue: tag.backgroundTransparency)
			} else if let sheet = view as? SheetEmpty {
				sheet.changeOpacity(newValue: tag.backgroundTransparency)
			}
			if tag.sheetBackgroundColor != .white {
				isSetup = true
				cellBackgroundColor.setColor(color: .white)
				isSetup = false
			}
		}
	}
	
	private func changeBackgroundImage() {
		if let view = previewView.subviews.first {
			
			if let sheet = view as? SheetView {
				sheet.setBackgroundImage(image: tagImage ?? tag.backgroundImage)
				
				if let externalDisplay = externalDisplayWindow, let view = externalDisplayWindow?.subviews.first, let sheet = view as? SheetView {
					sheet.setBackgroundImage(image: tagImage ?? tag.backgroundImage)
					externalDisplay.addSubview(sheet)
				}
				self.view.setNeedsDisplay()
			}
			
		}
	}
	
	private func changeSheetImage() {
		if let view = previewView.subviews.first, let sheet = view as? SheetTitleImage {
			sheet.setSheetImage(sheetImage)
		}
	}
	
	private func updateTime() {
		if let view = previewView.subviews.first, let sheet = view as? SheetView {
			sheet.updateTime(isOn: tag.displayTime)
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
		
		
//		// Container view height ajustments
//
//		// remove previous active constraint
//		if let newHeightconstraint = newSheetContainerViewHeightConstraint {
//			sheetContainerView.removeConstraint(newHeightconstraint)
//		}
//		// deactivate standard constraint
//		sheetContainerViewHeightConstraint.isActive = false
//
//		// add new constraint
//		newSheetContainerViewHeightConstraint = NSLayoutConstraint(item: sheetContainerView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: (UIScreen.main.bounds.width - 20) * externalDisplayWindowRatio)
//		sheetContainerView.addConstraint(newSheetContainerViewHeightConstraint!)
		previewView.layoutIfNeeded()
		buildPreview(isSetup: isSetup)
		
	}
	
	private func generateTag(skipImage: Bool = false) {
		
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
		
		changeBackgroundImage()
		changeSheetImage()
		
	}
	
	private func dutchContentMode() -> [String] {
		
		return ["vul, maar verlies verhouding", "vul maar behoud verhouding", "vul alles", "vullen", "midden", "boven", "onder", "links", "rechts", "links boven", "rechts boven", "links onder", "rechts onder"]
		
	}
	
	@IBAction func cancelPressed(_ sender: UIBarButtonItem) {
		
		
		
		switch modificationMode {
			
		case .newTag, .newCustomSheet:
			tag.delete()
			sheet.delete()
			
		case .editTag:
			CoreTag.predicates.append("id", equals: tag.id)
			if let restoreCoreDataSettingsTag = CoreTag.getEntities().first {
				tag = restoreCoreDataSettingsTag
			}
			sheet.delete()
		case .editCustomSheet:
			managedObjectContext.rollback()
			
		}
		
		shutDownExternalDisplay()
		
		dismiss(animated: true)
	}
	
	@IBAction func savePressed(_ sender: UIBarButtonItem) {
		
		if sheet.title == nil || sheet.title == "" || sheet.title == Text.NewTag.sampleTitle {
			let message = UIAlertController(title: Text.NewTag.errorTitle, message:
				Text.NewTag.errorMessage, preferredStyle: UIAlertControllerStyle.alert)
			message.addAction(UIAlertAction(title: Text.Actions.close, style: UIAlertActionStyle.default,handler: nil))
			
			self.present(message, animated: true, completion: nil)
			
		} else {
			
			generateTag()
			
			if let tagImage = tagImage {
				tag.backgroundImage = tagImage
			}

			if let sheet = sheet as? SheetTitleImageEntity {
				sheet.image = sheetImage
			}
			
			switch modificationMode {
			case .newTag, .editTag:
				sheet.delete()
				tag.isHidden = false
				tag.isTemp = false
			case .newCustomSheet, .editCustomSheet:
				tag.allHaveTitle = true
				tag.hasEmptySheet = false
				sheet.isTemp = false
				sheet.hasTag = tag
				tag.isHidden = true
				tag.isTemp = false
			}

			let _ = CoreEntity.saveContext()
			
			shutDownExternalDisplay()
			
			delegate?.didCreate(sheet: sheet)
			dismiss(animated: true)
			
		}
		
	}
	
	private func shutDownExternalDisplay() {
		if let externalDisplayWindow = externalDisplayWindow {
			let view = UIView(frame: externalDisplayWindow.frame)
			view.backgroundColor = .black
			externalDisplayWindow.addSubview(view)
		}
	}
	
}

