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
	
	open var position: Int {
		return Int(sheet.position)
	}
	open var scaleFactor: CGFloat?
	open var isForExternalDispay: Bool = false
	open var cluster: Cluster?
	open var sheet: Sheet!
	open var sheetTheme: Theme?
	open var isPreview: Bool = false
	
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		customInit()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		customInit()
	}
	
	func set(frame: CGRect, cluster: Cluster? = nil, sheet: Sheet, theme: Theme?, scaleFactor: CGFloat? = 1, isPreview: Bool = false, position: Int = 0, toExternalDisplay: Bool = false) {
		
		for view in subviews {
			view.removeFromSuperview()
		}
		let view = getViewFor(sheet: sheet, frame: frame)
		view.frame = frame
		view.cluster = cluster
		view.sheet = sheet
		view.sheetTheme = theme
		view.scaleFactor = scaleFactor
		view.isPreview = isPreview
		if toExternalDisplay, let externalDisplay = externalDisplayWindow {
			sendToExternalDisplay(frame: externalDisplay.frame, sheet: sheet, theme: theme, scaleFactor: externalDisplay.frame.width / frame.width * (scaleFactor ?? 1))
		}
		view.update()
		addSubview(view)
	}
	
	static func createWith(frame: CGRect, cluster: Cluster? = nil, sheet: Sheet, theme: Theme?, scaleFactor: CGFloat? = 1, isPreview: Bool = false, position: Int = 0, toExternalDisplay: Bool = false) -> SheetView {
		
		let view: SheetView
		
		switch sheet.type {
		case .SheetTitleContent:
			view = SheetTitleContent(frame: frame)
		case .SheetTitleImage:
			view = SheetTitleImage(frame: frame)
		case .SheetPastors:
			view = SheetPastors(frame: frame)
		case .SheetSplit:
			view = SheetSplit(frame: frame)
		case .SheetEmpty:
			view = SheetEmpty(frame: frame)
		case .SheetActivities:
			view = SheetActivitiesView(frame: frame)
		}
		
		view.cluster = cluster
		view.sheet = sheet
		view.sheetTheme = theme
		view.scaleFactor = scaleFactor
		view.isPreview = isPreview
		
		view.update()
		
		if toExternalDisplay, let externalDisplay = externalDisplayWindow {
			view.sendToExternalDisplay(frame: externalDisplay.frame, cluster: cluster, sheet: sheet, theme: theme, scaleFactor: externalDisplay.frame.width / view.frame.width * (scaleFactor ?? 1))
		}
		return view
	}
	
	private func sendToExternalDisplay(frame: CGRect, cluster: Cluster? = nil, sheet: Sheet, theme: Theme?, scaleFactor: CGFloat? = 1, isPreview: Bool = false) {
		let view = getViewFor(sheet: sheet, frame: frame)
		view.cluster = cluster
		view.sheet = sheet
		view.sheetTheme = theme
		view.isPreview = isPreview
		view.scaleFactor = scaleFactor
		
		view.isForExternalDispay = true
		
		if let externalDisplay = externalDisplayWindow {
			for subview in externalDisplay.subviews {
				subview.removeFromSuperview()
			}
			externalDisplay.addSubview(view)
		}
		view.update()
	}
	
	private func getViewFor(sheet: Sheet, frame: CGRect) -> SheetView {
		let view: SheetView
		
		switch sheet.type {
		case .SheetTitleContent:
			view = SheetTitleContent(frame: frame)
		case .SheetTitleImage:
			view = SheetTitleImage(frame: frame)
		case .SheetPastors:
			view = SheetPastors(frame: frame)
		case .SheetSplit:
			view = SheetSplit(frame: frame)
		case .SheetEmpty:
			view = SheetEmpty(frame: frame)
		case .SheetActivities:
			view = SheetActivitiesView(frame: frame)
		}
		return view
	}
	
	
	func customInit() {
	}
	
	func update() {
	}
	
	func updateTitle() {
	}
	
	func updateContent() {
	}
	
	func updateOpacity() {
	}
	
	func updateBackgroundImage() {
	}
	
	func updateSheetImage() {
	}
	
	func updateBackgroundColor() {
	}
	
	func updateTime(isOn: Bool) {
	}
	
}
