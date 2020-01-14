//
//  VUser.swift
//  SongProjector
//
//  Created by Leo van der Zee on 02/01/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import Foundation
import CoreData

class VUser: VEntity {
		
	class func list(sortOn attributeName: String? = nil, ascending: Bool? = nil) -> [VUser] {
		if let attributeName = attributeName, let ascending = ascending {
			CoreUser.setSortDescriptor(attributeName: attributeName, ascending: ascending)
		}
		return CoreUser.getEntities().map({ VUser(user: $0) })
	}
	
	class func single(with id: Int64?) -> VUser? {
		if let id = id, let user = CoreUser.getEntitieWith(id: id) {
			return VUser(user: user)
		}
		return nil
	}
	
	var appInstallToken: String? = nil
	var userToken: String? = nil
	 
	var inviteToken: String? = nil
	var roleId: Int64 = 0
	
	
	var hasRole: VRole? {
		if let role = CoreRole.getEntitieWith(id: roleId) {
			return VRole(entity: role)
		}
		return nil
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
		
		self.init()
		
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
		user.inviteToken = self.inviteToken
		user.roleId = self.roleId
	}
	
	override func setPropertiesTo(entity: Entity, context: NSManagedObjectContext) {
		super.setPropertiesTo(entity: entity, context: context)
		if let user = entity as? User {
			user.appInstallToken = self.appInstallToken
			user.userToken = self.userToken
			user.inviteToken = self.inviteToken
			user.roleId = self.roleId
		}
	}
	
	override func getPropertiesFrom(entity: Entity) {
		super.getPropertiesFrom(entity: entity)
		if let user = entity as? User {
			appInstallToken = user.appInstallToken
			userToken = user.userToken
			inviteToken = user.inviteToken
			roleId = user.roleId
		}
	}
	
	convenience init(user: User) {
		self.init()
		getPropertiesFrom(entity: user)
	}
	
	override func getManagedObject(context: NSManagedObjectContext) -> Entity {
		
		CoreUser.managedObjectContext = context
		if let storedEntity = CoreUser.getEntitieWith(id: id) {
			CoreUser.managedObjectContext = moc
			setPropertiesTo(entity: storedEntity, context: context)
			return storedEntity
		} else {
			CoreUser.managedObjectContext = context
			let newEntity = CoreUser.createEntityNOTsave()
			CoreUser.managedObjectContext = moc
			setPropertiesTo(entity: newEntity, context: context)
			return newEntity
		}

	}

	
}
