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
    
    enum SheetCodable {
        case sheetTitleContentCodable(SheetTitleContentCodable)
        case sheetTitleImageCodable(SheetTitleImageCodable)
        case sheetEmptyCodable(SheetEmptyCodable)
        case sheetSplitCodable(SheetSplitCodable)
        case sheetPastorsCodable(SheetPastorsCodable)
        case sheetActivityCodable(SheetActivitiesCodable)
    }
	
	open var position: Int {
        switch sheetCodable {
        case .sheetTitleContentCodable(let sheetCodable):
            return sheetCodable.position
        default: return Int(sheet.position)
        }
	}
	open var scaleFactor: CGFloat?
	open var isForExternalDispay: Bool = false
	open var cluster: VCluster?
	open var sheet: VSheet!
    open var sheetCodable: SheetCodable?
	open var sheetTheme: VTheme?
    open var sheetThemeCodable: ThemeCodable?
	open var isPreview: Bool = false
	
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		customInit()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		customInit()
	}
	
	func set(frame: CGRect, cluster: VCluster? = nil, sheet: VSheet, theme: VTheme?, scaleFactor: CGFloat? = 1, isPreview: Bool = false, toExternalDisplay: Bool = false) {
		
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
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.3
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 5
		addSubview(view)
	}
	
	static func createWith(frame: CGRect, cluster: VCluster? = nil, sheet: VSheet, theme: VTheme?, scaleFactor: CGFloat? = 1, isPreview: Bool = false, toExternalDisplay: Bool = false) -> SheetView {
		
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
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.3
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 5
		
		view.update()
		
		if toExternalDisplay, let externalDisplay = externalDisplayWindow {
			view.sendToExternalDisplay(frame: externalDisplay.frame, cluster: cluster, sheet: sheet, theme: theme, scaleFactor: externalDisplay.frame.width / view.frame.width * (scaleFactor ?? 1))
		}
		return view
	}
    
    static func createWith(frame: CGRect, cluster: VCluster? = nil, sheet: SheetCodable, theme: ThemeCodable?, scaleFactor: CGFloat? = 1, isPreview: Bool = false, toExternalDisplay: Bool = false) -> SheetView {
        
        let view: SheetView = Self.getViewFor(sheet: sheet, frame: frame)
        
        view.cluster = cluster
        view.sheetCodable = sheet
        view.sheetThemeCodable = theme
        view.scaleFactor = scaleFactor
        view.isPreview = isPreview
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.3
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 5
        
        view.update()
        
        if toExternalDisplay, let externalDisplay = externalDisplayWindow {
            view.sendToExternalDisplay(frame: externalDisplay.frame, cluster: cluster, sheet: sheet, theme: theme, scaleFactor: externalDisplay.frame.width / view.frame.width * (scaleFactor ?? 1))
        }
        return view
    }
    
    private func sendToExternalDisplay(frame: CGRect, cluster: VCluster? = nil, sheet: SheetCodable, theme: ThemeCodable?, scaleFactor: CGFloat? = 1, isPreview: Bool = false) {
        let view = Self.getViewFor(sheet: sheet, frame: frame)
        view.cluster = cluster
        view.sheetCodable = sheet
        view.sheetThemeCodable = theme
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

    private static func getViewFor(sheet: SheetCodable, frame: CGRect) -> SheetView {
        let view: SheetView
        
        switch sheet {
        case .sheetTitleContentCodable:
            view = SheetTitleContent(frame: frame)
        case .sheetTitleImageCodable:
            view = SheetTitleImage(frame: frame)
        case .sheetPastorsCodable:
            view = SheetPastors(frame: frame)
        case .sheetSplitCodable:
            view = SheetSplit(frame: frame)
        case .sheetEmptyCodable:
            view = SheetEmpty(frame: frame)
        case .sheetActivityCodable:
            view = SheetActivitiesView(frame: frame)
        }
        
        return view
    }
    
	
	private func sendToExternalDisplay(frame: CGRect, cluster: VCluster? = nil, sheet: VSheet, theme: VTheme?, scaleFactor: CGFloat? = 1, isPreview: Bool = false) {
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
	
	private func getViewFor(sheet: VSheet, frame: CGRect) -> SheetView {
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
