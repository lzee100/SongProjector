//
//  NewSongSheetCell.swift
//  SongViewer
//
//  Created by Leo van der Zee on 06-12-17.
//  Copyright © 2017 Topicus Onderwijs BV. All rights reserved.
//

import UIKit

protocol NewSongSheetCellDelegate {
	func textViewDidChange(index: Int?, lyrics: String?)
}

class NewSongSheetCell: UITableViewCell, UITextViewDelegate {

	@IBOutlet var leftConstraint: NSLayoutConstraint!
	@IBOutlet var containerView: UIView!
	@IBOutlet var textView: UITextView!
	
	
	var delegate: NewSongSheetCellDelegate?
	
	var songTitle: String? { didSet { update() } }
	var lyrics: String? { didSet { update() } }
	var index: Int?
	
	static let identifier = "NewSongSheetCell"
	
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
	
	func setup() {
		
		update()
	}
	
	private func update() {
		textView.text = index == 0 ? songTitle : lyrics
	}

    override func setSelected(_ selected: Bool, animated: Bool) {
		
    }
	
	func textViewDidEndEditing(_ textView: UITextView) {
		print("")
	}
	
	func textViewDidChange(_ textView: UITextView) {
		delegate?.textViewDidChange(index: index, lyrics: textView.text)
	}
    
}
