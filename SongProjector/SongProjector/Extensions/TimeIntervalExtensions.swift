//
//  TimeIntervalExtensions.swift
//  SongProjector
//
//  Created by Leo van der Zee on 10-01-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import Foundation

extension TimeInterval {
	static func seconds(_ n : Double) -> TimeInterval{
		return n
	}
	
	static func minutes(_ n : Double) -> TimeInterval{
		return n * seconds(60)
	}
	
	static func hours(_ n : Double) -> TimeInterval{
		return n * minutes(60)
	}
	
	static func days(_ n : Double) -> TimeInterval{
		return n * hours(24)
	}
	
	static func weeks(_ n : Double) -> TimeInterval{
		return n * days(7)
	}
	
	static func years(_ n : Double) -> TimeInterval{
		return n * days(365)
	}
	
}
