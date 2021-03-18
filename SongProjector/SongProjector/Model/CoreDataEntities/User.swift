//
//  User.swift
//  SongProjector
//
//  Created by Leo van der Zee on 16/02/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class User: Entity {
	
	@nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
		return NSFetchRequest<User>(entityName: "User")
	}
	
	@NSManaged public var appInstallTokens: String?
    @NSManaged public var sheetTimeOffset: String
    @NSManaged public var adminCode: String?
    @NSManaged public var adminInstallTokenId: String?
    @NSManaged public var googleCalendarId: String?
    
}
