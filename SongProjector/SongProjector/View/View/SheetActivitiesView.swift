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
	@IBOutlet var backgroundImageView: UIImageView!
	@IBOutlet var descriptionTitle: UILabel!
	@IBOutlet var titleBackgroundView: UIView!
	@IBOutlet var activitiesContainerView: UIView!
	
	@IBOutlet var titleLeftConstraint: NSLayoutConstraint!
	@IBOutlet var titleTopConstraint: NSLayoutConstraint!
	@IBOutlet var titleRightConstraint: NSLayoutConstraint!

	@IBOutlet var containerLeftConstraint: NSLayoutConstraint!
	@IBOutlet var containerBottomContraint: NSLayoutConstraint!
	@IBOutlet var containerTopConstraint: NSLayoutConstraint!
	@IBOutlet var containerRightConstraint: NSLayoutConstraint!
	
	private var selectedTag: Tag?
	private var activities: [GoogleActivity] = []
	private var sheet: SheetActivities?
	
	override func customInit() {
		Bundle.main.loadNibNamed("SheetActivitiesView", owner: self, options: [:])
		sheetView.frame = self.frame
		sheetView.layoutIfNeeded()
		addSubview(sheetView)
	}
	
	static func createWith(frame: CGRect, sheet: SheetActivities?, tag: Tag?, scaleFactor: CGFloat = 1, isPreview: Bool = false) -> SheetActivitiesView {
		
		let view = SheetActivitiesView(frame: frame)
		view.selectedTag = tag
		view.scaleFactor = scaleFactor
		view.sheet = sheet
		if isPreview {
			view.addPreviewActivities()
		} else {
			CoreGoogleActivities.setSortDescriptor(attributeName: "startDate", ascending: true)
			view.activities = CoreGoogleActivities.getEntities()
		}
		view.update()
		
		return view
	}
	
	override func update() {
		
		titleLeftConstraint.constant = titleLeftConstraint.constant * (scaleFactor ?? 1)
		titleTopConstraint.constant = titleTopConstraint.constant * (scaleFactor ?? 1)
		titleRightConstraint.constant = titleRightConstraint.constant * (scaleFactor ?? 1)
		containerTopConstraint.constant = containerTopConstraint.constant * (scaleFactor ?? 1)
		containerLeftConstraint.constant = containerLeftConstraint.constant * (scaleFactor ?? 1)
		containerBottomContraint.constant = containerBottomContraint.constant * (scaleFactor ?? 1)
		containerRightConstraint.constant = containerRightConstraint.constant * (scaleFactor ?? 1)
		
		var fontName = ""
		if var attributes = selectedTag?.getTitleAttributes(scaleFactor ?? 1), let font = attributes[.font] as? UIFont {
			fontName = font.fontName
			attributes[.font] = UIFont(name: fontName, size: (self.descriptionTitle.frame.height / 3) * (scaleFactor ?? 1))
			descriptionTitle.attributedText = NSAttributedString(string: sheet?.title ?? "", attributes: attributes)
		} else {
			descriptionTitle.attributedText = NSAttributedString(string: sheet?.title ?? "", attributes: selectedTag?.getTitleAttributes(scaleFactor ?? 1))
		}
		
		layoutIfNeeded()
		
		addActivities()
		
		if let backgroundImage = selectedTag?.backgroundImage, let imageScaled = UIImage.scaleImageToSize(image: backgroundImage, size: bounds.size) {
			imageScaled.draw(in: CGRect(x: 0, y: 0, width: 50, height: 50))
			self.backgroundImageView.isHidden = false
			self.backgroundImageView.contentMode = .scaleAspectFit
			self.backgroundImageView.image = imageScaled
		} else {
			backgroundImageView.isHidden = true
		}
		
		if let backgroundColor = selectedTag?.sheetBackgroundColor, selectedTag?.backgroundImage == nil {
			self.backgroundView.backgroundColor = backgroundColor
		} else {
			self.backgroundView.backgroundColor = .white
		}
	}
	
	private func addPreviewActivities() {
		activities = []
		var index: Double = 0
		while index < 8 {
			let activity = CoreGoogleActivities.createEntityNOTsave()
			activity.isTemp = true
			activity.startDate = Date().addingTimeInterval(.days(index * 3))
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
			let headerThisWeek = ActivityHeader.createWith(frame: frameHeader, tag: selectedTag, title: Text.ActivitySheet.titleUpcomingTime, scaleFactor: scaleFactor)
			activitiesContainerView.addSubview(headerThisWeek)
			
			// add ACTIVITY THIS WEEK
			let frame = CGRect(x: 0, y: activitiesContainerView.bounds.height / 10, width: activitiesContainerView.bounds.width, height: activitiesContainerView.bounds.height / 12)
			let activityView = ActivityView.createWith(frame: frame, tag: selectedTag, activity: nil, scaleFactor: (scaleFactor ?? 1))
			activitiesContainerView.addSubview(activityView)
			
			return
		}
		
		var hasThisWeek = false
		for activity in activities {
			if let startDate = activity.startDate, startDate.isThisWeek {
				hasThisWeek = true
				break
			}
		}
		
		var hasNextWeek = false
		for activity in activities {
			if let startDate = activity.startDate, startDate.isNextWeek {
				hasNextWeek = true
				break
			}
		}
		
		var hasUpcoming = false
		for activity in activities {
			if let startDate = activity.startDate, !startDate.isThisWeek, !startDate.isNextWeek {
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
			if let startDate = activity.startDate, startDate.isThisWeek {
				
				// add HEADER THIS WEEK
				if !hasHeaderThisWeek {
				let frameHeader = CGRect(x: 0, y: y, width: activitiesContainerView.bounds.width, height: activityHeight * headerPoints)
				let headerThisWeek = ActivityHeader.createWith(frame: frameHeader, tag: selectedTag, title: Text.ActivitySheet.titleThisWeek, scaleFactor: scaleFactor)
				activitiesContainerView.addSubview(headerThisWeek)
					y += (activityHeight * headerPoints)
					hasHeaderThisWeek = true
				}
				
				// add ACTIVITY THIS WEEK
				let frame = CGRect(x: 0, y: y, width: activitiesContainerView.bounds.width, height: activityHeight * 2)
				let activityView = ActivityView.createWith(frame: frame, tag: selectedTag, activity: activity, scaleFactor: scaleFactor ?? 1)
				activitiesContainerView.addSubview(activityView)
				y += (activityHeight * 2)
			}
			// NEXT WEEK
			else if let startDate = activity.startDate, startDate.isNextWeek {
				// add HEADER NEXT WEEK
				if !hasHeaderNextWeek {
					let frameHeader = CGRect(x: 0, y: y, width: activitiesContainerView.bounds.width, height: activityHeight * headerPoints)
					let headerThisWeek = ActivityHeader.createWith(frame: frameHeader, tag: selectedTag, title: Text.ActivitySheet.titleNextWeek, scaleFactor: scaleFactor)
					activitiesContainerView.addSubview(headerThisWeek)
					y += (activityHeight * headerPoints)
					hasHeaderNextWeek = true
				}
				
				// add ACTIVITY NEXT WEEK
				let frame = CGRect(x: 0, y: y, width: activitiesContainerView.bounds.width, height: activityHeight * 2)
				let activityView = ActivityView.createWith(frame: frame, tag: selectedTag, activity: activity, scaleFactor: scaleFactor ?? 1)
				activitiesContainerView.addSubview(activityView)
				y += (activityHeight * 2)
			}
			
			// UPCOMING
			else {
				if !hasHeaderUpcoming {
					let frameHeader = CGRect(x: 0, y: y, width: activitiesContainerView.bounds.width, height: activityHeight * headerPoints)
					let headerThisWeek = ActivityHeader.createWith(frame: frameHeader, tag: selectedTag, title: Text.ActivitySheet.titleUpcomingTime, scaleFactor: scaleFactor)
					activitiesContainerView.addSubview(headerThisWeek)
					y += (activityHeight * headerPoints)
					hasHeaderUpcoming = true
				}
				
				// add ACTIVITY NEXT WEEK
				let frame = CGRect(x: 0, y: y, width: activitiesContainerView.bounds.width, height: activityHeight * 2)
				let activityView = ActivityView.createWith(frame: frame, tag: selectedTag, activity: activity, scaleFactor: scaleFactor ?? 1)
				activitiesContainerView.addSubview(activityView)
				y += (activityHeight * 2)
			}
			activitiesContainerView.layoutIfNeeded()
			activitiesContainerView.layoutSubviews()
		}
		
	}
}

