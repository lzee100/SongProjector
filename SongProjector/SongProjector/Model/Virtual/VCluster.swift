//
//  VCluster.swift
//  SongProjector
//
//  Created by Leo van der Zee on 28/12/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import CoreData

public class VCluster: VEntity {

	class func list(sortOn attributeName: String? = nil, ascending: Bool? = nil) -> [VCluster] {
		if let attributeName = attributeName, let ascending = ascending {
			CoreCluster.setSortDescriptor(attributeName: attributeName, ascending: ascending)
		}
		return CoreCluster.getEntities().map({ VCluster(cluster: $0) })
	}
	
	class func single(with id: Int64?) -> VCluster? {
		if let id = id, let cluster = CoreCluster.getEntitieWith(id: id) {
			return VCluster(cluster: cluster)
		}
		return nil
	}
	
		
	var isLoop: Bool = false
	var position: Int16 = 0
	var time: Double = 0
	var themeId: Int64 = 0
	
	var hasInstruments: [VInstrument] = []
	var hasSheets: [VSheet] = []
	
	var tagIds: [NSNumber] = []
	
	var hasTheme: VTheme? {
		return VTheme.single(with: themeId)
	}
	
	var hasTags: [VTag] {
		return tagIds.compactMap({ VTag.single(with: Int64(exactly: $0)) })
	}
	
	public var isTypeSong: Bool {
		return !hasSheets.contains(where: { $0.hasTheme?.isHidden == true  })
	}
	
	public var hasPianoSolo: Bool {
		return hasInstruments.contains(where: { $0.type == .pianoSolo })
	}
	
	public var hasMusic: Bool {
		return hasInstruments.count > 0
	}

	private var clusterSheets: [SheetMetaType] {
		return hasSheets.compactMap({ $0 as? SheetMetaType })
	}
	
	
	enum CodingKeysCluster:String,CodingKey
	{
		case isLoop
		case position
		case time
		case theme = "theme"
		case themeId = "theme_id"
		case hasSheets = "sheets"
		case hasInstruments = "instruments"
		case hasTags = "tags"
	}
	
	
	
	// MARK: - Init
		
	public override func initialization(decoder: Decoder) throws {
		
	}
	
	
	
	// MARK: - Encodable
	
	override public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeysCluster.self)
		try container.encode(Int(truncating: NSNumber(value: isLoop)), forKey: .isLoop)
		try container.encode(position, forKey: .position)
		try container.encode(time, forKey: .time)
		try container.encode(hasTheme, forKey: .theme)
		try container.encode(clusterSheets.map(AnySheet.init), forKey: .hasSheets)
		try container.encode(hasInstruments, forKey: .hasInstruments)
		
		try container.encode(hasTags, forKey: .hasTags)

		try super.encode(to: encoder)
		
	}
	
	
	
	// MARK: - Decodable
	
	required public convenience init(from decoder: Decoder) throws {
		
		self.init()
		
		let container = try decoder.container(keyedBy: CodingKeysCluster.self)
		isLoop = try Bool(truncating: (container.decodeIfPresent(Int16.self, forKey: .isLoop) ?? 0) as NSNumber)
		position = try container.decodeIfPresent(Int16.self, forKey: .position) ?? 0
		time = try container.decodeIfPresent(Double.self, forKey: .time) ?? 0
		themeId = try container.decodeIfPresent(Int64.self, forKey: .themeId) ?? 0
		tagIds = try (container.decodeIfPresent([VTag].self, forKey: .hasTags)?.compactMap({ NSNumber(value: $0.id) }) ?? [])
		let metas = try container.decode([AnySheet].self, forKey: .hasSheets).map{ $0.base }
		
		var sheetUnsorted: [VSheet] = []
		metas.compactMap({ $0 as? VSheet }).forEach { (sheet) in
			if sheet is VSheetTitleContent {
				sheetUnsorted.append((sheet as! VSheetTitleContent))
			} else if sheet is VSheetTitleImage {
				sheetUnsorted.append((sheet as! VSheetTitleImage))
			} else if sheet is VSheetPastors {
				sheetUnsorted.append((sheet as! VSheetPastors))
			} else if sheet is VSheetSplit {
				sheetUnsorted.append((sheet as! VSheetSplit))
			} else if sheet is VSheetEmpty {
				sheetUnsorted.append((sheet as! VSheetEmpty))
			} else if sheet is VSheetActivities {
				sheetUnsorted.append((sheet as! VSheetActivities))
			}
		}
		hasSheets = sheetUnsorted.sorted(by: { $0.position < $1.position })
		
		let instr = try container.decodeIfPresent([VInstrument].self, forKey: .hasInstruments)
		if let instr = instr {
			hasInstruments = instr
		}
		
		try super.initialization(decoder: decoder)
		
	}
	
	public override func copy(with zone: NSZone? = nil) -> Any {
		let copy = super.copy(with: zone) as? Cluster
		copy?.isLoop = isLoop
		copy?.position = position
		copy?.time = time
		copy?.themeId = themeId
		
		copy?.hasInstruments = NSSet(array: hasInstruments.map({ $0.copy(with: zone) }))
		copy?.hasSheets = NSSet(array: hasSheets.map({ $0.copy(with: zone) }))
		copy?.tagIds = tagIds
		
		return copy!
	}
	
	override func getPropertiesFrom(entity: Entity) {
		super.getPropertiesFrom(entity: entity)
		if let cluster = entity as? Cluster {
			
			isLoop = cluster.isLoop
			position = Int16(cluster.position)
			time = cluster.time
			themeId = cluster.themeId
			
			hasInstruments = cluster.hasInstruments == nil ? [] : (cluster.hasInstruments!.allObjects as! [Instrument]).map({ VInstrument(entity: $0) })
			
			func getSheets(sheets: [Sheet]) -> [VSheet] {
				return sheets.map({
					if let sheet = $0 as? SheetTitleContentEntity {
						return VSheetTitleContent(entity: sheet) as VSheet
					} else if let sheet = $0 as? SheetTitleImageEntity {
						return VSheetTitleImage(entity: sheet) as VSheet
					} else if let sheet = $0 as? SheetSplitEntity {
						return VSheetSplit(entity: sheet) as VSheet
					} else if let sheet = $0 as? SheetPastorsEntity {
						return VSheetPastors(entity: sheet) as VSheet
					} else if let sheet = $0 as? SheetEmptyEntity {
						return VSheetEmpty(entity: sheet) as VSheet
					} else {
						return VSheet(entity: $0)
					}
				})
			}

			hasSheets = cluster.hasSheets == nil ? [] : getSheets(sheets: cluster.hasSheets!.allObjects as! [Sheet]).sorted(by: { $0.position < $1.position })
			tagIds = cluster.tagIds

		}
	}
	
	override func setPropertiesTo(entity: Entity, context: NSManagedObjectContext) {
		super.setPropertiesTo(entity: entity, context: context)
		if let cluster = entity as? Cluster {
			cluster.isLoop = isLoop
			cluster.position = Int16(position)
			cluster.time = time
			cluster.themeId = themeId
			cluster.hasInstruments = NSSet(array: hasInstruments.map({ $0.getManagedObject(context: context) }))
			if let sheets = cluster.hasSheets {
				cluster.removeFromHasSheets(sheets)
			}
			let sheets = NSSet(array: hasSheets.map({ $0.getManagedObject(context: context) }))
//			print((sheets.allObjects as! [Sheet]).compactMap({ $0.managedObjectContext == context }))
			cluster.addToHasSheets(sheets)
			cluster.tagIds = tagIds
		}
	}
	
	convenience init(cluster: Cluster) {
		self.init()
		getPropertiesFrom(entity: cluster)
	}
	
	override func getManagedObject(context: NSManagedObjectContext) -> Entity {
		
		
		CoreCluster.managedObjectContext = context
		if let storedEntity = CoreCluster.getEntitieWith(id: id) {
			CoreCluster.managedObjectContext = moc
			setPropertiesTo(entity: storedEntity, context: context)
			return storedEntity
		} else {
			CoreCluster.managedObjectContext = context
			let newEntity = CoreCluster.createEntityNOTsave()
			CoreCluster.managedObjectContext = moc
//			let entityDes = NSEntityDescription.entity(forEntityName: "Cluster", in: context)
//			let newEntity = NSManagedObject(entity: entityDes!, insertInto: context) as! Cluster

			setPropertiesTo(entity: newEntity, context: context)
			return newEntity
		}

	}
	
}
