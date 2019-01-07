//
//  VSheet.swift
//  SongProjector
//
//  Created by Leo van der Zee on 06/01/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation


class VSheet: NSObject, Codable, NSCopying {
	
	static func getSheets(getHidden: Bool = false) -> [VSheet] {
		CoreSheet.predicates.append("isHidden", notEquals: !getHidden)
		return CoreSheet.getEntities().map({ VSheet.convert($0) })
	}
	
	static func getSheet(id: Int64) -> VSheet? {
		CoreSheet.predicates.append("id", equals: id)
		if let entity = CoreSheet.getEntities().first {
			return convert(entity)
		}
		return nil
	}
	
	
	public var id: Int64 = 0
	public var title: String? = ""
	public var createdAt: Date = Date()
	public var updatedAt: Date = Date()
	public var deletedAt: Date? = nil
	
	public var type: String = "SheetTitleContent"
	
	public var hasTheme: VTheme?
	public var hasCluster: VCluster?
	
	
	var trans: Text.Actions.Type {
		return Text.Actions.self
	}
	
	
	enum CodingKeys:String,CodingKey
	{
		case id
		case title
		case createdAt
		case updatedAt
		case deletedAt
		case type
		case hasTheme = "theme"
		case hasCluster = "cluster"
	}
	
	static func convert(_ sheet: Sheet) -> VSheet {
		let vSheet = VSheet()
		vSheet.id = sheet.id
		vSheet.title = sheet.title
		vSheet.createdAt = sheet.createdAt ?? Date()
		vSheet.updatedAt = sheet.updatedAt ?? Date()
		vSheet.deletedAt = sheet.deletedAt
		vSheet.title = sheet.title
		
		if let cluster = sheet.hasCluster {
			vSheet.hasCluster = VCluster.convert(cluster)
		}
		if let theme = sheet.hasTheme {
			vSheet.hasTheme = VTheme.convert(theme)
		}
		
		return vSheet
	}
	
	func copy(with zone: NSZone? = nil) -> Any {
		let vSheet = VSheet()
		vSheet.id = id
		vSheet.title = title
		vSheet.createdAt = createdAt
		vSheet.updatedAt = updatedAt
		vSheet.deletedAt = deletedAt
		vSheet.title = title
		
		return vSheet
	}
	
	
}

