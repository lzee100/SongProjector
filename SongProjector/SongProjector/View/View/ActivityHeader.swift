//
//  ActivityHeader.swift
//  SongProjector
//
//  Created by Leo van der Zee on 28-01-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import UIKit

class ActivityHeader: UIView {
	
	@IBOutlet var activityHeaderView: UIView!
	@IBOutlet var descriptionTitle: UILabel!
	
	
	private var selectedTheme: VTheme?
	private var scaleFactor: CGFloat = 1
	private var titleDescription = ""
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		customInit()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		customInit()
	}
	
	func customInit() {
		Bundle.main.loadNibNamed("ActivityHeader", owner: self, options: [:])
		activityHeaderView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
		addSubview(activityHeaderView)
	}
	
	static func createWith(frame: CGRect, theme: VTheme?, title: String, scaleFactor: CGFloat? = 1) -> ActivityHeader {
		
		let view = ActivityHeader(frame: frame)
		view.selectedTheme = theme
		view.scaleFactor = scaleFactor ?? 1
		view.titleDescription = title
		view.update()
		
		return view
	}
	
	func update() {
		var fontName = ""
		if var attributes = selectedTheme?.getTitleAttributes(scaleFactor), let font = attributes[.font] as? UIFont {
			fontName = font.fontName
			attributes[.font] = UIFont(name: fontName, size: (self.descriptionTitle.frame.height / 3) * scaleFactor)
			descriptionTitle.attributedText = NSAttributedString(string: titleDescription, attributes: attributes)
		} else {
			descriptionTitle.attributedText = NSAttributedString(string: titleDescription, attributes: selectedTheme?.getTitleAttributes(scaleFactor))
		}
	}
}
