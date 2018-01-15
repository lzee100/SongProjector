//
//  SheetExtensions.swift
//  SongProjector
//
//  Created by Leo van der Zee on 11-01-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import Foundation

public enum SheetType {
	case SheetTitleContent
	case SheetTitleImage
	case SheetEmpty
}

extension Sheet {
	

		
	var type: SheetType {
		if self.entity.isKindOf(entity: SheetTitleContentEntity.entity()){
			return .SheetTitleContent
		} else if self.entity.isKindOf(entity: SheetTitleImageEntity.entity()) {
			return .SheetTitleImage
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
		case .SheetEmpty:
			return CoreSheetEmptySheet.createEntityNOTsave()
		}
	}
	
}
