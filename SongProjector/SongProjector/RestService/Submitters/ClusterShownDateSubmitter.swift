//
//  ClusterShownDateSubmitter.swift
//  SongProjector
//
//  Created by Leo van der Zee on 23/02/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import Foundation
import CoreData

// does not work when you want to set a shown date for a universal cluster. If you create a user cluster, you don't have a theme for this cluster.....
let ClusterShownDateSubmitter = CsterShownDateSubmitter()

class CsterShownDateSubmitter: Requester<VClusterShownDate> {
	
	private var clusterIds: [String] = []
	
	override var requesterId: String {
		return "ClusterSubmitter"
	}

	override var path: String {
		return "clusters/shownDate"
	}
	
	override func additionalProcessing(_ context: NSManagedObjectContext, _ entities: [VClusterShownDate], completion: @escaping ((Requester<VClusterShownDate>.AdditionalProcessResult) -> Void)) {
		
		entities.forEach { (entity) in
			CoreCluster.managedObjectContext = context
			let cluster = VCluster.single(with: entity.id)
			cluster?.lastShownAt = entity.lastShownAt
			cluster?.createdAt = entity.createdAt
			cluster?.updatedAt = entity.updatedAt
			cluster?.deleteDate = entity.deleteDate
		}
	}
	
}

class VClusterShownDate: VEntity {
	
	var lastShownAt: Date? = nil
	
	enum CodingKeysCluster:String,CodingKey
	{
		case lastShownAt
	}
	
	convenience init(vCluster: VCluster) {
		self.init()
		self.id = vCluster.id
		self.title = vCluster.title
		self.createdAt = vCluster.createdAt
		self.updatedAt = vCluster.updatedAt
		self.deleteDate = vCluster.deleteDate
	}
	
	// MARK: - Init
		
	public override func initialization(decoder: Decoder) throws {
		
	}
	
	
	
	// MARK: - Encodable
	
	override public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeysCluster.self)
		if let lastShownAt = lastShownAt {
			let lastShownAtString = GlobalDateFormatter.localToUTC(date: lastShownAt as Date)
			try container.encode(lastShownAtString, forKey: .lastShownAt)
		}

		try super.encode(to: encoder)
		
	}
	
	
	
	// MARK: - Decodable
	
	required public convenience init(from decoder: Decoder) throws {
		
		self.init()
		
		let container = try decoder.container(keyedBy: CodingKeysCluster.self)
		lastShownAt = try decodeDate(container: container, forKey: .lastShownAt) as Date?
		
		try super.initialization(decoder: decoder)
		
	}
	
}
