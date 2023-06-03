//
//  VSheetTitleContent.swift
//  SongProjector
//
//  Created by Leo van der Zee on 28/12/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import CoreData

protocol VSheetMetaType: Codable {
    static var type: SheetType { get }
}

public class VSheetTitleContent: VSheet, VSheetMetaType, ObservableObject {
    
	
	static var type: SheetType = .SheetTitleContent
    
	var content: String?
    var isBibleVers = false
	
	enum CodingKeysTitleContent:String, CodingKey
	{
		case content
        case isBibleVers
	}
	
	
	
	// MARK: - Init
		
	public override func initialization(decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeysTitleContent.self)
		content = try container.decodeIfPresent(String.self, forKey: .content)
        isBibleVers = try container.decodeIfPresent(Bool.self, forKey: .isBibleVers) ?? false
	}
	
	
	
	// MARK: - Encode
	
	override public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeysTitleContent.self)
		try container.encode(content, forKey: .content)
        try container.encode(isBibleVers, forKey: .isBibleVers)
		try super.encode(to: encoder)
	}
	
	
	
	// MARK: - Decodable
	
	required public convenience init(from decoder: Decoder) throws {
				
		self.init()
		
		let container = try decoder.container(keyedBy: CodingKeysTitleContent.self)
		content = try container.decodeIfPresent(String.self, forKey: .content)
        isBibleVers = try container.decodeIfPresent(Bool.self, forKey: .isBibleVers) ?? false

		try super.initialization(decoder: decoder)
		
	}
	
	
	
	// MARK: - NSCopying

	public override func copy(with zone: NSZone? = nil) -> Any {
		let copy = super.copy(with: zone) as! VSheetTitleContent
		copy.content = content
        copy.isBibleVers = isBibleVers
		return copy
	}
	
    override func getPropertiesFrom(entity: Entity, context: NSManagedObjectContext) {
        super.getPropertiesFrom(entity: entity, context: context)
		if let sheet = entity as? SheetTitleContentEntity {
			content = sheet.content
            isBibleVers = sheet.isBibleVers
		}
	}
		
	override func setPropertiesTo(entity: Entity, context: NSManagedObjectContext) {
		super.setPropertiesTo(entity: entity, context: context)
		if let sheet = entity as? SheetTitleContentEntity {
			sheet.content = content
            sheet.isBibleVers = isBibleVers
		}
	}
	
    convenience init(sheetTitleContent: SheetTitleContentEntity, context: NSManagedObjectContext) {
		self.init()
		getPropertiesFrom(entity: sheetTitleContent, context: context)
	}

}
