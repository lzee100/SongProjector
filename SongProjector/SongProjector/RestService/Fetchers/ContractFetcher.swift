//
//  ContractFetcher.swift
//  SongProjector
//
//  Created by Leo van der Zee on 23/02/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation

let ContractFetcher: CntractFetcher = {
	return CntractFetcher()
}()

class CntractFetcher: Requester<Contract> {
	
	
	override var requestReloadTime: RequesterReloadTime {
		return .seconds
	}

	override var requesterId: String {
		return "ContractFetcher"
	}

	override var path: String {
		return "contracts"
	}

	override var coreDataManager: CoreDataManager<Contract> {
		return CoreContract
	}

	override var params: [String : Any] {
		return userParams
	}

	private var userParams: [String : Any] = [:]

	func fetch(locale: String) {
		CoreContract.setSortDescriptor(attributeName: "id", ascending: true)
		CoreContract.getEntities(onlyDeleted: false, skipFilter: true).forEach({ moc.delete($0) })
		do {
			try moc.save()
		} catch {
			print(error)
		}
		userParams = ["locale": locale]
		requestMethod = .get
		request(force: true)
	}

}
