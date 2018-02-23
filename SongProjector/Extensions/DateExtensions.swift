//
//  DateExtensions.swift
//  SongProjector
//
//  Created by Leo van der Zee on 28-01-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import Foundation

extension Date {
	
	var isThisWeek: Bool {
		let endOfThisWeek = Date().addingTimeInterval(.days(7))
		return self < endOfThisWeek
	}
	
	var isNextWeek: Bool {
		let nextWeekBeginning = Date().addingTimeInterval(.days(7))
		let nextWeekEnding = Date().addingTimeInterval(.days(14))
		return self > nextWeekBeginning && self < nextWeekEnding
	}
	
	var toString: String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "d MMMM hh:mm"
		return dateFormatter.string(from: self)
	}
	
	
}
