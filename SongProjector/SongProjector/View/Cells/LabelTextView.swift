//
//  LabelTextView.swift
//  SongProjector
//
//  Created by Leo van der Zee on 16-01-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import UIKit

protocol LabelTextViewDelegate {
	func textViewDidChange(cell: LabelTextView, textView: UITextView)
	func textViewDidResign(cell: LabelTextView, textView: UITextView)
}

class LabelTextView: UITableViewCell, UITextViewDelegate {
	
	
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

	static func create(id: String, description: String, placeholder: String) -> LabelTextView {
		let view : LabelTextView! = UIView.create(nib: "LabelTextView")
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
	
	func set(text: String?) {
		customText = text ?? ""
		textView.text = text
		previewTextField.text = text
		delegate?.textViewDidResign(cell: self, textView: textView)
	}

	
	override func setSelected(_ selected: Bool, animated: Bool) {
		
	}
	
	override func setHighlighted(_ highlighted: Bool, animated: Bool) {
		
	}
	
	public func textViewDidChange(_ textView: UITextView) {
		customText = textView.text
		delegate?.textViewDidChange(cell: self, textView: textView)
	}
	
	func textViewDidEndEditing(_ textView: UITextView) {
		previewTextField.text = textView.text
		delegate?.textViewDidResign(cell: self, textView: textView)
	}
}
