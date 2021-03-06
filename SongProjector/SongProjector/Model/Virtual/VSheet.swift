//
//  VSheet.swift
//  SongProjector
//
//  Created by Leo van der Zee on 28/12/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import CoreData

public class VSheet: VEntity {
	
    var isNew: Bool {
        return updatedAt == nil
    }
	var isEmptySheet = false
	var position: Int = 0
	var time: Double = 0
	var hasTheme: VTheme? = nil
	
	enum CodingKeysTheme:String,CodingKey
	{
        case id
		case isEmptySheet
		case position
		case time
		case hasCluster = "cluster"
		case hasTheme = "theme"
	}
	
	var type: SheetType {
		if self is VSheetTitleContent {
			return .SheetTitleContent
		} else if self is VSheetTitleImage {
			return .SheetTitleImage
		} else if self is VSheetSplit {
			return .SheetSplit
		} else if self is VSheetPastors {
			return .SheetPastors
		} else if self is VSheetActivities {
			return .SheetActivities
		} else {
			return .SheetEmpty
		}
	}
	
	
	// MARK: - Init
	
	// encode and decode relation to cluster
	
	override init() {
		super.init()
	}
	
	public override func initialization(decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeysTheme.self)
		isEmptySheet = try Bool(truncating: (container.decodeIfPresent(Int16.self, forKey: .isEmptySheet) ?? 0) as NSNumber)
		position = Int(try container.decodeIfPresent(Int16.self, forKey: .position) ?? 0)
        let sheetTimeString = try container.decodeIfPresent(String.self, forKey: .time) ?? ""
        time = Double(sheetTimeString) ?? 0.0
		hasTheme = try container.decodeIfPresent(VTheme.self, forKey: .hasTheme)
		
		try super.initialization(decoder: decoder)
		
	}
	
	
	
	// MARK: - Encodable
	
	override public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeysTheme.self)
		try container.encode(Int(truncating: NSNumber(value: isEmptySheet)), forKey: .isEmptySheet)
		try container.encode(position, forKey: .position)
        try container.encode(id, forKey: .id)
        try container.encode(time.stringValue, forKey: .time)
		if hasTheme != nil {
			try container.encode(hasTheme, forKey: .hasTheme)
		}

		try super.encode(to: encoder)
	}
	
	
	
	// MARK: - Decodable
	
	required public convenience init(from decoder: Decoder) throws {
		
		self.init()
		
		let container = try decoder.container(keyedBy: CodingKeysTheme.self)
		
		isEmptySheet = try Bool(truncating: (container.decodeIfPresent(Int16.self, forKey: .isEmptySheet) ?? 0) as NSNumber)
		position = try container.decodeIfPresent(Int.self, forKey: .position) ?? 0
        let sheetTimeString = try container.decodeIfPresent(String.self, forKey: .time) ?? ""
        time = Double(sheetTimeString) ?? 0.0
		hasTheme = try container.decodeIfPresent(VTheme.self, forKey: .hasTheme)
		
		try super.initialization(decoder: decoder)
		
	}
	
	public func isEqualTo(_ object: Any?) -> Bool {
		if let sheet = object as? Sheet {
			return self.id == sheet.id
		}
		return false
	}
	
	
	// MARK: - NSCopying

	public override func copy(with zone: NSZone? = nil) -> Any {
		let copy = super.copy(with: zone) as! VSheet
		copy.isEmptySheet = isEmptySheet
		copy.position = position
		copy.time = time
		copy.hasTheme = hasTheme?.copy() as? VTheme
		return copy
	}
	
    override func getPropertiesFrom(entity: Entity, context: NSManagedObjectContext) {
        super.getPropertiesFrom(entity: entity, context: context)
		if let sheet = entity as? Sheet {
			isEmptySheet = sheet.isEmptySheet
			position = Int(sheet.position)
			time = sheet.time
            hasTheme = sheet.hasTheme == nil ? nil : VTheme(theme: sheet.hasTheme!, context: context)
		}
	}
	
	override func setPropertiesTo(entity: Entity, context: NSManagedObjectContext) {
		super.setPropertiesTo(entity: entity, context: context)
		if let sheet = entity as? Sheet {
			sheet.isEmptySheet = isEmptySheet
			sheet.position = Int16(position)
			sheet.time = time
			sheet.hasTheme = hasTheme?.getManagedObject(context: context) as? Theme
		}
	}
	
	convenience init(sheet: Sheet, context: NSManagedObjectContext) {
		self.init()
		getPropertiesFrom(entity: sheet, context: context)
	}
	
    override func getManagedObject(context: NSManagedObjectContext) -> Entity {
        if let entity: Cluster = DataFetcher().getEntity(moc: context, predicates: [.get(id: id)]) {
            setPropertiesTo(entity: entity, context: context)
            return entity
        } else {
            let entity: Cluster = DataFetcher().createEntity(moc: context)
            setPropertiesTo(entity: entity, context: context)
            return entity
        }
    }
	
	
}
