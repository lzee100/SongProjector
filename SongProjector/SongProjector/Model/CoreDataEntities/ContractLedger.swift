//
//  ContractLedger.swift
//  SongProjector
//
//  Created by Leo van der Zee on 06/03/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import CoreData

class ContractLedger: Entity {
	
	@nonobjc public class func fetchRequest() -> NSFetchRequest<ContractLedger> {
		return NSFetchRequest<ContractLedger>(entityName: "ContractLedger")
	}
	
	@NSManaged public var contractId: String
	@NSManaged public var organizationId: String
	@NSManaged public var userName: String
	@NSManaged public var phoneNumber: String
	@NSManaged public var hasApplePay: Bool

    func hasOrganization(moc: NSManagedObjectContext) -> Organization? {
//        let organization: Organization? = DataFetcher().getEntity(moc: moc, predicates: [.get(id: organizationId)])
//        return organization
        return nil
    }
    func hasContract(moc: NSManagedObjectContext) -> Contract? {
//        let contract: Contract? = DataFetcher().getEntity(moc: moc, predicates: [.get(id: contractId)])
//        return contract
        return nil
    }
    
}
