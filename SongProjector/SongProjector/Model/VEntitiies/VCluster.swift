//
//  VCluster.swift
//  SongProjector
//
//  Created by Leo van der Zee on 06/01/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation

class VCluster: NSObject, Codable, NSCopying {
	
	static func getClusters(getHidden: Bool = false) -> [VCluster] {
		CoreCluster.predicates.append("isHidden", notEquals: !getHidden)
		return CoreCluster.getEntities().map({ VCluster.convert($0) })
	}
	
	static func getCluster(id: Int64) -> VCluster? {
		CoreCluster.predicates.append("id", equals: id)
		if let entity = CoreCluster.getEntities().first {
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
	public var position: Int16 = 0
	public var time: Double? = nil
	
	public var hasSheets: [VSheet] = []
	public var hasTheme: VTheme?
	public var hasInstruments: [VInstrument]

	
	
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
		case isLoop
		case position
		case time
	}
	
	static func convert(_ cluster: Cluster) -> VCluster {
		let vCluster = VCluster()
		vCluster.id = cluster.id
		vCluster.title = cluster.title
		vCluster.createdAt = cluster.createdAt ?? Date()
		vCluster.updatedAt = cluster.updatedAt ?? Date()
		vCluster.deletedAt = cluster.deletedAt
		vCluster.title = cluster.title
		
		return vCluster
	}
	
	func copy(with zone: NSZone? = nil) -> Any {
		let vCluster = VTheme()
		vCluster.id = id
		vCluster.title = title
		vCluster.createdAt = createdAt
		vCluster.updatedAt = updatedAt
		vCluster.deletedAt = deletedAt
		vCluster.title = title
		
		return vCluster
	}
	
	
}
