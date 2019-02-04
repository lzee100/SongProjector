//
//  LabelTextViewCell.swift
//  SongProjector
//
//  Created by Leo van der Zee on 16-01-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import UIKit

protocol LabelTextViewDelegate {
	func textViewDidChange(cell: LabelTextViewCell, textView: UITextView)
	func textViewDidResign(cell: LabelTextViewCell, textView: UITextView)
}

class LabelTextViewCell: ChurchBeamCell, DynamicHeightCell, SheetImplementation, UITextViewDelegate {
	
	
	@IBOutlet var descriptionTitle: UILabel!
	@IBOutlet var previewTextField: UITextField!
	@IBOutlet var textViewContainer: UIView!
	
	var preferredHeight : CGFloat {
		return isActive ? 260 : 60
	}
	
	var id = ""
	var isActive = false { didSet { setupTextView() } }
	var textView = UITextView()
	var customText = ""
	var sheetAttribute: SheetAttribute?
	var sheet: Sheet?
	var valueDidChange: ((ChurchBeamCell) -> Void)?
	
	static let identifier = "LabelTextViewCell"
	
	override func awakeFromNib() {
		previewTextField.isEnabled = false
		textViewContainer.isHidden = true
		textViewContainer.backgroundColor = themeWhiteBlackBackground
		textView.delegate = self
		descriptionTitle.text = description
	}

	static func create(id: String, description: String, placeholder: String) -> LabelTextViewCell {
		let view : LabelTextViewCell! = UIView.create(nib: "LabelTextViewCell")
		view.id = id
		view.previewTextField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedStringKey.foregroundColor: UIColor.placeholderColor])
		view.previewTextField.isEnabled = false
		view.textViewContainer.isHidden = true
		view.textViewContainer.backgroundColor = themeWhiteBlackBackground
		view.textView.delegate = view
		view.descriptionTitle.text = description
		return view
	}
	
	var delegate: LabelTextViewDelegate?
	
	func set(placeholder: String) {
		previewTextField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedStringKey.foregroundColor: UIColor.placeholderColor])
	}

	private func setupTextView() {
		if isActive {
			previewTextField.isHidden = true
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
				self.textView = UITextView(frame: self.textViewContainer.bounds)
				self.textView.delegate = self
				if let font = UIFont (name: "Avenir", size: 16) {
					self.textView.attributedText = NSAttributedString(string: self.customText, attributes: [NSAttributedStringKey.font : font])
				}
				self.textViewContainer.addSubview(self.textView)
				self.textViewContainer.isHidden = false
				self.textViewContainer.alpha = 0.0
				UIView.animate(withDuration: 0.2, animations: {
					self.textViewContainer.alpha = 1
					self.setNeedsLayout()
				})
			})
		} else {
			previewTextField.isHidden = false
			textViewContainer.isHidden = true
			textView.removeFromSuperview()
		}
	}
	
	func apply(sheet: Sheet, sheetAttribute: SheetAttribute) {
		self.sheet = sheet
		self.sheetAttribute = sheetAttribute
		self.descriptionTitle.text = sheetAttribute.description
		
		switch sheetAttribute {
		case .SheetContent, .SheetContentLeft:
			if let sheet = sheet as? SheetSplitEntity {
				set(text: sheet.textLeft)
			} else if let sheet = sheet as? SheetTitleContentEntity {
				set(text: sheet.content)
			} else if let sheet = sheet as? SheetTitleImageEntity {
				set(text: sheet.content)
			}else if let sheet = sheet as? SheetPastorsEntity {
				set(text: sheet.content)
			}
		case .SheetContentRight:
			if let sheet = sheet as? SheetSplitEntity {
				set(text: sheet.textRight)
			}
		default:
			break
		}
	}
	
	func set(text: String?) {
		customText = text ?? ""
		textView.text = text
		previewTextField.text = text
		delegate?.textViewDidResign(cell: self, textView: textView)
	}
	
	public func textViewDidChange(_ textView: UITextView) {
		customText = textView.text
		
		if let sheet = sheet as? SheetTitleContentEntity {
			sheet.content = textView.text
		} else if let sheet = sheet as? SheetTitleImageEntity {
			sheet.content = textView.text
		} else if let sheet = sheet as? SheetPastorsEntity {
			sheet.content = textView.text
		}
		
		valueDidChange?(self)
		delegate?.textViewDidChange(cell: self, textView: textView)
	}
	
}
