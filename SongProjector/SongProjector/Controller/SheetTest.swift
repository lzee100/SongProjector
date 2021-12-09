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
		
		let sheet = VSheetPastors()
		
		let theme = VTheme()
		theme.title = "theme"
		theme.isHidden = true
		theme.deleteDate = NSDate()
		theme.titleTextSize = 14
		theme.textColorTitle = .blackColor
		theme.contentTextSize = 10
		theme.textColorLyrics = .blackColor
		theme.backgroundTransparancy = 100
		theme.allHaveTitle = true
		theme.hasEmptySheet = false
		theme.titleAlignmentNumber = 0
		theme.contentAlignmentNumber = 0

		theme.textColorTitle = .whiteColor
		theme.textColorLyrics = .whiteColor
		theme.isTitleItalic = true
		theme.isContentItalic = true
		theme.titleAlignmentNumber = 1
		theme.contentAlignmentNumber = 1
		
		sheet.title = AppText.NewPastorsSheet.title
		sheet.content = AppText.NewPastorsSheet.content

		let view = SheetPastors.createWith(frame: previewView.bounds, cluster: nil, sheet: sheet, theme: theme, isPreview: false, toExternalDisplay: true)

		previewView.addSubview(view)
		self.view.backgroundColor = .gray
		
	}

}
