//
//  VSheetPastors.swift
//  SongProjector
//
//  Created by Leo van der Zee on 30/12/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class VSheetPastors: VSheet, VSheetMetaType {
	
	static var type: SheetType = .SheetPastors
	
	var content: String? = nil
	var imagePath: String? = nil
	var thumbnailPath: String? = nil
	var imagePathAWS: String? = nil
	var thumbnailPathAWS: String? = nil
    
    var tempSelectedImage: UIImage? {
        didSet {
            tempSelectedImageThumbNail = tempSelectedImage?.resized(withPercentage: 0.5)
        }
    }
    var tempSelectedImageThumbNail: UIImage?
    var isTempSelectedImageDeleted = false
    var tempLocalImageName: String?
    
    var hasNewRemoteImage: Bool {
        if let imagePathAWS = imagePathAWS {
            if
                let imagePath = imagePath,
                let url = URL(string: imagePath),
                let remoteURL = URL(string: imagePathAWS),
                url.lastPathComponent == remoteURL.lastPathComponent
            {
                return false
            } else {
                return true
            }
        } else {
            return false
        }
    }
    

	// not saving image path local
	enum CodingKeysPastors:String,CodingKey
	{
		case content
		case imagePath
		case thumbnailPath
		case imagePathAWS
	}
	
	
	
	// MARK: - Encodable

	override public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeysPastors.self)
		try container.encode(content, forKey: .content)
		try container.encode(imagePathAWS, forKey: .imagePathAWS)
		try super.encode(to: encoder)
	}
	

	
	// MARK: - Decodable
	
	required public convenience init(from decoder: Decoder) throws {
		self.init()
		
		let container = try decoder.container(keyedBy: CodingKeysPastors.self)

		content = try container.decodeIfPresent(String.self, forKey: .content)
		// FixMe: delete image paths local
		imagePathAWS = try container.decodeIfPresent(String.self, forKey: .imagePathAWS)
		
		try super.initialization(decoder: decoder)
		
	}
	
	
	// MARK: - NSCopying
	
	public override func copy(with zone: NSZone? = nil) -> Any {
		let copy = super.copy(with: zone) as! VSheetPastors
		copy.content = content
		copy.imagePath = imagePath
		copy.thumbnailPath = thumbnailPath
		copy.imagePathAWS = imagePathAWS
		copy.thumbnailPathAWS = thumbnailPathAWS
		return copy
	}
	
	
	
	override func setPropertiesTo(entity: Entity, context: NSManagedObjectContext) {
		super.setPropertiesTo(entity: entity, context: context)
		if let sheet = entity as? SheetPastorsEntity {
			sheet.content = self.content
			sheet.imagePath = self.imagePath
			sheet.thumbnailPath = self.thumbnailPath
			if imagePathAWS == nil {
				sheet.imagePath = nil
				sheet.thumbnailPath = nil
			}
			sheet.imagePathAWS = self.imagePathAWS
		}
	}
	
    override func getPropertiesFrom(entity: Entity, context: NSManagedObjectContext) {
        super.getPropertiesFrom(entity: entity, context: context)
		if let sheet = entity as? SheetPastorsEntity {
			content = sheet.content
			imagePath = sheet.imagePath
			thumbnailPath = sheet.thumbnailPath
			imagePathAWS = sheet.imagePathAWS
		}
	}
	
	convenience init(sheet: SheetPastorsEntity, context: NSManagedObjectContext) {
		self.init()
        getPropertiesFrom(entity: sheet, context: context)
	}
	
    override func getManagedObject(context: NSManagedObjectContext) -> Entity {
        if let entity: SheetPastorsEntity = DataFetcher().getEntity(moc: context, predicates: [.get(id: id)]) {
            setPropertiesTo(entity: entity, context: context)
            return entity
        } else {
            let entity: SheetPastorsEntity = DataFetcher().createEntity(moc: context)
            setPropertiesTo(entity: entity, context: context)
            return entity
        }
    }

	

}
