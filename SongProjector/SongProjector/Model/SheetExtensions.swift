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
	case SheetPastors
	case SheetSplit
	case SheetEmpty
	case SheetActivities
	
	static let all = [SheetTitleContent, SheetTitleImage, SheetPastors, SheetSplit, SheetEmpty, SheetActivities]
	
	static func `for`(_ indexPath: IndexPath) -> SheetType {
		return all[indexPath.row]
	}
	
	static func iconFor(type: SheetType) -> UIImage {
		switch type {
		case .SheetTitleContent:
			return Cells.bulletOpen
		case .SheetTitleImage:
			return Cells.bulletOpen
		case .SheetPastors:
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

enum SheetAttribute {
	case SheetTitle
	case SheetContent
	case SheetContentLeft
	case SheetContentRight
	case SheetImage
	case SheetPastorImage
	case SheetImageHasBorder
	case SheetImageBorderSize
	case SheetImageBorderColor
	case SheetImageContentMode
	
	var description: String? {
		switch self {
		case .SheetTitle: return Text.NewSheetTitleImage.descriptionTitle
		case .SheetContent: return Text.NewSheetTitleImage.descriptionContent
		case .SheetContentLeft: return Text.NewSheetTitleImage.descriptionTextLeft
		case .SheetContentRight: return Text.NewSheetTitleImage.descriptionTextRight
		case .SheetImage, .SheetPastorImage: return Text.NewSheetTitleImage.descriptionImage
		case .SheetImageHasBorder: return Text.NewSheetTitleImage.descriptionImageHasBorder
		case .SheetImageBorderSize: return Text.NewSheetTitleImage.descriptionImageBorderSize
		case .SheetImageBorderColor: return Text.NewSheetTitleImage.descriptionImageBorderColor
		case .SheetImageContentMode: return Text.NewSheetTitleImage.descriptionImageContentMode
		}
	}
	
	var additionalDescription: String? {
		switch self {
		case .SheetPastorImage: return Text.newPastorsSheet.photoDescription
		default:
			return nil
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
		} else if self.entity.isKindOf(entity: SheetPastorsEntity.entity()) {
			return .SheetPastors
		} else {
			return .SheetEmpty
		}
		
	}
	
	override public func delete() {
		if let theme = hasTheme, theme.isHidden == true {
			theme.backgroundImage = nil
			let _ = CoreTheme.delete(entity: theme)
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
		case .SheetPastors:
			sheet = CoreSheetPastors.createEntity()
			if let sheet = sheet as? SheetPastorsEntity, let current = self as? SheetPastorsEntity {
				sheet.content = current.content
				sheet.imagePath = current.imagePath
				sheet.thumbnailPath = current.thumbnailPath
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
		if self.hasTheme?.isHidden == true {
			sheet.hasTheme = hasTheme?.getTemp()
		}
		sheet.title = title
		sheet.deletedAt = Date()
		sheet.time = time
		sheet.position = position
		sheet.isEmptySheet = isEmptySheet
		return sheet
	}
	
	func mergeSelfInto(sheet: Sheet, isTemp: Bool = false) {
		switch self.type {
		case .SheetTitleContent:
			let sheet = sheet as! SheetTitleContentEntity
			let this = self as! SheetTitleContentEntity
			sheet.lyrics = this.lyrics
			
		case .SheetTitleImage:
			let sheet = sheet as! SheetTitleImageEntity
			let this = self as! SheetTitleImageEntity
			sheet.hasTitle = this.hasTitle
			sheet.imageHasBorder = this.imageHasBorder
			sheet.content = this.content
			sheet.imageBorderColor = this.imageBorderColor
			sheet.imageBorderSize = this.imageBorderSize
			sheet.imagePath = this.imagePath
			sheet.imageContentMode = this.imageContentMode
			
		case .SheetPastors:
			let sheet = sheet as! SheetPastorsEntity
			let this = self as! SheetPastorsEntity
			sheet.content = this.content
			sheet.imagePath = this.imagePath
			sheet.thumbnailPath = this.thumbnailPath
			
		case .SheetSplit:
			let sheet = sheet as! SheetSplitEntity
			let this = self as! SheetSplitEntity
			sheet.textLeft = this.textLeft
			sheet.textRight = this.textRight
			
		case .SheetEmpty:
			break
		case .SheetActivities:
			let sheet = sheet as! SheetActivities
			let this = self as! SheetActivities
			sheet.hasGoogleActivity = this.hasGoogleActivity
		}
		sheet.title = title
		sheet.deletedAt = deletedAt
		sheet.time = time
		sheet.position = position
		sheet.isEmptySheet = isEmptySheet
	}
	
	public func isEqualTo(_ object: Any?) -> Bool {
		if let sheet = object as? Sheet {
			return self.id == sheet.id
		}
		return false
	}
}

struct SheetHasSheet {
	var sheetId: Int64
	var sheetTempId: Int64
	
	init(sheetId: Int64, sheetTempId: Int64) {
		self.sheetId = sheetId
		self.sheetTempId = sheetTempId
	}
}

extension SheetTitleImageEntity {
	override public func delete() {
		super.delete()
		image = nil
	}
}
