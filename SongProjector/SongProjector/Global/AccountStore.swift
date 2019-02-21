//
//  AccountStore.swift
//  SongProjector
//
//  Created by Leo van der Zee on 07/01/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import CloudKit

var AccountStore = AcStore()

class AcStore: NSObject {
	
	var icloudID: String {
		set {
			UserDefaults.standard.set(newValue, forKey: "icloudID")
		}
		get {
			return UserDefaults.standard.value(forKey: "icloudID") as? String ?? ""
		}
	}
	
}

class FetchIdOperation: AsynchronousOperation {
	
	var isSuccess: Bool {
		return error == nil
	}
	
	public private(set) var error : Error?

	override func main() {
		requestId()
	}
	
	func requestId() {
		if AccountStore.icloudID != "" {
			self.didFinish()
			return
		}
		let container = CKContainer.default()
		container.fetchUserRecordID() {
			recordID, error in
			AccountStore.icloudID = recordID?.recordName ?? ""
			if error != nil {
				print(error!.localizedDescription)
				self.didFail()
			} else {
				print("icloud name")
				print(recordID?.recordName ?? "")
				self.didFinish()
			}
		}
	}
	
	
}
