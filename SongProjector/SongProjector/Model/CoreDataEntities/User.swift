//
//  User.swift
//  SongProjector
//
//  Created by Leo van der Zee on 16/02/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import CoreData


class User: Entity {
	
	@nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
		return NSFetchRequest<User>(entityName: "User")
	}
	
	@NSManaged public var firstName: String?
	@NSManaged public var lastName: String?
	@NSManaged public var appInstallToken: String?
	@NSManaged public var bankAccountNumber: String?
	@NSManaged public var bankAccountName: String?
	@NSManaged public var identifiedEmail: String?
	@NSManaged public var userToken: String?
	
	@NSManaged public var hasRole: Role?
	
	enum CodingKeysUser: String, CodingKey
	{
		case firstName
		case lastName
		case bankAccountName
		case bankAccountNumber
		case identifiedEmail
		case userToken
		case appInstallToken
		case hasRole = "role"
	}
	
	
	// MARK: - Init
	
	// encode and decode relation to cluster
	
	@objc
	override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
		super.init(entity: entity, insertInto: context)
	}
	
	public override func initialization(decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeysUser.self)
		firstName = try container.decodeIfPresent(String.self, forKey: .firstName)
		lastName = try container.decodeIfPresent(String.self, forKey: .lastName)
		bankAccountName = try container.decodeIfPresent(String.self, forKey: .bankAccountName)
		bankAccountNumber = try container.decodeIfPresent(String.self, forKey: .bankAccountNumber)
		identifiedEmail = try container.decodeIfPresent(String.self, forKey: .identifiedEmail)
		userToken = try container.decodeIfPresent(String.self, forKey: .userToken)
		appInstallToken = try container.decodeIfPresent(String.self, forKey: .appInstallToken)
		let roles = try container.decodeIfPresent([Role].self, forKey: .hasRole)
		if let role = roles?.first {
			self.hasRole = role
		}
		
		try super.initialization(decoder: decoder)
		
	}
	
	
	
	// MARK: - Encodable
	
	override public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeysUser.self)
		try container.encode(firstName, forKey: .firstName)
		try container.encode(lastName, forKey: .lastName)
		try container.encode(bankAccountName, forKey: .bankAccountName)
		try container.encode(bankAccountNumber, forKey: .bankAccountNumber)
		try container.encode(identifiedEmail, forKey: .identifiedEmail)
		try container.encode(userToken, forKey: .userToken)
		try container.encode(appInstallToken, forKey: .appInstallToken)
		if let role = hasRole {
			try container.encode([role], forKey: .hasRole)
		}
		
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
		firstName = try container.decodeIfPresent(String.self, forKey: .firstName)
		lastName = try container.decodeIfPresent(String.self, forKey: .lastName)
		bankAccountName = try container.decodeIfPresent(String.self, forKey: .bankAccountName)
		bankAccountNumber = try container.decodeIfPresent(String.self, forKey: .bankAccountNumber)
		identifiedEmail = try container.decodeIfPresent(String.self, forKey: .identifiedEmail)
		userToken = try container.decodeIfPresent(String.self, forKey: .userToken)
		appInstallToken = try container.decodeIfPresent(String.self, forKey: .appInstallToken)
		let roles = try container.decodeIfPresent([Role].self, forKey: .hasRole)
		if let role = roles?.first {
			self.hasRole = role
		}
		
		try super.initialization(decoder: decoder)
		
	}
	
	func mergeSelfInto(user: inout User) {
		user.firstName = self.firstName
		user.lastName = self.lastName
		user.bankAccountName = self.bankAccountName
		user.bankAccountNumber = self.bankAccountNumber
		user.appInstallToken = self.appInstallToken
		user.userToken = self.userToken
		user.identifiedEmail = self.identifiedEmail
		user.hasRole = self.hasRole
	}
	
}
