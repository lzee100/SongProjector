//
//  SheetView.swift
//  SongProjector
//
//  Created by Leo van der Zee on 11-01-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import Foundation
import UIKit

class SheetView: UIView {
	
	open var position: Int = 0
	open var scaleFactor: CGFloat?
	open var isForExternalDispay: Bool = false
	open var cluster: Cluster?
	open var sheet: Sheet!
	open var sheetTag: Tag?
	open var isPreview: Bool = false
	
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		customInit()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		customInit()
	}
	
	func set(frame: CGRect, cluster: Cluster? = nil, sheet: Sheet, tag: Tag?, scaleFactor: CGFloat? = 1, isPreview: Bool = false, position: Int = 0, toExternalDisplay: Bool = false) {
		
		for view in subviews {
			view.removeFromSuperview()
		}
		let view = getViewFor(sheet: sheet, frame: frame)
		view.frame = frame
		view.cluster = cluster
		view.sheet = sheet
		view.sheetTag = tag
		view.scaleFactor = scaleFactor
		view.isPreview = isPreview
		view.position = Int(sheet.position)
		if toExternalDisplay, let externalDisplay = externalDisplayWindow {
			sendToExternalDisplay(frame: externalDisplay.frame, sheet: sheet, tag: tag, scaleFactor: externalDisplay.frame.width / frame.width * (scaleFactor ?? 1))
		}
		view.update()
		addSubview(view)
	}
	
	static func createWith(frame: CGRect, cluster: Cluster? = nil, sheet: Sheet, tag: Tag?, scaleFactor: CGFloat? = 1, isPreview: Bool = false, position: Int = 0, toExternalDisplay: Bool = false) -> SheetView {
		
		let view: SheetView
		
		switch sheet.type {
		case .SheetTitleContent:
			view = SheetTitleContent(frame: frame)
		case .SheetTitleImage:
			view = SheetTitleImage(frame: frame)
		case .SheetSplit:
			view = SheetSplit(frame: frame)
		case .SheetEmpty:
			view = SheetEmpty(frame: frame)
		case .SheetActivities:
			view = SheetActivitiesView(frame: frame)
		}
		
		view.cluster = cluster
		view.sheet = sheet
		view.sheetTag = tag
		view.scaleFactor = scaleFactor
		view.isPreview = isPreview
		
		view.update()
		
		if toExternalDisplay, let externalDisplay = externalDisplayWindow {
			view.sendToExternalDisplay(frame: externalDisplay.frame, sheet: sheet, tag: tag, scaleFactor: externalDisplay.frame.width / view.frame.width * (scaleFactor ?? 1))
		}
		return view
	}
	
	private func sendToExternalDisplay(frame: CGRect, sheet: Sheet, tag: Tag?, scaleFactor: CGFloat? = 1, isPreview: Bool = false) {
		let view = getViewFor(sheet: sheet, frame: frame)
		view.sheet = sheet
		view.sheetTag = tag
		view.isPreview = isPreview
		view.scaleFactor = scaleFactor
		
		view.isForExternalDispay = true
		
		view.update()
		if let externalDisplay = externalDisplayWindow {
			for subview in externalDisplay.subviews {
				subview.removeFromSuperview()
			}
			externalDisplay.addSubview(view)
		}
	}
	
	private func getViewFor(sheet: Sheet, frame: CGRect) -> SheetView {
		let view: SheetView
		
		switch sheet.type {
		case .SheetTitleContent:
			view = SheetTitleContent(frame: frame)
		case .SheetTitleImage:
			view = SheetTitleImage(frame: frame)
		case .SheetSplit:
			view = SheetSplit(frame: frame)
		case .SheetEmpty:
			view = SheetEmpty(frame: frame)
		case .SheetActivities:
			view = SheetActivitiesView(frame: frame)
		}
		return view
	}
	
	
	open func customInit() {
	}
	
	open func update() {
		
	}
	
	open func changeOpacity(newValue: Float) {

	}
	open func setBackgroundImage(image: UIImage?) {

	}
	
	open func updateTime(isOn: Bool) {

	}
	
}
