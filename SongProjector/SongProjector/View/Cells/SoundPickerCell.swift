//
//  SoundPickerCell.swift
//  SongProjector
//
//  Created by Leo van der Zee on 15/01/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import UIKit

protocol SoundPickerCellDelegate {
	func didSelectDocumentPicker(uploadObject: InstrumentUploadObject?)
}

class SoundPickerCell: ChurchBeamCell, UIPickerViewDataSource, UIPickerViewDelegate {
	
	
	static let identifier = "SoundPickerCell"

	@IBOutlet var instrumentPicker: UIPickerView!
	@IBOutlet var selectFileButton: UIButton!
    @IBOutlet var isSelectedImageView: UIImageView!
    
	@IBOutlet var instrumentPickerHeight: NSLayoutConstraint!
		
	enum State {
		case expanded
		case collapsed
	}
	
	var allInstruments: [InstrumentType] = [.bassGuitar, .drums, .guitar, .piano, .pianoSolo]
	var uploadObject: InstrumentUploadObject?
	var cellState: State = .collapsed
	var delegate: SoundPickerCellDelegate?
		
	override func awakeFromNib() {
        super.awakeFromNib()
		instrumentPicker.dataSource = self
		instrumentPicker.delegate = self
        isSelectedImageView.tintColor = .green1
        isSelectedImageView.isHidden = true
    }
	
	func setup(_ uploadObject: InstrumentUploadObject, delegate: SoundPickerCellDelegate) {
		self.uploadObject = uploadObject
        let hasFileSelected = uploadObject.localURL != nil
        isSelectedImageView.isHidden = !hasFileSelected
        self.delegate = delegate
	}
	
	
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return allInstruments.count
	}
	
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return allInstruments[row].rawValue
	}
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		uploadObject?.instrument = allInstruments[row]
	}
	
	@IBAction func didSelectSelectFile(_ sender: UIButton) {
		delegate?.didSelectDocumentPicker(uploadObject: uploadObject)
	}
	
}
