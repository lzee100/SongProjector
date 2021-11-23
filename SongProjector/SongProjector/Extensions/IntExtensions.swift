//
//  IntExtensions.swift
//  SongProjector
//
//  Created by Leo van der Zee on 16/01/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation


extension Int {
	
	var stringValue: String {
		return "\(self)"
	}

}

extension Int64 {
	var stringValue: String {
		return "\(self)"
	}
}

extension Int16 {
    var stringValue: String {
        return "\(self)"
    }
    var intValue: Int {
        return Int(self)
    }
}
