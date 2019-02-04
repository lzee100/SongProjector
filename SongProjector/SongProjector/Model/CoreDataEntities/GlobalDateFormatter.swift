//
//  DateFormatter.swift
//  SongProjector
//
//  Created by Leo van der Zee on 07/01/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation

class GlobalDateFormatter: NSObject {

	
	static func localToUTC(date:Date) -> String? {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd' 'HH:mm:ss.SSS"
		dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

		let stringDate = dateFormatter.string(from: date)
		let new = localToUTC(date: stringDate)
		return new
	}
	
	static func UTCToLocal(date:String) -> Date? {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
		dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
		
		let newDate = dateFormatter.date(from: date)
		dateFormatter.locale = Locale(identifier: "en_US_POSIX")
		dateFormatter.dateFormat = "dd-MM-yyyy'T'HH:mm:ss"
		dateFormatter.timeZone = TimeZone.current
		if let newDate = newDate {
			let localString = dateFormatter.string(from: newDate)
			dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
			if let date = dateFormatter.date(from: localString) {
				return date
			}
		}
		return nil
	}
	
	private static func localToUTC(date:String) -> String {
	let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd' 'HH:mm:ss.SSS"
	dateFormatter.calendar = NSCalendar.current
	dateFormatter.timeZone = TimeZone.current
	
	let dt = dateFormatter.date(from: date)
	dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
		dateFormatter.dateFormat = "yyyy-MM-dd' 'HH:mm:ss.SSS"

	return dateFormatter.string(from: dt!)
	}
	
	
}
