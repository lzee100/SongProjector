//
//  Instrument.swift
//  SongProjector
//
//  Created by Leo van der Zee on 14/01/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation


import Foundation
import CoreData


public class Instrument: Entity {

	@nonobjc public class func fetchRequest() -> NSFetchRequest<Instrument> {
		return NSFetchRequest<Instrument>(entityName: "Instrument")
	}
	
	@NSManaged public var isLoop: Bool
	@NSManaged public var resourcePath: String?
	@NSManaged public var typeString: String?
	@NSManaged public var resourcePathAWS: String?
	
}
