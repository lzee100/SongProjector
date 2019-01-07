//
//  VSheetPastorEntity.swift
//  SongProjector
//
//  Created by Leo van der Zee on 06/01/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation


class VSheetPastorEntity: VSheet {

	public var imagePath: String?
	public var thumbNailPath: String?


	
	
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





