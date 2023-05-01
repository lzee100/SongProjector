//
//  SheetExtensions.swift
//  SongProjector
//
//  Created by Leo van der Zee on 11-01-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import Foundation
import UIKit
import CoreData

public enum SheetType: String, Codable {
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
    
    func  makeDefault() -> SheetMetaType? {
        switch self {
        case .SheetTitleContent: return SheetTitleContentCodable.makeDefault()
        case .SheetTitleImage: return SheetTitleImageCodable.makeDefault()
        case .SheetEmpty: return SheetEmptyCodable.makeDefault()
        case .SheetSplit: return SheetTitleContentCodable.makeDefault()
        case .SheetPastors: return SheetPastorsCodable.makeDefault()
        case .SheetActivities: return SheetActivitiesCodable.makeDefault()
        }
    }
	
	var metatype: Sheet.Type {
		switch self {
		case .SheetTitleContent: return SheetTitleContentEntity.self
		case .SheetTitleImage: return SheetTitleImageEntity.self
		case .SheetSplit: return SheetSplitEntity.self
		case .SheetEmpty: return SheetEmptyEntity.self
		case .SheetPastors: return SheetPastorsEntity.self
		case .SheetActivities: return SheetActivitiesEntity.self
		}
	}
    
    var name: String {
        switch self {
        case .SheetTitleContent: return AppText.SheetsMenu.sheetTitleText
        case .SheetTitleImage: return AppText.SheetsMenu.sheetTitleImage
        case .SheetSplit: return AppText.SheetsMenu.sheetSplit
        case .SheetEmpty: return AppText.SheetsMenu.sheetEmpty
        case .SheetPastors: return AppText.SheetsMenu.sheetPastors
        case .SheetActivities: return AppText.SheetsMenu.sheetActivity
        }
    }
}

public enum VSheetType: String, Codable {
	case SheetTitleContent
	case SheetTitleImage
	case SheetPastors
	case SheetSplit
	case SheetEmpty
	case SheetActivities
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
		case .SheetTitle: return AppText.NewSheetTitleImage.descriptionTitle
		case .SheetContent: return AppText.NewSheetTitleImage.descriptionContent
		case .SheetContentLeft: return AppText.NewSheetTitleImage.descriptionTextLeft
		case .SheetContentRight: return AppText.NewSheetTitleImage.descriptionTextRight
		case .SheetImage, .SheetPastorImage: return AppText.NewSheetTitleImage.descriptionImage
		case .SheetImageHasBorder: return AppText.NewSheetTitleImage.descriptionImageHasBorder
		case .SheetImageBorderSize: return AppText.NewSheetTitleImage.descriptionImageBorderSize
		case .SheetImageBorderColor: return AppText.NewSheetTitleImage.descriptionImageBorderColor
		case .SheetImageContentMode: return AppText.NewSheetTitleImage.descriptionImageContentMode
		}
	}
	
	var additionalDescription: String? {
		switch self {
		case .SheetPastorImage: return AppText.NewPastorsSheet.photoDescription
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
		}  else if self.entity.isKindOf(entity: SheetActivitiesEntity.entity()) {
			return .SheetActivities
		} else if self.entity.isKindOf(entity: SheetPastorsEntity.entity()) {
			return .SheetPastors
		} else {
			return .SheetEmpty
		}
		
	}
	
	override public func delete(_ save: Bool = true, context: NSManagedObjectContext, completion: ((Error?) -> Void)) {
		hasTheme?.delete(save, context: context, completion: { error in
			super.delete(save, context: context, completion: completion)
		})
	}

	
//	var getTemp: Sheet {
//		let sheet: VSheet
//		switch self.type {
//		case .SheetTitleContent:
//			sheet = VSheetTitleContent()
//			if let sheet = sheet as? VSheetTitleContent, let current = self as? VSheetTitleContent {
//				sheet.content = current.content
//			}
//		case .SheetTitleImage:
//			sheet = VSheetTitleImage()
//			if let sheet = sheet as? VSheetTitleImage, let current = self as? VSheetTitleImage {
//				sheet.hasTitle = current.hasTitle
//				sheet.imageHasBorder = current.imageHasBorder
//				sheet.content = current.content
//				sheet.imageBorderColor = current.imageBorderColor
//				sheet.imageBorderSize = current.imageBorderSize
//				sheet.imagePath = current.imagePath
//				sheet.imageContentMode = current.imageContentMode
//			}
//		case .SheetPastors:
//			sheet = VSheetPastors()
//			if let sheet = sheet as? VSheetPastors, let current = self as? VSheetPastors {
//				sheet.content = current.content
//				sheet.imagePath = current.imagePath
//				sheet.thumbnailPath = current.thumbnailPath
//			}
//		case .SheetSplit:
//			sheet = VSheetSplit()
//			if let sheet = sheet as? VSheetSplit, let current = self as? VSheetSplit {
//				sheet.textLeft = current.textLeft
//				sheet.textRight = current.textRight
//			}
//		case .SheetEmpty:
//			sheet = VSheetEmpty()
//		case .SheetActivities:
//			sheet = VSheetActivities()
//			if let sheet = sheet as? VSheetActivities, let current = self as? VSheetActivities {
//				sheet.hasGoogleActivity = current.hasGoogleActivity
//			}
//		}
//		if self.hasTheme?.isHidden == true {
//			sheet.hasTheme = hasTheme?.getTemp()
//		}
//		sheet.title = title
//		sheet.deleteDate = NSDate()
//		sheet.time = time
//		sheet.position = position
//		sheet.isEmptySheet = isEmptySheet
//		return sheet
//	}
//	
//	func mergeSelfInto(sheet: Sheet, isTemp: NSDate? = nil) {
//		switch self.type {
//		case .SheetTitleContent:
//			let sheet = sheet as! SheetTitleContentEntity
//			let this = self as! SheetTitleContentEntity
//			sheet.content = this.content
//			
//		case .SheetTitleImage:
//			let sheet = sheet as! SheetTitleImageEntity
//			let this = self as! SheetTitleImageEntity
//			sheet.hasTitle = this.hasTitle
//			sheet.imageHasBorder = this.imageHasBorder
//			sheet.content = this.content
//			sheet.imageBorderColor = this.imageBorderColor
//			sheet.imageBorderSize = this.imageBorderSize
//			sheet.imagePath = this.imagePath
//			sheet.imageContentMode = this.imageContentMode
//			
//		case .SheetPastors:
//			let sheet = sheet as! SheetPastorsEntity
//			let this = self as! SheetPastorsEntity
//			sheet.content = this.content
//			sheet.imagePath = this.imagePath
//			sheet.thumbnailPath = this.thumbnailPath
//			
//		case .SheetSplit:
//			let sheet = sheet as! SheetSplitEntity
//			let this = self as! SheetSplitEntity
//			sheet.textLeft = this.textLeft
//			sheet.textRight = this.textRight
//			
//		case .SheetEmpty:
//			break
//		case .SheetActivities:
//			let sheet = sheet as! SheetActivitiesEntity
//			let this = self as! SheetActivitiesEntity
//			sheet.hasGoogleActivity = this.hasGoogleActivity
//		}
//		sheet.title = title
//		sheet.deleteDate = isTemp
//		sheet.time = time
//		sheet.position = position
//		sheet.isEmptySheet = isEmptySheet
//		print("merged sheet")
//	}
	
	public func isEqualTo(_ object: Any?) -> Bool {
		if let sheet = object as? Sheet {
			return self.id == sheet.id
		}
		return false
	}
}

extension Array where Element == Sheet {
    
    func getSheets(context: NSManagedObjectContext) -> [SheetMetaType] {
        let results: [SheetMetaType] = self.compactMap { sheet in
            if let sheet = sheet as? SheetTitleContentEntity, let mapped = SheetTitleContentCodable(managedObject: sheet, context: context) {
                return mapped
            }
            if let sheet = sheet as? SheetTitleImageEntity, let mapped = SheetTitleImageCodable(managedObject: sheet, context: context) {
                return mapped
            }
            if let sheet = sheet as? SheetEmptyEntity, let mapped = SheetEmptyCodable(managedObject: sheet, context: context) {
                return mapped
            }
            if let sheet = sheet as? SheetSplitEntity, let mapped = SheetSplitCodable(managedObject: sheet, context: context) {
                return mapped
            }
            if let sheet = sheet as? SheetPastorsEntity, let mapped = SheetPastorsCodable(managedObject: sheet, context: context) {
                return mapped
            }
            if let sheet = sheet as? SheetActivitiesEntity, let mapped = SheetActivitiesCodable(managedObject: sheet, context: context) {
                return mapped
            }
            return nil
        }
        return results
    }
    
}

extension Array where Element == SheetMetaType {
    
    func getThemes(context: NSManagedObjectContext) -> [ThemeCodable] {
        let results: [ThemeCodable] = self.compactMap { sheet in
            if let sheet = sheet as? SheetTitleContentEntity, let mapped = SheetTitleContentCodable(managedObject: sheet, context: context)?.hasTheme {
                return mapped
            }
            if let sheet = sheet as? SheetTitleImageEntity, let mapped = SheetTitleImageCodable(managedObject: sheet, context: context)?.hasTheme {
                return mapped
            }
            if let sheet = sheet as? SheetEmptyEntity, let mapped = SheetEmptyCodable(managedObject: sheet, context: context)?.hasTheme {
                return mapped
            }
            if let sheet = sheet as? SheetSplitEntity, let mapped = SheetSplitCodable(managedObject: sheet, context: context)?.hasTheme {
                return mapped
            }
            if let sheet = sheet as? SheetPastorsEntity, let mapped = SheetPastorsCodable(managedObject: sheet, context: context)?.hasTheme {
                return mapped
            }
            return nil
        }
        return results
    }
    
}
