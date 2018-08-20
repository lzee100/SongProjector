//
//  SheetTest.swift
//  SongProjector
//
//  Created by Leo van der Zee on 10-07-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import UIKit

class SheetTest: UIViewController {

	@IBOutlet var previewView: UIView!
	
	override func viewDidLoad() {
		
		let sheet = CoreSheetPastors.createEntity()
		sheet.isTemp = true

		
		let tag = CoreTag.createEntity()
		tag.title = "tag"
		tag.isHidden = true
		tag.isTemp = true
		tag.titleTextSize = 14
		tag.textColorTitle = .black
		tag.lyricsTextSize = 10
		tag.textColorLyrics = .black
		tag.backgroundTransparency = 100
		tag.allHaveTitle = true
		tag.hasEmptySheet = false
		tag.titleAlignmentNumber = 0
		tag.lyricsAlignmentNumber = 0

		tag.textColorTitle = .white
		tag.textColorLyrics = .white
		tag.isTitleItalian = true
		tag.isLyricsItalian = true
		tag.titleAlignmentNumber = 1
		tag.lyricsAlignmentNumber = 1
		
		sheet.title = Text.newPastorsSheet.title
		sheet.content = Text.newPastorsSheet.content

		let view = SheetPastors.createWith(frame: previewView.bounds, cluster: nil, sheet: sheet, tag: tag, isPreview: false, position: 0, toExternalDisplay: true)

		previewView.addSubview(view)
		self.view.backgroundColor = .gray
		
	}

}
