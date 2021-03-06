//
//  ActivityView.swift
//  SongProjector
//
//  Created by Leo van der Zee on 28-01-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import UIKit

class ActivityView: UIView {

	@IBOutlet var descriptionTime: UILabel!
	@IBOutlet var descriptionActivity: UILabel!
	@IBOutlet var bulletView: UIView!
	@IBOutlet var activityView: UIView!
	
	private var selectedTheme: VTheme?
	private var activity: VGoogleActivity?
	private var scaleFactor: CGFloat? = 1
	
	@IBOutlet var bulletHeightConstraint: NSLayoutConstraint!
	@IBOutlet var timeWidthConstraint: NSLayoutConstraint!
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		customInit()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		customInit()
	}
	
	func customInit() {
		Bundle.main.loadNibNamed("ActivityView", owner: self, options: [:])
		activityView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
		activityView.layoutIfNeeded()
		addSubview(activityView)
	}
	
	static func createWith(frame: CGRect, theme: VTheme?, activity: VGoogleActivity?, scaleFactor: CGFloat? = 1) -> ActivityView {
		
		let view = ActivityView(frame: frame)
		view.selectedTheme = theme
		view.activity = activity
		view.bulletView.backgroundColor = .blackColor
		view.scaleFactor = scaleFactor
		view.update()
		
		return view
	}
	
	func update() {
		bulletHeightConstraint.constant = (descriptionTime.frame.height / 4)
		layoutIfNeeded()
		bulletView.layer.cornerRadius = bulletView.bounds.height / 2
		timeWidthConstraint.constant = timeWidthConstraint.constant * (scaleFactor ?? 1)
		
		var dateTime = ""
		if let date = activity?.startDate {
			dateTime += (date as Date).toString
		}
		if dateTime.isEmpty {
			dateTime = AppText.ActivitySheet.dayActivity
		}
		let activityDescription = activity?.eventDescription ?? AppText.ActivitySheet.descriptionNoActivities
		
		var fontName = ""
		if var attributes = selectedTheme?.getLyricsAttributes(scaleFactor ?? 1), let font = attributes[.font] as? UIFont {
			fontName = font.fontName
			attributes[.font] = UIFont(name: fontName, size: self.descriptionTime.frame.height / 2)
			descriptionTime.attributedText = NSAttributedString(string: dateTime, attributes: attributes)
			descriptionActivity.attributedText = NSAttributedString(string: activityDescription, attributes: attributes)
		} else {
			descriptionTime.attributedText = NSAttributedString(string: dateTime, attributes: selectedTheme?.getLyricsAttributes(scaleFactor ?? 1))
			descriptionActivity.attributedText = NSAttributedString(string: activityDescription, attributes: selectedTheme?.getLyricsAttributes(scaleFactor ?? 1))
		
		}
	}
	
}
