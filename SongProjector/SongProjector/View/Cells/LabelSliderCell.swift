//
//  LabelSliderCell.swift
//  SongProjector
//
//  Created by Leo van der Zee on 18-03-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import UIKit

protocol LabelSliderDelegate {
	func sliderValueChanged(cell: LabelSliderCell, value: Float)
}

class LabelSliderCell: UITableViewCell {

	@IBOutlet var descriptionTitle: UILabel!
	@IBOutlet var percentagePreview: UILabel!
	@IBOutlet var viewBeforeSlider: UIView!
	@IBOutlet var slider: UISlider!

	@IBOutlet var sliderTopConstraint: NSLayoutConstraint!
	
	var preferredHeight : CGFloat {
		return isActive ? 120 : 60
	}
	
	var id = ""
	var isActive = false { didSet { setupTextView() } }
	var textView = UITextView()
	var customText = ""
	var delegate: LabelSliderDelegate?
	
	static func create(id: String, description: String, initialValue: Float) -> LabelSliderCell {
		let view : LabelSliderCell! = UIView.create(nib: "LabelSliderCell")
		view.id = id
		view.descriptionTitle.text = description
		view.slider.minimumValue = 0
		view.slider.maximumValue = 100
		view.slider.value = initialValue
		view.slider.tintColor = themeHighlighted
		view.descriptionTitle.textColor = themeWhiteBlackTextColor
		view.percentagePreview.textColor = themeWhiteBlackTextColor
		view.viewBeforeSlider.backgroundColor = themeWhiteBlackBackground
		return view
	}
	
	func setup() {
		slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
	}
	
	private func setupTextView() {
		if isActive {
			self.sliderTopConstraint.constant = (120 / 2) + (self.slider.frame.height / 2)
			UIView.animate(withDuration: 0.2, animations: {
				self.layoutIfNeeded()
			})
		} else {
			self.sliderTopConstraint.constant = 15
			UIView.animate(withDuration: 0.2, animations: {
				self.layoutIfNeeded()
			})
		}
	}
	
	func set(sliderValue: Float?) {
		if let sliderValue = sliderValue {
			setPreviewWith(value: sliderValue)
			slider.setValue(sliderValue, animated: false)
			delegate?.sliderValueChanged(cell: self, value: sliderValue)
		}
	}
	
	private func setPreviewWith(value: Float) {
		percentagePreview.text = String(100-Int(value)) + "%"
	}
	
	@objc private func sliderValueChanged() {
		set(sliderValue: slider.value)
	}
	
	
	override func setSelected(_ selected: Bool, animated: Bool) {
		
	}
	
	override func setHighlighted(_ highlighted: Bool, animated: Bool) {
		
	}
	
}
