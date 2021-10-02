//
//  DataExtensions.swift
//  SongProjector
//
//  Created by Leo van der Zee on 10/02/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation


extension Data {
	func printToJson() {
		do {
			let json = try JSONSerialization.jsonObject(with: self, options: []) as Any
			let jsonString = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
			print(String(data: jsonString , encoding: .utf8 ) ?? "JSON to string not convertable")
		} catch {
			print("could not demap cluster with relation // see requester")
		}
	}

}
