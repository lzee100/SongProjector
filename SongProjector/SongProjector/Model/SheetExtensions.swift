//
//  SheetExtensions.swift
//  SongProjector
//
//  Created by Leo van der Zee on 11-01-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import Foundation
import UIKit

public enum SheetType {
	case SheetTitleContent
	case SheetTitleImage
	case SheetSplit
	case SheetEmpty
	case SheetActivities
	
	static let all = [SheetTitleContent, SheetTitleImage, SheetSplit, SheetEmpty, SheetActivities]
	
	static func `for`(_ indexPath: IndexPath) -> SheetType {
		return all[indexPath.row]
	}
	
	static func iconFor(type: SheetType) -> UIImage {
		switch type {
		case .SheetTitleContent:
			return Cells.bulletOpen
		case .SheetTitleImage:
			return Cells.bulletOpen
		case .SheetSplit:
			return Cells.bulletOpen
		case .SheetEmpty:
			return Cells.bulletOpen
		case .SheetActivities:
			return Cells.bulletOpen
		}
	}
}

extension Sheet {
			
	var type: SheetType {
		if self.entity.isKindOf(entity: SheetTitleContentEntity.entity()){
			return .SheetTitleContent
		} else if self.entity.isKindOf(entity: SheetTitleImageEntity.entity()) {
			return .SheetTitleImage
		} else if self.entity.isKindOf(entity: SheetSplitEntity.entity()) {
			return .SheetSplit
		}  else if self.entity.isKindOf(entity: SheetActivities.entity()) {
			return .SheetActivities
		} else {
			return .SheetEmpty
		}
		
	}
	
	var emptySheet: Sheet {
		switch type {
		case .SheetTitleContent:
			let sheet = CoreSheetTitleContent.createEntityNOTsave()
			sheet.isTemp = true
			return sheet
		case .SheetTitleImage:
			let sheet = CoreSheetTitleImage.createEntityNOTsave()
			sheet.isTemp = true
			return sheet
		case .SheetSplit:
			let sheet = CoreSheetSplit.createEntityNOTsave()
			sheet.isTemp = true
			return sheet
		case .SheetEmpty:
			let sheet = CoreSheetEmptySheet.createEntity()
			sheet.isTemp = true
			return sheet
		case .SheetActivities:
			let sheet = CoreSheetActivities.createEntity()
			sheet.isTemp = true
			return sheet
		}
	}
	
	override public func delete() {
		if let tag = hasTag {
			tag.backgroundImage = nil
			let _ = CoreTag.delete(entity: tag)
		}
		_ = CoreSheet.delete(entity: self)
	}
	
	var getTemp: Sheet {
		let sheet: Sheet
		switch self.type {
		case .SheetTitleContent:
			sheet = CoreSheetTitleContent.createEntity()
			if let sheet = sheet as? SheetTitleContentEntity, let current = self as? SheetTitleContentEntity {
				sheet.lyrics = current.lyrics
			}
		case .SheetTitleImage:
			sheet = CoreSheetTitleImage.createEntity()
			if let sheet = sheet as? SheetTitleImageEntity, let current = self as? SheetTitleImageEntity {
				sheet.hasTitle = current.hasTitle
				sheet.imageHasBorder = current.imageHasBorder
				sheet.content = current.content
				sheet.imageBorderColor = current.imageBorderColor
				sheet.imageBorderSize = current.imageBorderSize
				sheet.imagePath = current.imagePath
				sheet.imageContentMode = current.imageContentMode
			}
		case .SheetSplit:
			sheet = CoreSheetSplit.createEntity()
			if let sheet = sheet as? SheetSplitEntity, let current = self as? SheetSplitEntity {
				sheet.textLeft = current.textLeft
				sheet.textRight = current.textRight
			}
		case .SheetEmpty:
			sheet = CoreSheetEmptySheet.createEntity()
		case .SheetActivities:
			sheet = CoreSheetActivities.createEntity()
			if let sheet = sheet as? SheetActivities, let current = self as? SheetActivities {
				sheet.hasGoogleActivity = current.hasGoogleActivity
			}
		}
		sheet.title = title
		sheet.isTemp = true
		sheet.time = time
		sheet.position = position
		sheet.isEmptySheet = isEmptySheet
		return sheet
	}
	
}

extension SheetTitleImageEntity {
	override public func delete() {
		super.delete()
		image = nil
	}
}
