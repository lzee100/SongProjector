//
//  DateFormatter.swift
//  SongProjector
//
//  Created by Leo van der Zee on 07/01/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation

class GlobalDateFormatter: NSObject {
//
//    func localToUTC(date:Date) -> String {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
//        dateFormatter.calendar = NSCalendar.current
//        dateFormatter.timeZone = TimeZone.current
//
//        let dt = dateFormatter.str
//        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
//        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
//
//        return dateFormatter.string(from: dt!)
//    }
//
//    func UTCToLocal(date:String) -> String {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
//        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
//
//        let dt = dateFormatter.date(from: date)
//        dateFormatter.timeZone = TimeZone.current
//        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
//
//        return dateFormatter.string(from: dt!)
//    }


//	static func localToUTCNumber(date:Date) -> String? {
//		let dateFormatter = DateFormatter()
//		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
//		dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
//
//		let stringDate = dateFormatter.string(from: date)
//		let new = localToUTCNumber(date: stringDate)
//		return new
//	}
//
//	static func UTCToLocalNumber(date:String) -> Date? {
//		let dateFormatter = DateFormatter()
//		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
//        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
//        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
//
//		let newDate = dateFormatter.date(from: date)
//		dateFormatter.locale = Locale(identifier: "en_US_POSIX")
//		dateFormatter.dateFormat = "dd-MM-yyyy'T'HH:mm:ss"
//		dateFormatter.timeZone = TimeZone.current
//		if let newDate = newDate {
//			let localString = dateFormatter.string(from: newDate)
//			dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
//			if let date = dateFormatter.date(from: localString) {
//				return date
//            } else {
//                return nil
//            }
//        } else {
//            return nil
//        }
//	}
//
//	private static func localToUTCNumber(date:String) -> String {
//	let dateFormatter = DateFormatter()
//		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
//	dateFormatter.calendar = NSCalendar.current
//	dateFormatter.timeZone = TimeZone.current
//
//	let dt = dateFormatter.date(from: date)
//	dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
//		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
//
//	return dateFormatter.string(from: dt!)
//	}
	
	
}
