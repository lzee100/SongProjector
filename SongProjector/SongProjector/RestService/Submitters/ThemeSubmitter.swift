//
//  ThemeSubmitter.swift
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

let ThemeSubmitter: TmSubmitter = {
	return TmSubmitter()
}()

class TmSubmitter: Requester<Theme> {
	
	
	override var requesterId: String {
		return "ThemeSubmitter"
	}
	
	override var path: String {
		return "themes"
	}
	
	override var coreDataManager: CoreDataManager<Theme> {
		return CoreTheme
	}
	
}
