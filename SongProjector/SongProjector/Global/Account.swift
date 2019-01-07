//
//  Account.swift
//  SongProjector
//
//  Created by Leo van der Zee on 06/01/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import CloudKit

let AccountStore = Account()

class Account: NSObject {
	
	var accountID: String = ""
	
	
	/// async gets iCloud record name of logged-in user
	func iCloudUserIDAsync(complete: @escaping (_ instance: CKRecordID?, _ error: Error?) -> ()) {
		let container = CKContainer.default()
		container.fetchUserRecordID() {
			recordID, error in
			if error != nil {
				print(error!.localizedDescription)
				complete(nil, error)
			} else {
				print("fetched ID \(recordID?.recordName ?? "no record name")")
				complete(recordID, nil)
			}
		}
	}
	
	override init() {
		iCloudUserIDAsync(complete: { (id, error) in
			self.accountID = id?.recordName ?? ""
		})
	}
}
