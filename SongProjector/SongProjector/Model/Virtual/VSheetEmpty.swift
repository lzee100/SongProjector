//
//  VSheetEmpty.swift
//  SongProjector
//
//  Created by Leo van der Zee on 30/12/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import CoreData

class VSheetEmpty: VSheet, VSheetMetaType {
	
	static var type: SheetType = .SheetEmpty
    
	// MARK: - Encodable
	
	override public func encode(to encoder: Encoder) throws {
		try super.encode(to: encoder)
	}
	
	
	
	// MARK: - Decodable
	
	required public convenience init(from decoder: Decoder) throws {
				
		self.init()
		try super.initialization(decoder: decoder)
		
	}
	
	
	
	// MARK: - NSCopying
	
	public override func copy(with zone: NSZone? = nil) -> Any {
		let copy = super.copy(with: zone) as! VSheetEmpty
		return copy
	}
	
	
	
	override func setPropertiesTo(entity: Entity, context: NSManagedObjectContext) {
		super.setPropertiesTo(entity: entity, context: context)
	}
	
    override func getPropertiesFrom(entity: Entity, context: NSManagedObjectContext) {
        super.getPropertiesFrom(entity: entity, context: context)
	}
	
	convenience init(sheet: SheetEmptyEntity, context: NSManagedObjectContext) {
		self.init()
		getPropertiesFrom(entity: sheet, context: context)
	}

}
