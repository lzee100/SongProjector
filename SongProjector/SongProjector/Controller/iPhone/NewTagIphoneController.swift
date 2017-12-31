//
//  NewTagIphoneController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 28-12-17.
//  Copyright © 2017 iozee. All rights reserved.
//

import UIKit
import ChromaColorPicker

class NewTagIphoneController: UIViewController, UITableViewDelegate, UITableViewDataSource, LabelTextFieldCellDelegate, LabelPickerCellDelegate, LabelNumerCellDelegate, LabelColorPickerCellDelegate, LabelSwitchCellDelegate, LabelPhotoPickerCellDelegate {
	
	
	@IBOutlet var cancel: UIBarButtonItem!
	@IBOutlet var save: UIBarButtonItem!
	@IBOutlet var titlePreview: UILabel!
	@IBOutlet var lyricsPreview: UITextView!
	@IBOutlet var imageBackground: UIImageView!
	@IBOutlet var titleHeightConstraint: NSLayoutConstraint!
	
	@IBOutlet var tableView: UITableView!
	
	enum Section: String {
		case Name
		case Titel
		case Inhoud
		case Achtergrond
		
		static let all = [Name, Titel, Inhoud, Achtergrond]
		
		static func `for`(_ section: Int) -> Section {
			return all[section]
		}
	}
	
	enum Cell: String {
		case fontFamily
		case fontSize
		case borderSize
		case textColor
		case borderColor
		case bold
		case italic
		case underlined
		
		static let all = [fontFamily, fontSize, borderSize, textColor, borderColor, bold, italic, underlined]
		
		static func `for`(_ indexPath: IndexPath) -> Cell {
			return all[indexPath.row]
		}
	}
	
	let cellName = LabelTextFieldCell.create(id: "cellName", description: Text.NewTag.descriptionTitle, placeholder: Text.NewTag.descriptionTitlePlaceholder)
	
	let cellTitelFontFamily = LabelPickerCell.create(id: "titleFontFamily", description: Text.NewTag.fontFamilyDescription, initialFontName: UIFont.systemFont(ofSize: 12).fontName)
	let cellTitelFontSize = LabelNumberCell.create(id: "titleFontSize", description: Text.NewTag.fontSizeDescription, initialValue: 17)
	let cellTitelBorderSize = LabelNumberCell.create(id: "titleBorderSize", description: Text.NewTag.borderSizeDescription, initialValue: 0, positive: false)
	let cellTitelTextColor = LabelColorPickerCell.create(id: "cellTitelTextColor", description: Text.NewTag.textColor)
	let cellTitelBorderColor = LabelColorPickerCell.create(id: "cellTitelBorderColor", description: Text.NewTag.borderColor)
	let cellTitelBold = LabelSwitchCell.create(id: "cellTitelBold", description: Text.NewTag.bold)
	let cellTitelItalic = LabelSwitchCell.create(id: "cellTitelItalic", description: Text.NewTag.italic)
	let cellTitelUnderLined = LabelSwitchCell.create(id: "cellTitelUnderlined", description: Text.NewTag.underlined)
	
	let cellLyricsFontFamily = LabelPickerCell.create(id: "lyricsFontFamily", description: Text.NewTag.fontFamilyDescription, initialFontName: UIFont.systemFont(ofSize: 12).fontName)
	let cellLyricsFontSize = LabelNumberCell.create(id: "lyricsFontSize", description: Text.NewTag.fontSizeDescription, initialValue: 17)
	let cellLyricsBorderSize = LabelNumberCell.create(id: "lyricsBorderSize", description: Text.NewTag.borderSizeDescription, initialValue: 0, positive: false)
	let cellLyricsTextColor = LabelColorPickerCell.create(id: "cellLyricsTextColor", description: Text.NewTag.textColor)
	let cellLyricsBorderColor = LabelColorPickerCell.create(id: "cellLyricsBorderColor", description: Text.NewTag.borderColor)
	let cellLyricsBold = LabelSwitchCell.create(id: "cellLyricsBold", description: Text.NewTag.bold)
	let cellLyricsItalic = LabelSwitchCell.create(id: "cellLyricsItalic", description: Text.NewTag.italic)
	let cellLyricsUnderLined = LabelSwitchCell.create(id: "cellLyricsUnderlined", description: Text.NewTag.underlined)
	
	var cellPhotoPicker = LabelPhotoPickerCell()
	
	var editExistingTag: Tag?
	var tagName = ""
	var titleAttributes: [NSAttributedStringKey : Any] = [:]
	var lyricsAttributes: [NSAttributedStringKey: Any] = [:]
	var titleAttributedText: NSAttributedString?
	
	var titleFontNameIsSet = false
	var lyricsFontNameIsSet = false
	
    override func viewDidLoad() {
        super.viewDidLoad()

		setup()
    }
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return Section.all.count
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch Section.for(section) {
		case .Name:
			return 1
		case .Titel:
			return Cell.all.count
		case .Inhoud:
			return Cell.all.count
		case .Achtergrond:
			return 1
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch Section.for(indexPath.section) {
		case .Name:
			return cellName
		case .Titel:
			return getTitelCellFor(indexPath: indexPath)
		case .Inhoud:
			return getLyricsCellFor(indexPath: indexPath)
		case .Achtergrond:
			return cellPhotoPicker
		}
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		switch Section.for(indexPath.section) {
		case .Name:
			return 60
		case .Titel:
			switch Cell.for(indexPath) {
			case .fontFamily: return cellTitelFontFamily.preferredHeight
			case .fontSize: return cellTitelFontSize.preferredHeight
			case .textColor: return cellTitelTextColor.preferredHeight
			case .borderSize: return cellTitelBorderSize.preferredHeight
			case .borderColor: return cellTitelBorderColor.preferredHeight
			default:
				return 60
			}
		case .Inhoud:
			switch Cell.for(indexPath) {
			case .fontFamily: return cellLyricsFontFamily.preferredHeight
			case .fontSize: return cellLyricsFontSize.preferredHeight
			case .textColor: return cellLyricsTextColor.preferredHeight
			case .borderSize: return cellLyricsBorderSize.preferredHeight
			case .borderColor: return cellLyricsBorderColor.preferredHeight
			default:
				return 60
			}
		case .Achtergrond:
			return cellPhotoPicker.preferredHeight
		}
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 60
	}
	
	func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
		return 60
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch Section.for(section) {
		case .Name:
			return Text.NewTag.sectionGeneral.capitalized
		case .Titel:
			return Text.NewTag.sectionTitle.capitalized
		case .Inhoud:
			return Text.NewTag.sectionLyrics.capitalized
		case .Achtergrond:
			return Text.NewTag.sectionBackground.capitalized
		}
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch Section.for(indexPath.section) {
		case .Name:
			break
		case .Titel:
			switch Cell.for(indexPath) {
			case .fontFamily:
				let cell = cellTitelFontFamily
				cell.isActive = !cell.isActive
				reloadDataWithScrollTo(cell)
			case .textColor:
				let cell = cellTitelTextColor
				cell.isActive = !cell.isActive
				reloadDataWithScrollTo(cell)
			case .borderColor:
				let cell = cellTitelBorderColor
				cell.isActive = !cell.isActive
				reloadDataWithScrollTo(cell)
			default:
				break
			}
		case .Inhoud:
			switch Cell.for(indexPath) {
			case .fontFamily:
				let cell = cellLyricsFontFamily
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
		case .Achtergrond:
			let cell = cellPhotoPicker
			cell.isActive = !cell.isActive
			reloadDataWithScrollTo(cell)
		}
	}
	
	
	// MARK: - Delegate functions
	
	func textFieldDidChange(cell: LabelTextFieldCell ,text: String?) {
		if let text = text {
			tagName = text
		}
	}
	
	func didSelectFontWith(name: String, cell: LabelPickerCell) {
		if cell.id == "titleFontFamily" {
			var size: CGFloat = 17
			if let font = titleAttributes[.font] as? UIFont {
				size = font.pointSize
			}
			titleAttributes[.font] = UIFont(name: name, size: size)
			buildPreview()
			if titleFontNameIsSet {
			cell.isActive = !cell.isActive
			} else {
				titleFontNameIsSet = true
			}
			tableView.beginUpdates()
			tableView.endUpdates()
		}
		if cell.id == "lyricsFontFamily" {
			var size: CGFloat = 17
			if let font = lyricsAttributes[.font] as? UIFont {
				size = font.pointSize
			}
			lyricsAttributes[.font] = UIFont(name: name, size: size)
			buildPreview()
			if lyricsFontNameIsSet {
				cell.isActive = !cell.isActive
			} else {
				lyricsFontNameIsSet = true
			}
			tableView.beginUpdates()
			tableView.endUpdates()
		}
	}

	
	func numberChangedForCell(cell: LabelNumberCell) {
		
		if cell.id == "titleFontSize" {
			if let family = titleAttributes[.font] as? UIFont {
				titleAttributes[.font] = UIFont(name: family.fontName, size: CGFloat(cell.value))
			} else {
				titleAttributes[.font] = UIFont(name: UIFont.systemFont(ofSize: 1).fontName, size: CGFloat(cell.value))
			}
			buildPreview()
		}
		if cell.id == "titleBorderSize" {
			titleAttributes[.strokeWidth] = cell.value
			buildPreview()
		}
		
		if cell.id == "lyricsFontSize"{
			if let family = lyricsAttributes[.font] as? UIFont {
				lyricsAttributes[.font] = UIFont(name: family.fontName, size: CGFloat(cell.value))
			} else {
				lyricsAttributes[.font] = UIFont(name: UIFont.systemFont(ofSize: 1).fontName, size: CGFloat(cell.value))
			}
			buildPreview()
		}
		if cell.id == "lyricsBorderSize" {
			lyricsAttributes[.strokeWidth] = cell.value
			buildPreview()
		}
		
	}
	
	func colorPickerDidChooseColor(cell: LabelColorPickerCell, colorPicker: ChromaColorPicker, color: UIColor) {
		if cell.id == "cellTitelTextColor" {
			titleAttributes[.foregroundColor] = color
			titleAttributes[.underlineColor] = color
			buildPreview()

			tableView.beginUpdates()
			tableView.endUpdates()
			// TODO: iets met opslaan kleur??
		} else if cell.id == "cellTitelBorderColor" {
			titleAttributes[.strokeColor] = color
			buildPreview()
			
			tableView.beginUpdates()
			tableView.endUpdates()
		}
		
		if cell.id == "cellLyricsTextColor" {
			lyricsAttributes[.foregroundColor] = color
			lyricsAttributes[.underlineColor] = color
			buildPreview()
			
			tableView.beginUpdates()
			tableView.endUpdates()
			// TODO: iets met opslaan kleur??
		} else if cell.id == "cellLyricsBorderColor" {
			lyricsAttributes[.strokeColor] = color
			buildPreview()
			
			tableView.beginUpdates()
			tableView.endUpdates()
		}
		
	}
	
	func valueChangedFor(cell: LabelSwitchCell, uiSwitch: UISwitch) {
		switch cell.id {
		case "cellTitelBold":
			if let font = titleAttributes[.font] as? UIFont {
				if uiSwitch.isOn {
					titleAttributes[.font] = font.setBoldFnc()
				} else {
					titleAttributes[.font] = font.detBoldFnc()
				}
				buildPreview()
			}
		case "cellTitelItalic":
			if let font = titleAttributes[.font] as? UIFont {
				if uiSwitch.isOn {
					titleAttributes[.font] = font.setItalicFnc()
				} else {
					titleAttributes[.font] = font.detItalicFnc()
				}
			}
			buildPreview()
		case "cellTitelUnderlined":
				if uiSwitch.isOn {
					titleAttributes[.underlineStyle] = NSUnderlineStyle.styleSingle.rawValue
				} else {
					titleAttributes.removeValue(forKey: .underlineStyle)
				}
			buildPreview()
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
				buildPreview()
			}
		case "cellLyricsItalic":
			if let font = lyricsAttributes[.font] as? UIFont {
				if uiSwitch.isOn {
					lyricsAttributes[.font] = font.setItalicFnc()
				} else {
					lyricsAttributes[.font] = font.detItalicFnc()
				}
			}
			buildPreview()
		case "cellLyricsUnderlined":
			if uiSwitch.isOn {
				lyricsAttributes[.underlineStyle] = NSUnderlineStyle.styleSingle.rawValue
			} else {
				lyricsAttributes.removeValue(forKey: .underlineStyle)
			}
			buildPreview()
		default:
			break
		}

	}
	
	func didSelectImage(cell: LabelPhotoPickerCell) {
		cell.isActive = !cell.isActive
		tableView.beginUpdates()
		tableView.endUpdates()
		tableView.reloadData()
		buildPreview()
	}

	private func setup() {
		
		tableView.register(cell: Cells.labelNumberCell)
		tableView.register(cell: Cells.LabelPickerCell)
		tableView.register(cell: Cells.LabelSwitchCell)
		tableView.register(cell: Cells.labelTextFieldCell)
		tableView.register(cell: Cells.LabelPhotoPickerCell)
		
		cellPhotoPicker = LabelPhotoPickerCell.create(id: "cellPhotoPicker", description: Text.NewTag.backgroundImage, sender: self)
		cellPhotoPicker.setup()

		
		cellName.setup()
		cellName.delegate = self
		cellTitelFontFamily.delegate = self
		cellTitelFontSize.delegate = self
		cellTitelBorderSize.delegate = self
		cellTitelBorderColor.delegate = self
		cellTitelTextColor.delegate = self
		cellTitelBold.delegate = self
		cellTitelItalic.delegate = self
		cellTitelUnderLined.delegate = self
		cellLyricsFontFamily.delegate = self
		cellLyricsFontSize.delegate = self
		cellLyricsBorderSize.delegate = self
		cellLyricsBorderColor.delegate = self
		cellLyricsTextColor.delegate = self
		cellLyricsBold.delegate = self
		cellLyricsItalic.delegate = self
		cellLyricsUnderLined.delegate = self
		cellPhotoPicker.delegate = self
		
		if let tag = editExistingTag {
			
			
			
			cellName.setName(name: tag.title ?? "")
			cellTitelFontFamily.setFontName(value: tag.titleFontName ?? "")
			cellTitelFontSize.setValue(value: Int(tag.titleTextSize))
			cellTitelBorderSize.setValue(value: Int(tag.titleBorderSize))
			cellTitelBorderColor.setColor(color: tag.borderColorTitle ?? .black)
			cellTitelTextColor.setColor(color: tag.textColorTitle ?? .black)
			cellTitelBold.setSwitchValueTo(value: tag.isTitleBold)
			cellTitelItalic.setSwitchValueTo(value: tag.isTitleItalian)
			cellTitelUnderLined.setSwitchValueTo(value: tag.isTitleUnderlined)
			
			cellLyricsFontFamily.setFontName(value: tag.lyricsFontName ?? "")
			cellLyricsFontSize.setValue(value: Int(tag.lyricsTextSize))
			cellLyricsBorderSize.setValue(value: Int(tag.lyricsBorderSize))
			cellLyricsBorderColor.setColor(color: tag.borderColorLyrics ?? .black)
			cellLyricsTextColor.setColor(color: tag.textColorLyrics ?? .black)
			cellLyricsBold.setSwitchValueTo(value: tag.isLyricsBold)
			cellLyricsItalic.setSwitchValueTo(value: tag.isLyricsItalian)
			cellLyricsUnderLined.setSwitchValueTo(value: tag.isLyricsUnderlined)
			if let image = tag.backgroundImage {
				cellPhotoPicker.setImage(image: image)
			}
		}
		
		cancel.title = Text.Actions.cancel
		save.title = Text.Actions.save
		
		let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
		tap.cancelsTouchesInView = false
		view.addGestureRecognizer(tap)
		
		buildPreview()
	}
	
	private func reloadDataWithScrollTo(_ cell: UITableViewCell) {
		tableView.reloadData()
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
			self.tableView.scrollRectToVisible(cell.frame, animated: true)
		}
	}

	
	private func getTitelCellFor(indexPath: IndexPath) -> UITableViewCell {
		switch Cell.for(indexPath) {
		case .fontFamily: return cellTitelFontFamily
		case .fontSize: return cellTitelFontSize
		case .textColor: return cellTitelTextColor
		case .borderSize: return cellTitelBorderSize
		case .borderColor: return cellTitelBorderColor
		case .bold: return cellTitelBold
		case .italic: return cellTitelItalic
		case .underlined: return cellTitelUnderLined
		}
	}
	
	private func getLyricsCellFor(indexPath: IndexPath) -> UITableViewCell {
		switch Cell.for(indexPath) {
		case .fontFamily: return cellLyricsFontFamily
		case .fontSize: return cellLyricsFontSize
		case .textColor: return cellLyricsTextColor
		case .borderSize: return cellLyricsBorderSize
		case .borderColor: return cellLyricsBorderColor
		case .bold: return cellLyricsBold
		case .italic: return cellLyricsItalic
		case .underlined: return cellLyricsUnderLined
		}
	}
	
	private func buildPreview() {
		let attText = NSAttributedString(string: Text.NewTag.sampleTitel, attributes: titleAttributes)
		titlePreview.attributedText = attText
		
		let attLyrics = NSAttributedString(string: Text.NewTag.sampleLyrics, attributes: lyricsAttributes)
		lyricsPreview.attributedText = attLyrics
		
		if let font = titleAttributes[.font] as? UIFont {
			titleHeightConstraint.constant = font.pointSize
		}
		
		if let image = cellPhotoPicker.pickedImage {
			let scaledImage = UIImage.scaleImageToSize(image: image, size: imageBackground.frame.size)
			imageBackground.image = scaledImage
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
			if let titleBorderSize = titleAttributes[.strokeWidth] as? Int {
				tag.titleBorderSize = Int16(titleBorderSize)
			}
			if let titleColor = titleAttributes[.foregroundColor] as? UIColor {
				tag.textColorTitle = titleColor
			}
			if let titleStrokeColor = titleAttributes[.strokeColor] as? UIColor {
				tag.borderColorTitle = titleStrokeColor
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
			}
			if let lyricsColor = lyricsAttributes[.foregroundColor] as? UIColor {
				tag.textColorLyrics = lyricsColor
			}
			if let lyricsStrokeColor = lyricsAttributes[.strokeColor] as? UIColor {
				tag.borderColorLyrics = lyricsStrokeColor
			}
			if let _ = lyricsAttributes[.underlineStyle] as? Int {
				tag.isLyricsUnderlined = true
			} else {
				tag.isLyricsUnderlined = false
			}
			
			if let image = cellPhotoPicker.pickedImage {
				tag.imagePath = saveImage(image: image, tag: tag)
			}
			
			CoreTag.saveContext()
			//		if editExistingTag != nil {
			//			navigationController?.popViewController(animated: true)
			//		} else {
			dismiss(animated: true)
			//		}
		}
	}
	
	@objc func dismissKeyboard() {
		view.endEditing(true)
	}
	
	@IBAction func cancelPressed(_ sender: UIBarButtonItem) {
		dismiss(animated: true)
	}
	
	
}
