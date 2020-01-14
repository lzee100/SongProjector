//
//  SheetActivitiesView.swift
//  SongProjector
//
//  Created by Leo van der Zee on 28-01-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import UIKit

class SheetActivitiesView: SheetView {

	@IBOutlet var sheetView: UIView!
	
	@IBOutlet var backgroundView: UIView!
	@IBOutlet var timeLabel: UILabel!
	@IBOutlet var backgroundImageView: UIImageView!
	@IBOutlet var descriptionTitle: UILabel!
	@IBOutlet var titleBackgroundView: UIView!
	@IBOutlet var activitiesContainerView: UIView!
	
	@IBOutlet var titleLeftConstraint: NSLayoutConstraint!
	@IBOutlet var titleTopConstraint: NSLayoutConstraint!
	@IBOutlet var timeLabelRightConstraint: NSLayoutConstraint!

	@IBOutlet var containerLeftConstraint: NSLayoutConstraint!
	@IBOutlet var containerBottomContraint: NSLayoutConstraint!
	@IBOutlet var containerTopConstraint: NSLayoutConstraint!
	@IBOutlet var containerRightConstraint: NSLayoutConstraint!
	
	private var activities: [VGoogleActivity] = []
	
	override func customInit() {
		Bundle.main.loadNibNamed("SheetActivitiesView", owner: self, options: [:])
		sheetView.frame = self.frame
		sheetView.layoutIfNeeded()
		addSubview(sheetView)
	}
	
	override func update() {
		
		timeLabel.text = ""
		if isPreview {
			addPreviewActivities()
		} else {
			CoreGoogleActivities.setSortDescriptor(attributeName: "startDate", ascending: true)
			activities = VGoogleActivity.list()
		}
		
		if let scaleFactor = scaleFactor {
			titleLeftConstraint.constant = titleLeftConstraint.constant  * scaleFactor
			titleTopConstraint.constant = titleTopConstraint.constant  * scaleFactor
			timeLabelRightConstraint.constant = timeLabelRightConstraint.constant  * scaleFactor
			containerTopConstraint.constant = containerTopConstraint.constant  * scaleFactor
			containerLeftConstraint.constant = containerLeftConstraint.constant  * scaleFactor
			containerBottomContraint.constant = containerBottomContraint.constant  * scaleFactor
			containerRightConstraint.constant = containerRightConstraint.constant  * scaleFactor
		}
		
		var fontName = ""
		if var attributes = sheetTheme?.getTitleAttributes(scaleFactor ?? 1), let font = attributes[.font] as? UIFont {
			fontName = font.fontName
			attributes[.font] = UIFont(name: fontName, size: (self.descriptionTitle.frame.height / 3) * (scaleFactor ?? 1))
			descriptionTitle.attributedText = NSAttributedString(string: sheet.title ?? "", attributes: attributes)
		} else {
			descriptionTitle.attributedText = NSAttributedString(string: sheet.title ?? "", attributes: sheetTheme?.getTitleAttributes(scaleFactor ?? 1))
		}
		
		layoutIfNeeded()
		
		addActivities()
		
		updateBackgroundImage()
		
		if let backgroundColor = sheetTheme?.sheetBackgroundColor, sheetTheme?.backgroundImage == nil {
			self.backgroundView.backgroundColor = backgroundColor
		} else {
			self.backgroundView.backgroundColor = .white
		}
	}
	
	private func addPreviewActivities() {
		activities = []
		var index: Double = 0
		while index < 8 {
			let activity = VGoogleActivity()
			activity.deleteDate = NSDate()
			activity.startDate = Date().addingTimeInterval(.days(index * 3)) as NSDate
			activity.eventDescription = Text.ActivitySheet.previewDescription
			index += 1
			activities.append(activity)
		}
	}
	
	private func addActivities() {
		
		for subview in activitiesContainerView.subviews {
			subview.removeFromSuperview()
		}
		
		// NO ACTIVITIES
		if activities.count == 0 {
			
			// add HEADER
			let frameHeader = CGRect(x: 0, y: 0, width: activitiesContainerView.bounds.width, height: activitiesContainerView.bounds.height / 10)
			let headerThisWeek = ActivityHeader.createWith(frame: frameHeader, theme: sheetTheme, title: Text.ActivitySheet.titleUpcomingTime, scaleFactor: scaleFactor)
			activitiesContainerView.addSubview(headerThisWeek)
			
			// add ACTIVITY THIS WEEK
			let frame = CGRect(x: 0, y: activitiesContainerView.bounds.height / 10, width: activitiesContainerView.bounds.width, height: activitiesContainerView.bounds.height / 12)
			let activityView = ActivityView.createWith(frame: frame, theme: sheetTheme, activity: nil, scaleFactor: (scaleFactor ?? 1))
			activitiesContainerView.addSubview(activityView)
			
			return
		}
		
		var hasThisWeek = false
		for activity in activities {
			if let startDate = activity.startDate, (startDate as Date).isThisWeek {
				hasThisWeek = true
				break
			}
		}
		
		var hasNextWeek = false
		for activity in activities {
			if let startDate = activity.startDate, (startDate as Date).isNextWeek {
				hasNextWeek = true
				break
			}
		}
		
		var hasUpcoming = false
		for activity in activities {
			if let startDate = activity.startDate, (startDate as Date).isThisWeek, !(startDate as Date).isNextWeek {
				hasUpcoming = true
				break
			}
		}
		
		var heightHeaders: CGFloat = 0
		let headerPoints: CGFloat = 2
		if hasThisWeek {
			heightHeaders += headerPoints
		}
		if hasNextWeek {
			heightHeaders += headerPoints
		}
		if hasUpcoming {
			heightHeaders += headerPoints
		}
		
		let activityHeight = activitiesContainerView.bounds.height / (heightHeaders + 16)
		var y: CGFloat = 0
		
		var hasHeaderThisWeek = false
		var hasHeaderNextWeek = false
		var hasHeaderUpcoming = false
		
		for activity in activities {
			
			// THIS WEEK
			if let startDate = activity.startDate, (startDate as Date).isThisWeek {
				
				// add HEADER THIS WEEK
				if !hasHeaderThisWeek {
				let frameHeader = CGRect(x: 0, y: y, width: activitiesContainerView.bounds.width, height: activityHeight * headerPoints)
				let headerThisWeek = ActivityHeader.createWith(frame: frameHeader, theme: sheetTheme, title: Text.ActivitySheet.titleThisWeek, scaleFactor: scaleFactor)
				activitiesContainerView.addSubview(headerThisWeek)
					y += (activityHeight * headerPoints)
					hasHeaderThisWeek = true
				}
				
				// add ACTIVITY THIS WEEK
				let frame = CGRect(x: 0, y: y, width: activitiesContainerView.bounds.width, height: activityHeight * 2)
				let activityView = ActivityView.createWith(frame: frame, theme: sheetTheme, activity: activity, scaleFactor: scaleFactor ?? 1)
				activitiesContainerView.addSubview(activityView)
				y += (activityHeight * 2)
			}
			// NEXT WEEK
			else if let startDate = activity.startDate, (startDate as Date).isThisWeek {
				// add HEADER NEXT WEEK
				if !hasHeaderNextWeek {
					let frameHeader = CGRect(x: 0, y: y, width: activitiesContainerView.bounds.width, height: activityHeight * headerPoints)
					let headerThisWeek = ActivityHeader.createWith(frame: frameHeader, theme: sheetTheme, title: Text.ActivitySheet.titleNextWeek, scaleFactor: scaleFactor)
					activitiesContainerView.addSubview(headerThisWeek)
					y += (activityHeight * headerPoints)
					hasHeaderNextWeek = true
				}
				
				// add ACTIVITY NEXT WEEK
				let frame = CGRect(x: 0, y: y, width: activitiesContainerView.bounds.width, height: activityHeight * 2)
				let activityView = ActivityView.createWith(frame: frame, theme: sheetTheme, activity: activity, scaleFactor: scaleFactor ?? 1)
				activitiesContainerView.addSubview(activityView)
				y += (activityHeight * 2)
			}
			
			// UPCOMING
			else {
				if !hasHeaderUpcoming {
					let frameHeader = CGRect(x: 0, y: y, width: activitiesContainerView.bounds.width, height: activityHeight * headerPoints)
					let headerThisWeek = ActivityHeader.createWith(frame: frameHeader, theme: sheetTheme, title: Text.ActivitySheet.titleUpcomingTime, scaleFactor: scaleFactor)
					activitiesContainerView.addSubview(headerThisWeek)
					y += (activityHeight * headerPoints)
					hasHeaderUpcoming = true
				}
				
				// add ACTIVITY NEXT WEEK
				let frame = CGRect(x: 0, y: y, width: activitiesContainerView.bounds.width, height: activityHeight * 2)
				let activityView = ActivityView.createWith(frame: frame, theme: sheetTheme, activity: activity, scaleFactor: scaleFactor ?? 1)
				activitiesContainerView.addSubview(activityView)
				y += (activityHeight * 2)
			}
			activitiesContainerView.layoutIfNeeded()
			activitiesContainerView.layoutSubviews()
		}
		
	}
	
	override func updateOpacity() {
		if let alpha = sheetTheme?.backgroundTransparancy, alpha != 1 {
			if sheetTheme?.backgroundImage != nil {
				backgroundImageView.alpha = CGFloat(alpha)
				backgroundView.alpha = 1
			} else {
				backgroundImageView.alpha = 0
				backgroundView.alpha = CGFloat(alpha)
			}
		}
	}
	
	override func updateBackgroundImage() {
		if let image = isForExternalDispay ? sheetTheme?.backgroundImage : sheetTheme?.thumbnail {
			backgroundImageView.isHidden = false
			backgroundImageView.contentMode = .scaleAspectFill
			backgroundImageView.image = image
			if let backgroundTransparency = sheetTheme?.backgroundTransparancy {
				backgroundImageView.alpha = CGFloat(backgroundTransparency)
			}
		} else {
			backgroundImageView.isHidden = true
		}
	}
	
	override func updateTime(isOn: Bool) {
		
		let test = Date().time
		if !isOn {
			timeLabel.text = ""
			return
		}
		
		if let theme = sheetTheme, let scaleFactor = scaleFactor { // is custom sheet
			
			timeLabel.attributedText = NSAttributedString(string: test, attributes: theme.getTitleAttributes(scaleFactor))
			
		} else {
			timeLabel.text = test
		}
		
	}
	
	override func updateTitle() {
		let sheet = self.sheet as! SheetActivitiesEntity
		if let songTitle = sheet.title {
			if let theme = sheetTheme {
				descriptionTitle.attributedText = NSAttributedString(string: songTitle, attributes: theme.getTitleAttributes(scaleFactor ?? 0))
			} else {
				descriptionTitle.text = ""
			}
		}
		self.setNeedsLayout()
	}
	
	override func updateContent() {
		if let theme = sheetTheme {
			activitiesContainerView.subviews.compactMap({ $0 as? ActivityView }).compactMap({ $0.descriptionTime }).forEach({ $0.attributedText = NSAttributedString(string: $0.text ?? "", attributes: theme.getLyricsAttributes(scaleFactor ?? 1)) })
			activitiesContainerView.subviews.compactMap({ $0 as? ActivityView }).compactMap({ $0.descriptionActivity }).forEach({ $0.attributedText = NSAttributedString(string: $0.text ?? "", attributes: theme.getLyricsAttributes(scaleFactor ?? 1)) })
		}
	}
	
	override func updateBackgroundColor() {
		if let backgroundColor = sheetTheme?.sheetBackgroundColor {
			self.backgroundView.backgroundColor = backgroundColor
		} else {
			self.backgroundView.backgroundColor = .white
		}
	}
	
}

