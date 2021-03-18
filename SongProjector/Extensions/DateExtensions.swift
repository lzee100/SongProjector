//
//  DateExtensions.swift
//  SongProjector
//
//  Created by Leo van der Zee on 28-01-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import Foundation

extension NSDate {
	var date: Date {
		return self as Date
	}
}

extension Date {
	
	// MARK: - Properties
	
	public var nsDate : NSDate {
		return self as NSDate
	}
	
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
		dateFormatter.dateFormat = "d MMMM HH:mm"
		return dateFormatter.string(from: self)
	}
	
	var time: String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "HH:mm"
		return dateFormatter.string(from: self)
	}
	
	
	// MARK: - Construction
	
	
	/// Constructs a date from the given components.
	public init(components: DateComponents) {
		
		self = Calendar.current.date(from: components) ?? Date()
		
	}
	
	public init(year:Int, month:Int, day:Int, hour:Int, minute:Int, second:Int) {
		
		var components = DateComponents()
		components.hour = hour
		components.minute = minute
		components.second = second
		components.day = day
		components.month = month
		components.year = year
		components.timeZone = .current
		
		self = Date(components: components)
		
	}
	
	public init(day: Int, month: Month, year: Int) {
		
		var components = DateComponents()
		
		components.day = day
		components.month = month.rawValue
		components.year = year
		
		self = Date(components: components)
		
	}
	
	
	// MARK: - Properties
	
	/// A date representing today at midnight.
	public static var today : Date {
		
		return now.dateMidnight
		
	}
	
	/// A date representing the day and time right now.
	public static var now : Date {
		return Date()
		
	}
	
	/// A date representing tomorrow at midnight.
	public static var tomorrow : Date {
		
		return today.dateDayAfter
		
	}
	
	/// A date representing yesterday at midnight.
	public static var yesterday : Date {
		
		return today.dateDayBefore
		
	}
	
	private var preserveDate : Set<Calendar.Component> {
		
		return [.month, .day, .year]
		
	}
	
	public var timeClass :Time {
		
		return Time(h: hour, m: minute, s: second)
		
	}
	
	/// The components of this date.
	public var components : DateComponents {
		
		return Calendar.current.dateComponents(preserveDate.union([.timeZone]), from: self)
		
	}
	
	public var hour : Int {
		
		return component(.hour)
		
	}
	
	public var minute : Int {
		
		return component(.minute)
		
	}
	
	public var second : Int {
		
		return component(.second)
		
	}
	
	public var weekday : Weekday {
		
		return Weekday(component: component(.weekday))
		
	}
	
	public var dayOfWeek : Weekday {
		
		return weekday
		
	}
    
    public var dayOfWeekNumber: Int {
        switch weekday {
        case .monday: return 1
        case .tuesday: return 2
        case .wednesday: return 3
        case .thursday: return 4
        case .friday: return 5
        case .saturday: return 6
        case .sunday: return 7
        case .unknown: return 0
        }
    }
	
	public var weekOfYear : Int {
		return component(.weekOfYear)
	}
	
	public var day : Int {
		
		return component(.day)
		
	}
	
	public var dayOfMonth : Int {
		
		return day
		
	}
	
	public var month : Month {
		
		return Month(component: component(.month))
		
	}
	
	public var year : Int {
		
		return component(.year)
		
	}
	
	public var isWeekday : Bool {
		
		let weekday = self.weekday
		return weekday != .saturday && weekday != .sunday
		
	}
	
	/// A flag indicating whether the date is in a leap year.
	public var isLeapYear : Bool {
		
		let year = self.year
		return year % 400 == 0 ? true : ((year % 4 == 0) && (year % 100 != 0))
		
	}
	
	/// A flag indicating whether the date is on a leap day.
	public var isLeapDay : Bool {
		
		return isLeapYear && isOn(day: 29, month: .february)
		
	}
	
	/// A flag indicating whether the date lies in the past.
	public var isInPast:Bool {
		
		return isBefore(Date.now)
	}
	
	/// A flag indicating whether the date is today.
	public var isToday : Bool {
		
		let today = Date.today
		let midnight = dateMidnight
		
		return today.day == midnight.day && today.month == midnight.month && today.year == midnight.year
		
	}
	
	/// A flag indicating whether the date lies in the future.
	public var isInFuture : Bool {
		
		return isAfter(Date.now)
	}
	
	public var isTodayOrInFuture : Bool {
		
		return isToday || isInFuture
		
	}
	
	/// The date one day before at midnight.
	public var dateDayBefore : Date {
		
		return dateByAddingDays(-1).dateMidnight
		
	}
	
	/// The date and time one second before the day after.
	public var dateSecondBeforeDayAfter : Date {
		
		return dateMidnight.dateDayAfter.dateByAddingSeconds(-1)
		
	}
	
	/// The date one day after at midnight.
	public var dateDayAfter : Date {
		
		return dateByAddingDays(1).dateMidnight
		
	}
	
	/// The date one week before at midnight.
	public var dateWeekBefore : Date {
		
		return dateByAddingWeeks(-1).dateMidnight
		
	}
	
	/// The date one week after at midnight.
	public var dateWeekAfter : Date {
		
		return dateByAddingWeeks(1).dateMidnight
		
	}
	
	/// The date at midnight.
	public var dateMidnight:Date {
		
		var components = self.components
		
		components.hour = 0
		components.minute = 0
		components.second = 0
		
		return Date(components: components)
	}
	
	public var dateMidday:Date {
		
		var components = self.components
		
		components.hour = 12
		components.minute = 42
		components.second = 42
		(components as NSDateComponents).timeZone = .current
		
		return Date(components: components)
	}
	
	public var dateEndOfDay:Date {
		
		var components = self.components
		
		components.hour = 23
		components.minute = 59
		components.second = 59
		(components as NSDateComponents).timeZone = .current
		
		return Date(components: components)
	}
	
	
	// MARK: - Functions
	
	public func isAfter(_ anotherDate:Date) -> Bool {
		
		return compare(anotherDate) == .orderedDescending
	}
	
	public func isBefore(_ anotherDate:Date) -> Bool {
		
		return compare(anotherDate) == .orderedAscending
	}
	
	public func isOn(day: Int, month: Month) -> Bool {
		
		return self.day == day && self.month == month
		
	}
	
	public func isOn(day: Int, month: Month, year: Int) -> Bool {
		
		return self.day == day && self.month == month && self.year == year
		
	}
	
	public func isOnSameDay(_ other: Date) -> Bool {
		
		return dateMidnight == other.dateMidnight
		
	}
	
	public func toWeekDay(_ weekday: Weekday) -> Date {
		
		let offset = weekday.rawValue - self.weekday.rawValue
		
		return dateByAddingComponent(offset, unit: .day)
	}
	
	public func dateByAddingSeconds(_ amount: Int) -> Date {
		
		return dateByAddingComponent(amount, unit: .second)
		
	}
	
	public func dateByAddingMinutes(_ amount: Int) -> Date {
		
		return dateByAddingComponent(amount, unit: .minute)
		
	}
	
	public func dateByAddingHours(_ amount: Int) -> Date {
		
		return dateByAddingComponent(amount, unit: .hour)
		
	}
	
	public func dateByAddingDays(_ amount: Int) -> Date {
		
		return dateByAddingComponent(amount, unit: .day)
		
	}
	
	public func dateByAddingWeeks(_ amount: Int) -> Date {
		
		return dateByAddingComponent(amount, unit: .weekOfYear)
		
	}
	
	public func dateByAddingYears(_ amount: Int) -> Date {
		
		return dateByAddingComponent(amount, unit: .year)
		
	}
	
	/// Finds the next date that corresponds to the given units of the given base date.
	public func dateByFindingNext(base: Date, units: [Calendar.Component]) -> Date? {
		
		var components = DateComponents()
		units.forEach{ components.setValue(base.component($0), for: $0) }
		
		return dateByFindingNext(components)
		
	}
	
	/// Finds the next date that corresponds with the given components.
	public func dateByFindingNext(_ components: DateComponents) -> Date? {
		
		return Calendar.current.nextDate(
			after: self,
			matching: components,
			matchingPolicy: .nextTimePreservingSmallerComponents,
			repeatedTimePolicy: .first,
			direction: .backward
		)
		
	}
	
	/// Finds the next date that is on the given weekday.
	public func dateByFindingNext(_ weekday: Weekday) -> Date? {
		
		var components = DateComponents()
		components.weekday = weekday.rawValue
		
		return dateByFindingNext(components)
		
	}
	
	/// Finds the previous date that corresponds to the given units of the given base date.
	public func dateByFindingPrevious(base: Date, units: [Calendar.Component]) -> Date? {
		
		var components = DateComponents()
		units.forEach{ components.setValue(base.component($0), for: $0) }
		
		return dateByFindingPrevious(components)
		
	}
	
	/// Finds the previous date that is on the given weekday.
	public func dateByFindingPrevious(_ weekday: Weekday) -> Date? {
		
		var components = DateComponents()
		components.weekday = weekday.rawValue
		
		return dateByFindingPrevious(components)
		
	}
	
	/// Finds the previous date that corresponds with the given components.
	public func dateByFindingPrevious(_ components: DateComponents) -> Date? {
		
		return Calendar.current.nextDate(
			after: self,
			matching: components,
			matchingPolicy: .previousTimePreservingSmallerComponents,
			repeatedTimePolicy: .first,
			direction: .backward
		)
		
	}
	
	public func dateBySetting(hour: Int, minute: Int, second: Int) -> Date? {
		
		return Calendar.current.date(bySettingHour: hour, minute: minute, second: second, of: self)
		
	}
	
	public func dateBySettingTime(_ time: Time) -> Date? {
		
		return dateBySetting(hour: time.hour, minute: time.minute, second: time.second)
	}
	
	public func dateBySettingTimezone(_ timezone: TimeZone) -> Date? {
		
		let components = DateComponents()
		(components as NSDateComponents).timeZone = timezone
		
		return Calendar.current.date(byAdding: components, to: self)
	}
	
	public func dateByAddingDate(_ date: Date) -> Date {
		
		return Calendar.current.date(byAdding: date.components, to: self)!
		
	}
	
	public func dateByAddingComponent(_ component: Int, unit: Calendar.Component) -> Date {
		
		return Calendar.current.date(byAdding: unit, value: component, to: self)!
		
	}
	
	/// Determines and returns the compoment of the given unit of the date.
	public func component(_ unit: Calendar.Component) -> Int {
		
		return Calendar.current.component(unit, from: self)
		
	}
	
	public func toString(_ format:String) -> String {
		
		let formatter = DateFormatter()
		formatter.dateFormat = format
		return formatter.string(from: self)
	}
    
    public func toStringTodayTomorrow(_ format:String) -> String {
        
        if isToday {
            return AppText.Generic.vandaag
        } else if isOnSameDay(Date().dateByAddingDays(1)) {
            return AppText.Generic.morgen
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
	
	public func setting(seconds: Int) -> Date?{
		let time = self.timeClass
		return self.dateBySettingTime(Time(h: time.hour, m: time.minute, s: seconds))
	}
	
	func yearsFrom(_ date: Date) -> Int {
		return (Calendar.current as NSCalendar).components(.year, from: date, to: self, options: []).year!
	}
	
	func monthsFrom(_ date: Date) -> Int {
		return (Calendar.current as NSCalendar).components(.month, from: date, to: self, options: []).month!
	}
	
	func weeksFrom(_ date: Date) -> Int {
		return (Calendar.current as NSCalendar).components(.weekOfYear, from: date, to: self, options: []).weekOfYear!
	}
	
	func daysFrom(_ date: Date) -> Int {
		return (Calendar.current as NSCalendar).components(.day, from: date.dateMidnight, to: self.dateMidnight, options: []).day!
	}
	
	func hoursFrom(_ date: Date) -> Int {
		return (Calendar.current as NSCalendar).components(.hour, from: date, to: self, options: []).hour!
	}
	
	func minutesFrom(_ date: Date) -> Int {
		return (Calendar.current as NSCalendar).components(.minute, from: date, to: self, options: []).minute!
	}
	
	func secondsFrom(_ date: Date) -> Int {
		return (Calendar.current as NSCalendar).components(.second, from: date, to: self, options: []).second!
	}
	
	
}
import Foundation

public enum Weekday: Int, ExpressibleByIntegerLiteral {
	case unknown = 0
	case sunday
	case monday
	case tuesday
	case wednesday
	case thursday
	case friday
	case saturday
	
	public init(component: Int) {
		
		self = Weekday(rawValue: component) ?? .unknown
		
	}
	
	public init(integerLiteral value: IntegerLiteralType) {
		
		self = Weekday(component: value)
		
	}
}

public enum Month : Int {
	case unknown = 0
	case january
	case february
	case march
	case april
	case may
	case june
	case july
	case august
	case september
	case october
	case november
	case december
	
	public var short : String {
		
		switch self {
			
		case .unknown:
			return "onb"
		case .january:
			return "jan"
		case .february:
			return "feb"
		case .march:
			return "mrt"
		case .april:
			return "apr"
		case .may:
			return "mei"
		case .june:
			return "jun"
		case .july:
			return "jul"
		case .august:
			return "aug"
		case .september:
			return "sep"
		case .october:
			return "okt"
		case .november:
			return "nov"
		case .december:
			return "dec"
			
		}
		
	}
	
	public init(component: Int) {
		
		self = Month(rawValue: component) ?? .unknown
		
	}
	
	public init(integerLiteral value: IntegerLiteralType) {
		
		self = Month(component: value)
		
	}
}

public struct NSDateFormats {
	public static let timeHourMinutes = "HH:mm"
	public static let iso8601 = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
}

public struct Time: Comparable, RawRepresentable {
	
	public typealias RawValue = String
	
	public var rawValue: String { return "\(hour):\(minute):\(second).\(millisecond)" }
	
	public var hour:Int
	public var minute:Int
	public var second:Int
	public var millisecond:Int
	
	public var interval:TimeInterval {
		let minutes = (hour * 60 + minute)
		return TimeInterval(minutes * 60 + second)
	}
	
	public var fullString:String {
		let h = hour <= 10 ? "0\(hour)" : String(hour)
		let m = minute <= 10 ? "0\(minute)" : String(minute)
		let s = second <= 10 ? "0\(second)" : String(second)
		
		return "\(h):\(m):\(s)"
	}
	
	public var shortString:String {
		let h = hour < 10 ? "0\(hour)" : String(hour)
		let m = minute < 10 ? "0\(minute)" : String(minute)
		
		return "\(h):\(m)"
	}
	
	public init(h:Int, m:Int, s:Int, ms:Int) {
		self.hour = h
		self.minute = m
		self.second = s
		self.millisecond = ms
	}
	
	public init(h:Int, m:Int, s:Int) {
		self.hour = h
		self.minute = m
		self.second = s
		self.millisecond = 0
	}
	
	public init(h:Int, m:Int) {
		self.hour = h
		self.minute = m
		self.second = 0
		self.millisecond = 0
	}
	
	public init(interval:TimeInterval) {
		
		self.second = Int(interval) % 60
		self.minute = Int(floor(interval / 60).truncatingRemainder(dividingBy: 60))
		self.hour = Int(floor(interval / 60 / 60))
		self.millisecond = 0
	}
	
	public init?(rawValue: String) {
		
		let components = rawValue.components(separatedBy: ".")
		if components.count != 2 {
			return nil
		}
		let parts = components.first!.components(separatedBy: ":")
		if parts.count != 3 {
			return nil
		}
		if let hour = Int(parts[0]), let minute = Int(parts[1]), let second = Int(parts[2]), let millisecond = Int(components[1]) {
			
			self.hour = hour
			self.minute = minute
			self.second = second
			self.millisecond = millisecond
			
		} else {
			
			return nil
		}
	}
	
	func range(during: Time) -> ClosedRange<Time>{
		let end = self.interval + during.interval
		return self...Time(interval: end)
	}
}

public func == (lhs:Time, rhs:Time) -> Bool {
	
	return lhs.interval == rhs.interval
}

public func <=(lhs: Time, rhs: Time) -> Bool {
	
	return lhs.interval <= rhs.interval
}

public func >=(lhs: Time, rhs: Time) -> Bool {
	
	return lhs.interval >= rhs.interval
}

public func >(lhs: Time, rhs: Time) -> Bool {
	
	return lhs.interval > rhs.interval
}

public func <(lhs: Time, rhs: Time) -> Bool {
	
	return lhs.interval < rhs.interval
}
