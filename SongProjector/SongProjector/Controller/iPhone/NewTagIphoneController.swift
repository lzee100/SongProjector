//
//  NewTagIphoneController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 28-12-17.
//  Copyright © 2017 iozee. All rights reserved.
//

import UIKit
import ChromaColorPicker

class NewTagIphoneController: UIViewController, UITableViewDelegate, UITableViewDataSource, LabelTextFieldCellDelegate, LabelPickerCellDelegate, LabelDoubleSwitchDelegate, LabelNumerCellDelegate, LabelColorPickerCellDelegate, LabelSwitchCellDelegate, LabelPhotoPickerCellDelegate {
	
	
	
	// MARK: - IBoutlets
	@IBOutlet var cancel: UIBarButtonItem!
	@IBOutlet var save: UIBarButtonItem!
	@IBOutlet var sheetContainerView: UIView!
	@IBOutlet var sheetPreview: UIView!
	@IBOutlet var titlePreview: UILabel!
	@IBOutlet var titleBackground: UIView!
	@IBOutlet var lyricsPreview: UITextView!
	@IBOutlet var imageBackground: UIImageView!
	@IBOutlet var titleHeightConstraint: NSLayoutConstraint!
	
	@IBOutlet var sheetContainerHeightConstraint: NSLayoutConstraint!
	@IBOutlet var sheetPreviewAspectRatio: NSLayoutConstraint!
	@IBOutlet var tableView: UITableView!
	
	
	// MARK: - Types
	
	enum Section: String {
		case general
		case title
		case content
		
		static let all = [general, title, content]
		
		static func `for`(_ section: Int) -> Section {
			return all[section]
		}
	}
	
	enum CellGeneral: String {
		case name
		case asTag
		case emptySheet
		case backgroundColor
		case backgroundImage
		
		static let all = [name, asTag, emptySheet, backgroundColor, backgroundImage]
		
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
	
	// MARK: - Properties
	// MARK: General Cells
	
	let cellName = LabelTextFieldCell.create(id: "cellName", description: Text.NewTag.descriptionTitle, placeholder: Text.NewTag.descriptionTitlePlaceholder)
	var cellAsTag = LabelPickerCell()
	var cellPhotoPicker = LabelPhotoPickerCell()
	var cellBackgroundColor = LabelColorPickerCell.create(id: "cellBackgroundColor", description: Text.NewTag.descriptionBackgroundColor)
	var cellHasEmptySheet = LabelDoubleSwitchCell.create(id: "cellHasEmptySheet", descriptionSwitchOne: Text.NewTag.descriptionHasEmptySheet, descriptionSwitchTwo: Text.NewTag.descriptionPositionEmptySheet)
	
	
	// MARK: Title Cells
	
	var cellTitleFontFamily = LabelPickerCell()
	let cellTitleFontSize = LabelNumberCell.create(id: "cellTitleFontSize", description: Text.NewTag.fontSizeDescription, initialValue: 17)
	let cellTitleAlignment = LabelPickerCell.create(id: "cellTitleFontAlignment", description: Text.NewTag.descriptionAlignment, initialValueName: Text.NewTag.alignLeft, pickerValues: [(Int64(0), Text.NewTag.alignLeft), (Int64(0), Text.NewTag.alignCenter), (Int64(0), Text.NewTag.alignRight)])
	let cellTitleBorderSize = LabelNumberCell.create(id: "cellTitleBorderSize", description: Text.NewTag.borderSizeDescription, initialValue: 0, positive: false)
	let cellTitleTextColor = LabelColorPickerCell.create(id: "cellTitleTextColor", description: Text.NewTag.textColor)
	let cellTitleBackgroundColor = LabelColorPickerCell.create(id: "cellTitleBackgroundColor", description: Text.NewTag.descriptionTitleBackgroundColor)
	let cellTitleBorderColor = LabelColorPickerCell.create(id: "cellTitleBorderColor", description: Text.NewTag.borderColor)
	let cellTitleBold = LabelSwitchCell.create(id: "cellTitleBold", description: Text.NewTag.bold)
	let cellTitleItalic = LabelSwitchCell.create(id: "cellTitleItalic", description: Text.NewTag.italic)
	let cellTitleUnderLined = LabelSwitchCell.create(id: "cellTitleUnderlined", description: Text.NewTag.underlined)
	
	
	// MARK: Lyrics Cells
	
	var cellLyricsFontFamily = LabelPickerCell()
	let cellLyricsFontSize = LabelNumberCell.create(id: "cellLyricsFontSize", description: Text.NewTag.fontSizeDescription, initialValue: 17)
	let cellLyricslAlignment = LabelPickerCell.create(id: "cellLyricsFontAlignment", description: Text.NewTag.descriptionAlignment, initialValueName: "Left", pickerValues: [(Int64(0), Text.NewTag.alignLeft), (Int64(0), Text.NewTag.alignCenter), (Int64(0), Text.NewTag.alignRight)])
	let cellLyricsBorderSize = LabelNumberCell.create(id: "cellLyricsBorderSize", description: Text.NewTag.borderSizeDescription, initialValue: 0, positive: false)
	let cellLyricsTextColor = LabelColorPickerCell.create(id: "cellLyricsTextColor", description: Text.NewTag.textColor)
	let cellLyricsBorderColor = LabelColorPickerCell.create(id: "cellLyricsBorderColor", description: Text.NewTag.borderColor)
	let cellLyricsBold = LabelSwitchCell.create(id: "cellLyricsBold", description: Text.NewTag.bold)
	let cellLyricsItalic = LabelSwitchCell.create(id: "cellLyricsItalic", description: Text.NewTag.italic)
	let cellLyricsUnderLined = LabelSwitchCell.create(id: "cellLyricsUnderlined", description: Text.NewTag.underlined)

	
	var editExistingTag: Tag?
	var tagName = ""
	var titleBackgroundColor: UIColor?
	var sheetBackgroundColor: UIColor?
	var hasEmptySheet: Bool = false
	var isEmptySheetIsFirst: Bool = false
	var isSetup = true
	var titleAttributes: [NSAttributedStringKey : Any] = [:]
	var lyricsAttributes: [NSAttributedStringKey: Any] = [:]
	var titleAttributedText: NSAttributedString?
	
	
	
	
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
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch Section.for(indexPath.section) {
		case .general:
			return getGeneralCellFor(indexPath: indexPath)
		case .title:
			return getTitleCellFor(indexPath: indexPath)
		case .content:
			return getLyricsCellFor(indexPath: indexPath)
		}
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		switch Section.for(indexPath.section) {
		case .general:
			switch CellGeneral.for(indexPath) {
			case .asTag : return cellAsTag.preferredHeight
			case .backgroundColor: return cellBackgroundColor.preferredHeight
			case .backgroundImage: return cellPhotoPicker.preferredHeight
			case .emptySheet : return cellHasEmptySheet.preferredHeight
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
		}
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 80
	}
	
	func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
		return 60
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch Section.for(section) {
		case .general:
			return Text.NewTag.sectionGeneral.capitalized
		case .title:
			return Text.NewTag.sectionTitle.capitalized
		case .content:
			return Text.NewTag.sectionLyrics.capitalized
		}
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
		}
		return view
	}
	
	func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
		switch Section.for(indexPath.section) {
		case .general:
			switch CellGeneral.for(indexPath) {
			case .backgroundColor:
				return .delete
			case .backgroundImage:
				return .delete
			default:
				return .none
			}
		case .title:
			switch CellTitle.for(indexPath) {
			case .backgroundColor:
				return .delete
			case .textColor:
				return .delete
			case .borderColor:
				return .delete
			default:
				return .none
			}
		case .content:
			switch CellLyrics.for(indexPath) {
			case .textColor:
				return .delete
			case .borderColor:
				return .delete
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
				case .backgroundColor:
					cellBackgroundColor.setColor(color: nil)
				case .backgroundImage:
					cellPhotoPicker.setImage(image: nil)
				default:
					break
				}
			case .title:
				switch CellTitle.for(indexPath) {
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
				case .textColor:
					cellLyricsTextColor.setColor(color: nil)
				case .borderColor:
					cellLyricsBorderColor.setColor(color: nil)
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
				let cell = cellPhotoPicker
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
		}
	}
	
	
	// MARK: - Delegate functions
	
	func textFieldDidChange(cell: LabelTextFieldCell ,text: String?) {
		if let text = text {
			tagName = text
		}
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
			tableView.beginUpdates()
			tableView.endUpdates()
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
			tableView.beginUpdates()
			tableView.endUpdates()
		}
		if cell.id == "cellAsTag" {
			CoreTag.predicates.append("id", equals: item.0)
			editExistingTag = CoreTag.getEntities().first
			loadTagAttributes()
			editExistingTag = nil
			cellName.setName(name: "")
			if !isSetup {
				cell.isActive = !cell.isActive
			}
			tableView.beginUpdates()
			tableView.endUpdates()
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
			buildPreview(isSetup: isSetup)
			tableView.beginUpdates()
			tableView.endUpdates()
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
			buildPreview(isSetup: isSetup)
			tableView.beginUpdates()
			tableView.endUpdates()
		}
	}
	
	func didSelectSwitch(first: Bool?, second: Bool?, cell: LabelDoubleSwitchCell) {
		if cell.id == "cellHasEmptySheet" {
			if let first = first {
				hasEmptySheet = first
				let cell = cellHasEmptySheet
				reloadDataWithScrollTo(cell)
			}
			if let second = second {
				isEmptySheetIsFirst = second
			}
		}
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
			buildPreview(isSetup: isSetup)
		}
		
		if cell.id == "cellLyricsFontSize"{
			if let family = lyricsAttributes[.font] as? UIFont {
				lyricsAttributes[.font] = UIFont(name: family.fontName, size: CGFloat(cell.value))
			} else {
				lyricsAttributes[.font] = UIFont(name: UIFont.systemFont(ofSize: 1).fontName, size: CGFloat(cell.value))
			}
			buildPreview(isSetup: isSetup)
		}
		if cell.id == "cellLyricsBorderSize" {
			lyricsAttributes[.strokeWidth] = cell.value
			buildPreview(isSetup: isSetup)
		}
		
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
			buildPreview(isSetup: isSetup)
			tableView.beginUpdates()
			tableView.endUpdates()
		} else if cell.id == "cellTitleBorderColor" {
			if let color = color {
				titleAttributes[.strokeColor] = color
			} else {
				cellTitleBorderSize.setValue(value: 0)
				titleAttributes.removeValue(forKey: .strokeColor)
			}
			buildPreview(isSetup: isSetup)
			tableView.beginUpdates()
			tableView.endUpdates()
		} else if cell.id == "cellTitleBackgroundColor" {
			if let color = color {
				titlePreview.backgroundColor = color
				titleBackgroundColor = color
			} else {
				titlePreview.backgroundColor = .clear
				titleBackgroundColor = nil
			}
			buildPreview(isSetup: isSetup)
			tableView.beginUpdates()
			tableView.endUpdates()
		}
		
		if cell.id == "cellLyricsTextColor" {
			if let color = color {
				lyricsAttributes[.foregroundColor] = color
				lyricsAttributes[.underlineColor] = color
			} else {
				lyricsAttributes[.foregroundColor] = UIColor.black
				lyricsAttributes[.underlineColor] = UIColor.black
			}
			buildPreview(isSetup: isSetup)
			
			tableView.beginUpdates()
			tableView.endUpdates()
		} else if cell.id == "cellLyricsBorderColor" {
			if let color = color {
				lyricsAttributes[.strokeColor] = color
			} else {
				cellLyricsBorderSize.setValue(value: 0)
				lyricsAttributes.removeValue(forKey: .strokeColor)
			}
			buildPreview(isSetup: isSetup)
			
			tableView.beginUpdates()
			tableView.endUpdates()
		}
		if cell.id == "cellBackgroundColor" {
			if let color = color {
				sheetBackgroundColor = color
			} else {
				sheetBackgroundColor = .white
			}
			buildPreview(isSetup: isSetup)
			tableView.beginUpdates()
			tableView.endUpdates()
		}
		
	}
	
	func valueChangedFor(cell: LabelSwitchCell, uiSwitch: UISwitch) {
		switch cell.id {
		case "cellTitleBold":
			if let font = titleAttributes[.font] as? UIFont {
				if uiSwitch.isOn {
					titleAttributes[.font] = font.setBoldFnc()
				} else {
					titleAttributes[.font] = font.detBoldFnc()
				}
				buildPreview(isSetup: isSetup)
			}
		case "cellTitleItalic":
			if let font = titleAttributes[.font] as? UIFont {
				if uiSwitch.isOn {
					titleAttributes[.font] = font.setItalicFnc()
				} else {
					titleAttributes[.font] = font.detItalicFnc()
				}
			}
			buildPreview(isSetup: isSetup)
		case "cellTitleUnderlined":
				if uiSwitch.isOn {
					titleAttributes[.underlineStyle] = NSUnderlineStyle.styleSingle.rawValue
				} else {
					titleAttributes.removeValue(forKey: .underlineStyle)
				}
			buildPreview(isSetup: isSetup)
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
				buildPreview(isSetup: isSetup)
			}
		case "cellLyricsItalic":
			if let font = lyricsAttributes[.font] as? UIFont {
				if uiSwitch.isOn {
					lyricsAttributes[.font] = font.setItalicFnc()
				} else {
					lyricsAttributes[.font] = font.detItalicFnc()
				}
			}
			buildPreview(isSetup: isSetup)
		case "cellLyricsUnderlined":
			if uiSwitch.isOn {
				lyricsAttributes[.underlineStyle] = NSUnderlineStyle.styleSingle.rawValue
			} else {
				lyricsAttributes.removeValue(forKey: .underlineStyle)
			}
			buildPreview(isSetup: isSetup)
		default:
			break
		}
	}
	
	func didSelectImage(cell: LabelPhotoPickerCell) {
		if !isSetup {
			cell.isActive = !cell.isActive
		}
		tableView.beginUpdates()
		tableView.endUpdates()
		tableView.reloadData()
		buildPreview(isSetup: isSetup)
	}
	
	
	// MARK: - Private Functions

	private func setup() {
		
		NotificationCenter.default.addObserver(forName: NotificationNames.externalDisplayDidChange, object: nil, queue: nil, using: externalDisplayDidChange)

		tableView.register(cell: Cells.labelNumberCell)
		tableView.register(cell: Cells.LabelPickerCell)
		tableView.register(cell: Cells.LabelSwitchCell)
		tableView.register(cell: Cells.labelTextFieldCell)
		tableView.register(cell: Cells.LabelPhotoPickerCell)
		
		sheetContainerHeightConstraint.isActive = false
		
		refineSheetRatio()
		
		let fontFamilyValues = UIFont.familyNames.map{ (Int64(0), $0) }.sorted { $0.1 < $1.1 }
		cellTitleFontFamily = LabelPickerCell.create(id: "cellTitleFontFamily", description: Text.NewTag.fontFamilyDescription, initialValueName: "Avenir", pickerValues: fontFamilyValues)
		cellLyricsFontFamily = LabelPickerCell.create(id: "cellLyricsFontFamily", description: Text.NewTag.fontFamilyDescription, initialValueName: "Avenir", pickerValues: fontFamilyValues)
		
		CoreTag.setSortDescriptor(attributeName: "title", ascending: true)
		let tags = CoreTag.getEntities().map{ ($0.id, $0.title!) }
		cellAsTag = LabelPickerCell.create(id: "cellAsTag", description: Text.NewTag.descriptionAsTag, initialValueName: "", pickerValues: tags)
		
		cellPhotoPicker = LabelPhotoPickerCell.create(id: "cellPhotoPicker", description: Text.NewTag.backgroundImage, sender: self)
		cellPhotoPicker.setup()
		
		
		titleAttributes[.font] = UIFont(name: "Avenir", size: 17)
		cellTitleTextColor.setColor(color: .black)
		lyricsAttributes[.font] = UIFont(name: "Avenir", size: 17)
		cellLyricsTextColor.setColor(color: .black)

		
		cellAsTag.delegate = self
		cellName.setup()
		cellName.delegate = self
		cellPhotoPicker.delegate = self
		cellBackgroundColor.delegate = self
		cellHasEmptySheet.delegate = self
		
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

		
		loadTagAttributes()
		
		cancel.title = Text.Actions.cancel
		save.title = Text.Actions.save
		
		let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
		tap.cancelsTouchesInView = false
		view.addGestureRecognizer(tap)
		
		isSetup = false
		buildPreview(isSetup: isSetup)
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
		case .asTag: return cellAsTag
		case .backgroundColor: return cellBackgroundColor
		case .backgroundImage: return cellPhotoPicker
		case .emptySheet: return cellHasEmptySheet
		}
	}
	
	private func loadTagAttributes() {
		if let tag = editExistingTag {
			cellName.setName(name: tag.title ?? "")
			cellTitleFontFamily.setValue(value: tag.titleFontName ?? "")
			cellTitleFontSize.setValue(value: Int(tag.titleTextSize))
			cellTitleAlignment.setValue(value: tag.titleAlignment, id: nil)
			cellTitleBorderSize.setValue(value: Int(tag.titleBorderSize))
			cellTitleBorderColor.setColor(color: tag.borderColorTitle)
			cellTitleTextColor.setColor(color: tag.textColorTitle)
			cellTitleBold.setSwitchValueTo(value: tag.isTitleBold)
			cellTitleItalic.setSwitchValueTo(value: tag.isTitleItalian)
			cellTitleUnderLined.setSwitchValueTo(value: tag.isTitleUnderlined)
		
			cellLyricsFontFamily.setValue(value: tag.lyricsFontName ?? "")
			cellLyricsFontSize.setValue(value: Int(tag.lyricsTextSize))
			cellLyricslAlignment.setValue(value: tag.lyricsAlignment, id: nil)
			cellLyricsBorderSize.setValue(value: Int(tag.lyricsBorderSize))
			cellLyricsBorderColor.setColor(color: tag.borderColorLyrics)
			cellLyricsTextColor.setColor(color: tag.textColorLyrics)
			cellLyricsBold.setSwitchValueTo(value: tag.isLyricsBold)
			cellLyricsItalic.setSwitchValueTo(value: tag.isLyricsItalian)
			cellLyricsUnderLined.setSwitchValueTo(value: tag.isLyricsUnderlined)
			cellHasEmptySheet.setSwitches(first: tag.hasEmptySheet, second: tag.isEmptySheetFirst)

			if let backgroundColorTitle = tag.backgroundColorTitle {
				titleBackgroundColor = backgroundColorTitle
				cellTitleBackgroundColor.setColor(color: backgroundColorTitle)
			}
			
			if let sheetBackgroundColor = tag.sheetBackgroundColor {
				self.sheetBackgroundColor = sheetBackgroundColor
				cellBackgroundColor.setColor(color: sheetBackgroundColor)
			}
			
			cellPhotoPicker.setImage(image: tag.backgroundImage)
			
			buildPreview(isSetup: false)
			
		}
	}
	
	private func buildPreview(isSetup: Bool) {
		if !isSetup {
			let attText = NSAttributedString(string: Text.NewTag.sampleTitle, attributes: titleAttributes)
			titlePreview.attributedText = attText
			
			let attLyrics = NSAttributedString(string: Text.NewTag.sampleLyrics, attributes: lyricsAttributes)
			lyricsPreview.attributedText = attLyrics
			
			if let font = titleAttributes[.font] as? UIFont {
				titleHeightConstraint.constant = font.pointSize
			}
			
			if let backgroundColorTitle = titleBackgroundColor {
				titleBackground.isHidden = false
				titleBackground.backgroundColor = backgroundColorTitle
			} else {
				titleBackground.isHidden = true
			}
			
			if let sheetBackgroundColor = sheetBackgroundColor {
				sheetPreview.backgroundColor = sheetBackgroundColor
			}
			
			if let image = cellPhotoPicker.pickedImage {
				let scaledImage = UIImage.scaleImageToSize(image: image, size: imageBackground.frame.size)
				imageBackground.image = scaledImage
			} else {
				imageBackground.image = nil
			}
			
			if let externalDisplayWindow = externalDisplayWindow {
				let view = SheetView(frame: externalDisplayWindow.frame)
				view.selectedTag = editExistingTag
				view.songTitle = Text.NewTag.sampleTitle
				if let titleBackgroundColor = titleBackgroundColor {
					view.titleBackground.isHidden = false
					view.titleBackground.backgroundColor = titleBackgroundColor
				} else {
					view.titleBackground.isHidden = true
				}
				if let backgroundColor = sheetBackgroundColor {
					view.backgroundColor = backgroundColor
				}
				view.lyrics = Text.NewTag.sampleLyrics
				view.scaleFactor = externalDisplayWindow.bounds.size.height / sheetPreview.frame.size.height
				view.previewTitleAttributes = titleAttributes
				view.previewLyricsAttributes = lyricsAttributes
				view.update()
				externalDisplayWindow.addSubview(view)
			}
		}
	}
	
	private func saveImage(image: UIImage, tag: Tag) -> String? {
		if let data = UIImagePNGRepresentation(image) {
			let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
			let imagePath = String(tag.id) + ".png"
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
	
	@IBAction func savePressed(_ sender: UIBarButtonItem) {
		
		if tagName == "" {
			let message = UIAlertController(title: Text.NewTag.errorTitle, message:
				Text.NewTag.errorMessage, preferredStyle: UIAlertControllerStyle.alert)
			message.addAction(UIAlertAction(title: Text.Actions.close, style: UIAlertActionStyle.default,handler: nil))
			
			self.present(message, animated: true, completion: nil)
			
		} else {
			
			let tag = editExistingTag != nil ? editExistingTag! : CoreTag.createEntity()
			
			tag.title = tagName
			
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
			
			if let image = cellPhotoPicker.pickedImage {
				tag.imagePath = saveImage(image: image, tag: tag)
			} else {
				if let path = tag.imagePath {
					if deleteImageFor(path: path) {
						tag.imagePath = nil
					}
				}
			}
			
			if let sheetBackgroundColor = sheetBackgroundColor {
				tag.sheetBackgroundColor = sheetBackgroundColor
			} else {
				tag.sheetBackgroundColor = nil
			}
			
			if let titleBackgroundColor = titleBackgroundColor {
				tag.titleBackgroundColor = titleBackgroundColor.toHex
			} else {
				tag.titleBackgroundColor = nil
			}
			
			tag.hasEmptySheet = hasEmptySheet
			
			if hasEmptySheet {
				tag.isEmptySheetFirst = isEmptySheetIsFirst
			}
			
			let _ = CoreTag.saveContext()
			dismiss(animated: true)
		}
	}
	
	@objc func dismissKeyboard() {
		view.endEditing(true)
	}
	
	@objc func externalDisplayDidChange(_ notification: Notification) {
		refineSheetRatio()
	}
	
	private func refineSheetRatio() {
		sheetPreviewAspectRatio.isActive = false
		sheetPreview.addConstraint(NSLayoutConstraint(item: sheetPreview, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: sheetPreview, attribute: NSLayoutAttribute.width, multiplier: externalDisplayWindowRatio, constant: 0))
		let constraint = NSLayoutConstraint(item: sheetContainerView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: (UIScreen.main.bounds.width - 20) * externalDisplayWindowRatio)
		sheetContainerView.addConstraint(constraint)
		buildPreview(isSetup: isSetup)
	}
	
	
	@IBAction func cancelPressed(_ sender: UIBarButtonItem) {
		if let externalDisplayWindow = externalDisplayWindow {
			let view = UIView(frame: externalDisplayWindow.frame)
			view.backgroundColor = .black
			externalDisplayWindow.addSubview(view)
		}
		dismiss(animated: true)
	}
	
	
}



