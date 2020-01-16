//
//  SongsUploadSheetCell.swift
//  SongProjector
//
//  Created by Leo van der Zee on 15/01/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import UIKit

protocol SongsUploadSheetCellDelegate {
	func errorParsingTime()
}


class SongsUploadSheetCell: ChurchBeamCell, UITextFieldDelegate {

	@IBOutlet var lyricsLabel: UILabel!
	@IBOutlet var timeTextField: UITextField!
	
	static let identifier = "SongsUploadSheetCell"
	var sheet: VSheetTitleContent?
	var delegate: SongsUploadSheetCellDelegate?
	
    override func awakeFromNib() {
        super.awakeFromNib()
		timeTextField.addTarget(self, action: #selector(textFieldDidChange), for: .valueChanged)
    }
	
	func setup(_ sheet: VSheetTitleContent, delegate: SongsUploadSheetCellDelegate) {
		lyricsLabel.text = sheet.content
		self.delegate = delegate
		if sheet.time != 0 {
			timeTextField.text = "\(sheet.time)"
		} else {
			timeTextField.text = nil
		}
	}
	
	@objc private func textFieldDidChange() {
		if let text = timeTextField.text {
			if text != "", let time = Double(text) {
				sheet?.time = time
			} else if text != "" {
				delegate?.errorParsingTime()
			}
		}
	}
	
}
