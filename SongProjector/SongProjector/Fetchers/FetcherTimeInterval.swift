//
//  FetcherTimeInterval.swift
//  SongProjector
//
//  Created by Leo van der Zee on 28-01-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import Foundation

struct RefreshInterval{
	static var immediately : Date{
		return date(TimeInterval.seconds(1))
	}
	static var extremeShort : Date{
		return date(TimeInterval.minutes(10))
	}
	static var short : Date{
		return date(TimeInterval.minutes(30))
	}
	static var medium : Date{
		return date(TimeInterval.hours(1))
	}
	static var long : Date{
		return date(TimeInterval.days(1))
	}
	
	fileprivate static func date(_ interval : Foundation.TimeInterval) -> Date {
		return Date().addingTimeInterval(-interval)
	}
}
