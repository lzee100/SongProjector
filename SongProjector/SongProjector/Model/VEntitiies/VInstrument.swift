//
//  VInstrument.swift
//  SongProjector
//
//  Created by Leo van der Zee on 06/01/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation


class VInstrument: NSObject, Codable {
	
	
	static func getInstrument(id: Int64) -> VSheet? {
		CoreInstrument.predicates.append("id", equals: id)
		if let entity = CoreInstrument.getEntities().first {
			return convert(entity)
		}
		return nil
	}
	
	
	public var id: Int64 = 0
	public var title: String? = ""
	public var createdAt: Date = Date()
	public var updatedAt: Date = Date()
	public var deletedAt: Date? = nil
	
	public var isLoop: Bool = false
	public var type: String = "Piano"
	public var resourcePath: String = ""
	
	public var hasCluster: VCluster?

	
	enum CodingKeys:String,CodingKey
	{
		case id
		case title
		case createdAt
		case updatedAt
		case deletedAt
		case isLoop
		case type
		case resourcePath

	}
	
	static func convert(_ instrument: Instrument) -> VInstrument {
		let vInstrument = VInstrument()
		vInstrument.id = instrument.id
		vInstrument.title = instrument.title
		vInstrument.createdAt = instrument.createdAt ?? Date()
		vInstrument.updatedAt = instrument.updatedAt ?? Date()
		vInstrument.deletedAt = instrument.deletedAt
		vInstrument.title = instrument.title
		
		if let cluster = instrument.hasCluster {
			vInstrument.hasCluster = VCluster.convert(cluster)
		}
	
		return vInstrument
	}
	
}
