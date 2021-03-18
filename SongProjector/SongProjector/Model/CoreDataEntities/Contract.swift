//
//  Contract.swift
//  SongProjector
//
//  Created by Leo van der Zee on 23/02/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import CoreData

class Contract: Entity {
	
	@nonobjc public class func fetchRequest() -> NSFetchRequest<Contract> {
		return NSFetchRequest<Contract>(entityName: "Contract")
	}
	
	@NSManaged public var name: String
	@NSManaged public var buttonContent: String
    
}
