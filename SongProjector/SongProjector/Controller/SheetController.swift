//
//  SheetController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 22-12-17.
//  Copyright © 2017 iozee. All rights reserved.
//

import UIKit

class SheetController: UIViewController {
	
	@IBOutlet var titleSheet: UILabel!
	@IBOutlet var lyricsSheet: UITextView!
	@IBOutlet var heightConstraint: NSLayoutConstraint!
	
	var isEmptySheet: Bool = false { didSet { update() } }
	var hasTitle: Bool = true { didSet { update() } }
	var songTitle: String? { didSet { update() } }
	var lyrics: String? { didSet { update() } }
	var viewFrame: CGRect?
	var tag: Tag? { didSet { update() } }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
	
	override func viewDidLayoutSubviews() {
		if let viewFrame = viewFrame {
			view.frame = viewFrame
		}

	}
	
	func setView(_ view: CGRect) {
		viewFrame = view
		self.view.frame = view
	}
	
	private func update() {
		heightConstraint.constant = isEmptySheet ? 0 : hasTitle ? 50 : 0
		
		if let songTitle = songTitle, let tag = tag {
			titleSheet.attributedText = NSAttributedString(string: songTitle, attributes: tag.getTitleAttributes())
		} else if let songTitle = songTitle {
			titleSheet.text = songTitle
		}
		
		if let lyrics = lyrics, let tag = tag {
			lyricsSheet.attributedText = NSAttributedString(string: lyrics, attributes: tag.getLyricsAttributes())
		} else if let lyrics = lyrics {
			lyricsSheet.text = lyrics
		}
	}
    
	func asImage() -> UIImage {
		return self.view.asImage()
	}

}
