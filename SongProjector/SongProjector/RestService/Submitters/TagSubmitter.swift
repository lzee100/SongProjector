//
//  TagSubmitter.swift
//  SongProjector
//
//  Created by Leo van der Zee on 10/01/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

struct SubmittedID: Codable {
	let id: Int64
	
	private enum CodingKeys: String, CodingKey {
		case id
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		id = try container.decode(Int64.self, forKey: .id)
	}
	
}

let TagSubmitter = TgSubmitter()

class TgSubmitter: Requester<Tag, SubmittedID> {
	
	
	override var requesterId: String {
		return "TagSubmitter"
	}
	
	override var path: String {
		switch requestMethod {
		case .get, .post:
			return "themes/"
		case .put, .delete:
			if let id = body?.id {
				return "themes/\(id)"
			}
			return ""
		}
	}
	
	override var coreDataManager: CoreDataManager<Tag> {
		return CoreTag
	}
	
	override func saveLocal(entities: [Tag]?) {
		
		super.saveLocal(entities: entities)
	}
	
	
}
