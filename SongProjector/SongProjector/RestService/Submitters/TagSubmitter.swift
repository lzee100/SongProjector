//
//  TagSubmitter.swift
//  SongProjector
//
//  Created by Leo van der Zee on 25/03/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation

let TagSubmitter: TgSubmitter = {
	return TgSubmitter()
}()

class TgSubmitter: Requester<Tag> {
	
	
	override var requesterId: String {
		return "TagSubmitter"
	}
	
	override var path: String {
		return "tags"
	}
	
	override var coreDataManager: CoreDataManager<Tag> {
		return CoreTag
	}
	
}
