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

	@IBOutlet var sheetViewContainer: UIView!
	@IBOutlet var timeTextField: UITextField!
	
	static let identifier = "SongsUploadSheetCell"
	var sheet: VSheet?
	var delegate: SongsUploadSheetCellDelegate?
	
	override func prepareForReuse() {
		super.prepareForReuse()
		sheetViewContainer.subviews.forEach({ $0.removeFromSuperview() })
		timeTextField.removeTarget(self, action: #selector(textFieldDidChange), for: UIControl.Event.editingChanged)
	}
	
    override func awakeFromNib() {
        super.awakeFromNib()
        timeTextField.keyboardType = .numberPad
    }
	
	func setup(_ cluster: VCluster, sheet: VSheet, sheetPosition: Int, delegate: SongsUploadSheetCellDelegate) {
		timeTextField.addTarget(self, action: #selector(textFieldDidChange), for: UIControl.Event.editingChanged)
		let view = SheetView.createWith(frame: sheetViewContainer.bounds, cluster: cluster, sheet: sheet, theme: sheet.hasTheme ?? cluster.hasTheme(moc: moc), scaleFactor: 1, toExternalDisplay: false)
		sheetViewContainer.addSubview(view)
		self.delegate = delegate
		if sheet.time != 0 {
			timeTextField.text = "\(sheet.time)"
		} else {
			timeTextField.text = nil
		}
		self.sheet = sheet
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
