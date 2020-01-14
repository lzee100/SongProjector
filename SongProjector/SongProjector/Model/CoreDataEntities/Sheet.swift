//
//  Sheet.swift
//  SongProjector
//
//  Created by Leo van der Zee on 14/01/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation



import Foundation
import CoreData

protocol SheetMetaType : Codable {
	static var type: SheetType { get }
}

public class Sheet: Entity {
	
	
	@nonobjc public class func fetchRequest() -> NSFetchRequest<Sheet> {
		return NSFetchRequest<Sheet>(entityName: "Sheet")
	}
	
	@NSManaged public var isEmptySheet: Bool
	@NSManaged public var position: Int16
	@NSManaged public var time: Double
	@NSManaged public var hasCluster: Cluster?
	@NSManaged public var hasTheme: Theme?
	
	enum CodingKeysTheme:String,CodingKey
	{
		case isEmptySheet
		case position
		case time
		case hasCluster = "cluster"
		case hasTheme = "theme"
	}
	
	
	// MARK: - Init
	
	// encode and decode relation to cluster
	
	@objc
	override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
		super.init(entity: entity, insertInto: context)
	}
	
	public override func initialization(decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeysTheme.self)
		isEmptySheet = try Bool(truncating: (container.decodeIfPresent(Int16.self, forKey: .isEmptySheet) ?? 0) as NSNumber)
		position = try container.decodeIfPresent(Int16.self, forKey: .position) ?? 0
		time = try container.decodeIfPresent(Double.self, forKey: .time) ?? 0
		hasTheme = try container.decodeIfPresent(Theme.self, forKey: .hasTheme)
		
		try super.initialization(decoder: decoder)
		
	}
	
	
	
	// MARK: - Encodable
	
	override public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeysTheme.self)
		try container.encode(Int(truncating: NSNumber(value: isEmptySheet)), forKey: .isEmptySheet)
		try container.encode(position, forKey: .position)
		if hasTheme != nil {
			try container.encode(hasTheme, forKey: .hasTheme)
		}

		try super.encode(to: encoder)
	}
	
	
	
	// MARK: - Decodable
	
	required public convenience init(from decoder: Decoder) throws {
		
		let managedObjectContext = mocBackground
		guard let entity = NSEntityDescription.entity(forEntityName: "Sheet", in: managedObjectContext) else {
			fatalError("failed at Sheet")
		}
		
		self.init(entity: entity, insertInto: managedObjectContext)
		//		try self.init(from: decoder)
		
		let container = try decoder.container(keyedBy: CodingKeysTheme.self)
		
		
		
		
		
		isEmptySheet = try Bool(truncating: (container.decodeIfPresent(Int16.self, forKey: .isEmptySheet) ?? 0) as NSNumber)
		position = try container.decodeIfPresent(Int16.self, forKey: .position) ?? 0
		time = try container.decodeIfPresent(Double.self, forKey: .time) ?? 0
		hasTheme = try container.decodeIfPresent(Theme.self, forKey: .hasTheme)
		
		try super.initialization(decoder: decoder)
		
	}
	
	
	
	// MARK: - NSCopying

	public override func copy(with zone: NSZone? = nil) -> Any {
		let entity = CoreSheet.createEntityNOTsave()
		for key in self.entity.propertiesByName.keys {
			if key != "id" {
				let value: Any? = self.value(forKey: key)
				entity.setValue(value, forKey: key)
			}
		}
		deleteDate = Date() as NSDate
		return entity
	}
	
	
}



struct AnySheet : Codable {
	
	var base: SheetMetaType
	
	init(_ base: SheetMetaType) {
		self.base = base
	}
	
	private enum CodingKeys : CodingKey {
		case type, base
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		let type = try container.decode(VSheetType.self, forKey: .type)
		switch type {
		case .SheetTitleContent: try self.base = VSheetTitleContent.init(from: decoder) as SheetMetaType
		case .SheetTitleImage: try self.base = VSheetTitleImage.init(from: decoder) as SheetMetaType
		case .SheetPastors: try self.base = VSheetPastors.init(from: decoder) as SheetMetaType
		case .SheetSplit: try self.base = VSheetSplit.init(from: decoder) as SheetMetaType
		case .SheetEmpty: try self.base = VSheetEmpty.init(from: decoder) as SheetMetaType
		case .SheetActivities: try self.base = VSheetActivities.init(from: decoder) as SheetMetaType
		}
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(type(of: base).type, forKey: .type)
		try base.encode(to: encoder)
	}
}



