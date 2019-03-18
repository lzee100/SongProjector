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
	
	@NSManaged public var appInstallToken: String?
	@NSManaged public var userToken: String?
	@NSManaged public var inviteToken: String?
	@NSManaged public var roleId: Int64
	
	
	var hasRole: Role? {
		return CoreRole.getEntitieWith(id: roleId)
	}
	
	enum CodingKeysUser: String, CodingKey
	{
		case identifiedEmail
		case userToken
		case appInstallToken
		case inviteToken
		case roleId
	}
	
	var isMe: Bool {
		return userToken == AccountStore.icloudID
	}
	
	// MARK: - Init
	
	// encode and decode relation to cluster
	
	@objc
	override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
		super.init(entity: entity, insertInto: context)
	}
	
	public override func initialization(decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeysUser.self)
		userToken = try container.decodeIfPresent(String.self, forKey: .userToken)
		appInstallToken = try container.decodeIfPresent(String.self, forKey: .appInstallToken)
		inviteToken = try container.decodeIfPresent(String.self, forKey: .inviteToken)
		roleId = try container.decode(Int64.self, forKey: .roleId)

		try super.initialization(decoder: decoder)
		
	}
	
	
	
	// MARK: - Encodable
	
	override public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeysUser.self)
		try container.encode(userToken, forKey: .userToken)
		try container.encode(appInstallToken, forKey: .appInstallToken)
		try container.encode(inviteToken, forKey: .inviteToken)
		try container.encode(roleId, forKey: .roleId)
		
		try super.encode(to: encoder)
	}
	
	
	
	// MARK: - Decodable
	
	required public convenience init(from decoder: Decoder) throws {
		
		let managedObjectContext = mocBackground
		guard let entity = NSEntityDescription.entity(forEntityName: "User", in: managedObjectContext) else {
			fatalError("failed at User")
		}
		
		self.init(entity: entity, insertInto: managedObjectContext)
		
		let container = try decoder.container(keyedBy: CodingKeysUser.self)
		userToken = try container.decodeIfPresent(String.self, forKey: .userToken)
		appInstallToken = try container.decodeIfPresent(String.self, forKey: .appInstallToken)
		inviteToken = try container.decodeIfPresent(String.self, forKey: .inviteToken)
		roleId = try container.decode(Int64.self, forKey: .roleId)
		
		try super.initialization(decoder: decoder)
		
	}
	
	func mergeSelfInto(user: inout User) {
		user.appInstallToken = self.appInstallToken
		user.userToken = self.userToken
		user.roleId = self.roleId
	}
	
}
