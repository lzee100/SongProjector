//
//  LabelPickerCell.swift
//  SongProjector
//
//  Created by Leo van der Zee on 29-12-17.
//  Copyright © 2017 iozee. All rights reserved.
//

import UIKit

protocol LabelPickerCellDelegate {
	func didSelect(item: (Int64, String), cell: LabelPickerCell)
}

class LabelPickerCell: ChurchBeamCell, TagImplementation, DynamicHeightCell, SheetImplementation, UIPickerViewDataSource, UIPickerViewDelegate {
	
	
	@IBOutlet var descriptionTitel: UILabel!
	@IBOutlet var fontLabel: UILabel!
	@IBOutlet var pickerHolder: UIView!
	
	var preferredHeight: CGFloat {
		return isActive ? 360 : 60
	}
	
	var sheet: Sheet?
	var sheetAttribute: SheetAttribute? {
		didSet {
			if let sheetAttribute = sheetAttribute {
				switch sheetAttribute {
				case .SheetImageContentMode: setupImageAspect()
				default:
					break
				}
			}
		}
	}
	
	var id: String = ""
	var isActive = false { didSet { updatePicker() } }
	var delegate: LabelPickerCellDelegate?
	var pickerValues: [(Int64, String)] = []
	var picker = UIPickerView()
	var selectedIndex: Int = 0
	
	var sheetTag: Tag?
	var tagAttribute: TagAttribute?
	var valueDidChange: ((ChurchBeamCell) -> Void)?
	
	static let identifier = "LabelPickerCell"
	
	override func awakeFromNib() {
		picker = UIPickerView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
		picker.dataSource = self
		picker.delegate = self
		pickerHolder.backgroundColor = themeWhiteBlackBackground
	}
	
	static func create(id: String, description: String, initialValueName: String, pickerValues: [(Int64, String)]) -> LabelPickerCell {
		let view : LabelPickerCell! = UIView.create(nib: "LabelPickerCell")
		view.id = id
		view.descriptionTitel.text = description
		view.fontLabel.text = initialValueName
		view.picker = UIPickerView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
		view.picker.dataSource = view
		view.picker.delegate = view
		view.pickerHolder.backgroundColor = themeWhiteBlackBackground
		view.pickerValues = pickerValues
		return view
	}
		
	func setValue(value: String? = nil, id: Int16? = nil) {
		if let value = value, let index = pickerValues.index(where: { (item) -> Bool in item.1 == value }) {
			pickerView(picker, didSelectRow: index, inComponent: 0)
		} else if let id = id, let index = pickerValues.index(where: { (value) -> Bool in value.0 == id }) {
			pickerView(picker, didSelectRow: index, inComponent: 0)
		} else {
			pickerView(picker, didSelectRow: 0, inComponent: 0)
		}
	}
	
	private func updatePicker() {
		if isActive {
			pickerHolder.isHidden = false
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
				self.pickerHolder.addSubview(self.picker)
			})
		} else {
			pickerHolder.isHidden = true
			picker.removeFromSuperview()
		}
	}
	
	func apply(tag: Tag, tagAttribute: TagAttribute) {
		
		switch tagAttribute {
		case .asTag: setupAsTag()
		case .titleFontName, .lyricsFontName: setupFonts()
		case .titleAlignment, .lyricsAlignment: setupFontAlignment()
		default:
			break
		}
		
		self.sheetTag = tag
		self.tagAttribute = tagAttribute
		self.descriptionTitel.text = tagAttribute.description
		applyValueToCell()
	}
	
	func apply(sheet: Sheet, sheetAttribute: SheetAttribute) {
		self.sheet = sheet
		self.sheetAttribute = sheetAttribute
		setupImageAspect()
		applyValueToCell()
	}
	
	func applyValueToCell() {
		if let tagAttribute = tagAttribute, let tag = sheetTag {
			switch tagAttribute {
			case .lyricsFontName: fontLabel.text = tag.lyricsFontName
			case .titleFontName: fontLabel.text = tag.titleFontName
			case .titleAlignment: fontLabel.text = pickerValues[Int(tag.titleAlignmentNumber)].1
			case .lyricsAlignment: fontLabel.text = pickerValues[Int(tag.lyricsAlignmentNumber)].1
			case .asTag: fontLabel.text = ""
			default: return
			}
		}
		if let sheet = sheet as? SheetTitleImageEntity {
			fontLabel.text = dutchContentMode()[Int(sheet.imageContentMode)]
		}
	}
	
	func applyCellValueToTag() {
		if let tagAttribute = tagAttribute, let tag = sheetTag {
			switch tagAttribute {
			case .lyricsFontName: tag.lyricsFontName = fontLabel.text
			case .titleFontName: tag.titleFontName = fontLabel.text
			case .titleAlignment: tag.titleAlignmentNumber = Int16(selectedIndex)
			case .lyricsAlignment: tag.lyricsAlignmentNumber = Int16(selectedIndex)
			default: return
			}
		}
		if let sheet = sheet as? SheetTitleImageEntity {
			sheet.imageContentMode = Int16(selectedIndex)
		}
	}
	
	func set(value: Any?) {
		guard value != nil else {
			return
		}
		if let value = value as? String {
			fontLabel.text = value
		}
	}
	
	public func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return pickerValues[row].1
	}
	
	func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
		let title = pickerValues[row].1
		let myTitle = NSAttributedString(string: title, attributes: [ .foregroundColor : themeWhiteBlackTextColor ])
		return myTitle
	}
	
	
	public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return pickerValues.count
	}
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		
		let value = pickerValues[row]
		fontLabel.text = value.1
		selectedIndex = row
		applyCellValueToTag()
		valueDidChange?(self)
		delegate?.didSelect(item: value, cell: self)
	}
	
	
	
	
	private func setupAsTag() {
		CoreTag.setSortDescriptor(attributeName: "title", ascending: true)
		CoreTag.predicates.append("isHidden", notEquals: true)
		let tags = CoreTag.getEntities().map{ ($0.id, $0.title ?? "") }
		pickerValues = tags
	}
	
	private func setupFonts() {
		let fontFamilyValues = UIFont.familyNames.map{ (Int64(0), $0) }.sorted { $0.1 < $1.1 }
		pickerValues = fontFamilyValues
	}
	
	private func setupImageAspect() {
		var modeValues: [(Int64, String)] = []
		for (index, mode) in dutchContentMode().enumerated() {
			modeValues.append((Int64(index), mode))
		}
		pickerValues = modeValues
		set(value: dutchContentMode()[2])
	}
	
	private func setupFontAlignment() {
		pickerValues = [(Int64(0), Text.NewTag.alignLeft), (Int64(1), Text.NewTag.alignCenter), (Int64(2), Text.NewTag.alignRight)]
		set(value: Text.NewTag.alignLeft)
	}
	
	private func dutchContentMode() -> [String] {
		
		return ["vul, maar verlies verhouding", "vul maar behoud verhouding", "vul alles", "vullen", "midden", "boven", "onder", "links", "rechts", "links boven", "rechts boven", "links onder", "rechts onder"]
		
	}
	
}
