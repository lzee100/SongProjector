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
	@NSManaged public var hasTheme: Theme?
	
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



