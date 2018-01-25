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
	
	static let all = [SheetTitleContent, SheetTitleImage, SheetSplit, SheetEmpty]
	
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
		} else {
			return .SheetEmpty
		}
		
	}
	
	var emptySheet: Sheet {
		switch type {
		case .SheetTitleContent:
			return CoreSheetTitleContent.createEntityNOTsave()
		case .SheetTitleImage:
			return CoreSheetTitleImage.createEntityNOTsave()
		case .SheetSplit:
			return CoreSheetSplit.createEntityNOTsave()
		case .SheetEmpty:
			return CoreSheetEmptySheet.createEntityNOTsave()
		}
	}
	
	@objc open func delete() {
		if let tag = hasTag {
			tag.backgroundImage = nil
			let _ = CoreTag.delete(entity: tag)
		}
		_ = CoreSheet.delete(entity: self)
	}
	
}

extension SheetTitleImageEntity {
	override public func delete() {
		super.delete()
		image = nil
	}
}
