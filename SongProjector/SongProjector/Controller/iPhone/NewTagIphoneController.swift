//
//  NewTagIphoneController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 28-12-17.
//  Copyright © 2017 iozee. All rights reserved.
//

import UIKit
import ChromaColorPicker

class NewTagIphoneController: UIViewController, UITableViewDelegate, UITableViewDataSource, TextFieldCellDelegate, LabelPickerCellDelegate, LabelNumerCellDelegate, LabelColorPickerCellDelegate, LabelSwitchCellDelegate {
	
	
	@IBOutlet var cancel: UIBarButtonItem!
	@IBOutlet var save: UIBarButtonItem!
	@IBOutlet var titlePreview: UILabel!
	@IBOutlet var lyricsPreview: UILabel!
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
	
	let cellName = LabelTextInputCell.create(placeholder: Text.NewTag.descriptionTitle)
	
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
	
	
	var titleAttributes: [NSAttributedStringKey : Any] = [:]
	var lyricsAttributes: [NSAttributedStringKey: Any] = [:]
	var titleAttributedText: NSAttributedString?
	
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
			return UITableViewCell()
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
			return 60
		}
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 60
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch Section.for(section) {
		case .Name:
			return Text.NewTag.descriptionTitle
		case .Titel:
			return Text.NewTag.sampleTitel.capitalized
		case .Inhoud:
			return Text.NewTag.sampleLyrics.capitalized
		case .Achtergrond:
			return Text.NewTag.background.capitalized
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
				tableView.beginUpdates()
				cell.isActive = !cell.isActive
				tableView.endUpdates()
			case .textColor:
				let cell = cellTitelTextColor
				tableView.beginUpdates()
				cell.isActive = !cell.isActive
				tableView.endUpdates()
			case .borderColor:
				let cell = cellTitelBorderColor
				tableView.beginUpdates()
				cell.isActive = !cell.isActive
				tableView.endUpdates()
			default:
				break
			}
		case .Inhoud:
			switch Cell.for(indexPath) {
			case .fontFamily:
				let cell = cellLyricsFontFamily
				tableView.beginUpdates()
				cell.isActive = !cell.isActive
				tableView.endUpdates()
			case .textColor:
				let cell = cellLyricsTextColor
				tableView.beginUpdates()
				cell.isActive = !cell.isActive
				tableView.endUpdates()
			case .borderColor:
				let cell = cellLyricsBorderColor
				tableView.beginUpdates()
				cell.isActive = !cell.isActive
				tableView.endUpdates()
			default:
				break
			}
		case .Achtergrond:
			break
		}
	}
	
	
	// MARK: - Delegate functions
	
	func textFieldCellShouldReturn(_ cell: TextFieldCell) -> Bool {
		return true
	}
	
	func didSelectFontWith(name: String, cell: LabelPickerCell) {
		if cell.id == "titleFontFamily", let font = titleAttributes[.font] as? UIFont {
			titleAttributes[.font] = UIFont(name: name, size: font.pointSize)
			buildPreview()
			cell.isActive = !cell.isActive
			tableView.beginUpdates()
			tableView.endUpdates()
		}
		if cell.id == "lyricsFontFamily", let font = lyricsAttributes[.font] as? UIFont {
			lyricsAttributes[.font] = UIFont(name: name, size: font.pointSize)
			buildPreview()
			cell.isActive = !cell.isActive
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


	private func setup() {
		tableView.register(cell: Cells.labelNumberCell)
		tableView.register(cell: Cells.LabelPickerCell)
		tableView.register(cell: Cells.LabelSwitchCell)
		tableView.register(cell: Cells.labelTextFieldCell)
		
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
		
		cancel.title = Text.Actions.cancel
		save.title = Text.Actions.save
		
		titlePreview.attributedText = NSAttributedString(string: Text.NewTag.sampleTitel, attributes: titleAttributes)
		lyricsPreview.attributedText = NSAttributedString(string: Text.NewTag.sampleLyrics, attributes: lyricsAttributes)
		
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
	}
	
	@IBAction func savePressed(_ sender: UIBarButtonItem) {
		
		if let name = cellName.textField.text {
			if name == "" {
				return
			}
		} else {
			return
		}
		
		let tag = CoreTag.createEntity()
		
		
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
			tag.titleTextColorHex = titleColor.hexCode
		}
		if let titleStrokeColor = titleAttributes[.strokeColor] as? UIColor {
			tag.titleBorderColorHex = titleStrokeColor.hexCode
		}
		if let _ = titleAttributes[.underlineStyle] as? String {
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
			tag.lyricsTextColorHex = lyricsColor.hexCode
		}
		if let lyricsStrokeColor = lyricsAttributes[.strokeColor] as? UIColor {
			tag.lyricsBorderColorHex = lyricsStrokeColor.hexCode
		}
		if let _ = lyricsAttributes[.underlineStyle] as? String {
			tag.isLyricsUnderlined = true
		} else {
			tag.isLyricsUnderlined = false
		}
		
	}
	
	@IBAction func cancelPressed(_ sender: UIBarButtonItem) {
		dismiss(animated: true)
	}
	
}
