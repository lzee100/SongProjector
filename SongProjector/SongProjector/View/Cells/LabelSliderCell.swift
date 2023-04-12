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

class LabelSliderCell: ChurchBeamCell, ThemeImplementation, DynamicHeightCell {
	
    static let identifier = "LabelSliderCell"
    
	@IBOutlet var descriptionTitle: UILabel!
	@IBOutlet var percentagePreview: UILabel!
	@IBOutlet var viewBeforeSlider: UIView!
	@IBOutlet var slider: UISlider!

	@IBOutlet var sliderTopConstraint: NSLayoutConstraint!
	
	var preferredHeight : CGFloat {
		return isActive ? 120 : 60
	}
	
	var id = ""
	
	var sheetTheme: VTheme?
	var themeAttribute: ThemeAttribute?
	var valueDidChange: ((ChurchBeamCell) -> Void)?
	
	var isActive = false { didSet { setupTextView() } }
	var textView = UITextView()
	var customText = ""
	var delegate: LabelSliderDelegate?
		
    private var cell: NewOrEditIphoneController.Cell?
    private var newDelegate: CreateEditThemeSheetCellDelegate?
    
	override func awakeFromNib() {
		slider.minimumValue = 0
		slider.maximumValue = 100
		slider.value = 100
		slider.tintColor = themeHighlighted
		descriptionTitle.textColor = .blackColor
		percentagePreview.textColor = .blackColor
        viewBeforeSlider.backgroundColor = .grey0
		setPreviewWith(value: slider.value)
		slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
	}
	static func create(id: String, description: String, initialValue: Float) -> LabelSliderCell {
		let view : LabelSliderCell! = UIView.create(nib: "LabelSliderCell")
		view.id = id
		view.descriptionTitle.text = description
		view.slider.minimumValue = 0
		view.slider.maximumValue = 100
		view.slider.value = initialValue
		view.slider.tintColor = themeHighlighted
		view.descriptionTitle.textColor = .blackColor
		view.percentagePreview.textColor = .blackColor
		view.viewBeforeSlider.backgroundColor = themeWhiteBlackBackground
		return view
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
	
	func apply(theme: VTheme, themeAttribute: ThemeAttribute) {
		self.sheetTheme = theme
		self.themeAttribute = themeAttribute
		self.descriptionTitle.text = themeAttribute.description
		applyValueToCell()
	}
	
	func applyValueToCell() {
		if let theme = sheetTheme, let themeAttribute = themeAttribute {
			switch themeAttribute {
			case .backgroundTransparancy: set(sliderValue: Float(exactly: theme.backgroundTransparancy * 100))
			default: return
			}
		}
	}
	
	func applyCellValueToTheme() {
		if let theme = sheetTheme, let themeAttribute = themeAttribute {
			switch themeAttribute {
			case .backgroundTransparancy: theme.backgroundTransparancy = Double(exactly: slider.value) ?? 0.0
			default: return
			}
		}
	}
	
	func set(value: Any?) {
		if let value = value as? Float {
			set(sliderValue: value)
		} else {
			slider.value = 0
		}
	}
	
	func set(sliderValue: Float?) {
		if let sliderValue = sliderValue {
			setPreviewWith(value: sliderValue)
			slider.setValue(sliderValue, animated: false)
		}
	}
	
	private func setPreviewWith(value: Float) {
		percentagePreview.text = String(Int(100 - value)) + "%"
	}
	
	@objc private func sliderValueChanged() {
        print(slider.value)
		set(sliderValue: slider.value)
		applyCellValueToTheme()
		valueDidChange?(self)
        newDelegate?.handle(cell: .backgroundTransparancy(Double(slider.value)))
	}
	
	override func setSelected(_ selected: Bool, animated: Bool) {
		
	}
	
	override func setHighlighted(_ highlighted: Bool, animated: Bool) {
		
	}
	
}

extension LabelSliderCell: CreateEditThemeSheetCellProtocol {
    
    func configure(cell: NewOrEditIphoneController.Cell, delegate: CreateEditThemeSheetCellDelegate) {
        self.cell = cell
        newDelegate = delegate
        descriptionTitle.text = cell.description
        switch cell {
        case .backgroundTransparancy(let value):
            set(sliderValue: Float(value))
        default: break
        }
    }
    
}
