//
//  ArrayExtensions.swift
//  SongViewer
//
//  Created by Leo van der Zee on 07-12-17.
//  Copyright © 2017 Topicus Onderwijs BV. All rights reserved.
//

import Foundation
import CoreData

public extension Array where Element : NSPredicate {
	
	
	// MARK: - Public Functions
	
	/// Appends a predicate that matches the given name to the given string value.
	public mutating func append(_ name: String, equals: String?) {
		
		append(format: "\(name) = %@", equals)
		
	}
	
	/// Appends a predicate that matches the given name to the given integer value.
	public mutating func append(_ name: String, equals: Int?) {
		
		append(format: "\(name) = %d", equals)
		
	}
	
	/// Appends a predicate that matches the given name to the given integer value.
	public mutating func append(_ name: String, equals: Int64?) {
		
		if let value = equals {
			
			append(format: "\(name) = %d", NSNumber(value: value))
			
		}
		
	}
	
	/// Appends a predicate that matches the given name to the given object value.
	public mutating func append(_ name: String, equals: Any?) {
		
		append(format: "\(name) = %@", equals)
		
	}
	
	public mutating func append(_ name: String, containedBy: [Any]?) {
		
		if let value = containedBy {
			append(format: "\(name) IN %@", value)
		}
		
	}
	
	public mutating func append(_ name: String, containedBy: [Int64]?) {
		
		if let value = containedBy {
			
			append(format: "\(name) IN %@", value.map(NSNumber.init))
			
		}
		
	}
	
	public mutating func append(_ name: String, notContainedBy: [Any]?) {
		
		if let value = notContainedBy {
			append(format: "NOT (\(name) IN %@)", value)
		}
		
	}
	
	public mutating func append(_ name: String, notContainedBy: [Int64]?) {
		
		if let value = notContainedBy {
			
			append(format: "NOT (\(name) IN %@)", value.map(NSNumber.init))
			
		}
		
	}
	
	public mutating func append(_ name: String, notEquals: Any?) {
		
		append(format: "\(name) != %@", notEquals)
		
	}
	
	public mutating func append(_ name: String, between one: Any?, and two: Any?) {
		
		append(format: "( \(name) >= %@ ) AND ( \(name) <= %@ )", one, two)
		
	}
	
	/// Appends a predicate for the given name to test if it contains the given object value.
	public mutating func append(_ name: String, contains: Any?) {
		
		append(format: "\(name) contains[cd] %@", contains)
		
	}
	
	/// Appends a predicate for the given name to test if it is greater than the given object value.
	public mutating func append(_ name: String, greaterThan: AnyObject?) {
		
		if let value = greaterThan {
			
			append(format: "\(name) > %@", value)
			
		}
		
	}
	
	public mutating func append(_ name: String, greaterThanOrEquals: AnyObject?) {
		
		append(format: "\(name) >= %@", greaterThanOrEquals)
		
	}
	
	/// Appends a predicate for the given name to test if it is less than the given object value.
	public mutating func append(_ name: String, lessThan: AnyObject?) {
		
		append(format: "\(name) < %@", lessThan)
		
	}
	
	public mutating func append(_ name: String, lessThanOrEquals: AnyObject?) {
		
		append(format: "\(name) <= %@", lessThanOrEquals)
		
	}
	
	/// Appends a predicate for the given name to test if it is nil or not.
	public mutating func append(_ name: String, isNil: Bool?) {
		
		if let value = isNil {
			
			let o = value ? "=" : "!="
			
			append(format: "\(name) \(o) nil")
			
		}
		
	}
	
	/// Appends a predicate for the given name to test if it is not nil or not.
	public mutating func append(_ name: String, isNotNil: Bool?) {
		
		if let value = isNotNil {
			
			append(name, isNil: !value)
			
		}
		
	}
	
	/// Appends a predicate with given format and optional values.
	/// A predicate is only appended if none of the given values are `nil`.
	public mutating func append(format: String, _ values: Any?...) {
		
		let arguments = values.flatMap({$0})
		
		if ( values.count == arguments.count ) {
			
			append(NSPredicate(format: format, argumentArray: arguments))
			
		}
		
	}
	
	public mutating func append(or: [NSPredicate]) {
		
		append(NSCompoundPredicate(orPredicateWithSubpredicates: or))
		
	}
	
	public mutating func append(and: [NSPredicate]) {
		
		append(NSCompoundPredicate(andPredicateWithSubpredicates: and))
		
	}
	
	public mutating func append(not: NSPredicate) {
		
		append(NSCompoundPredicate(notPredicateWithSubpredicate: not))
		
	}
	
	public mutating func append(_ predicate: NSPredicate?) {
		
		if let predicate = predicate as? Element {
			
			append(predicate)
			
		}
		
	}
	
}

extension Array {
	
	@discardableResult
	mutating func delete<T: Entity>(entity: T) -> Bool {
		if let array = self as? Array<T> {
			if let index = array.index(where: { $0.id == entity.id }){
				self.remove(at: index)
				return true
			}
		}
		return false
	}
	
	func contains<T: Entity>(entity: T) -> Bool {
		if let array = self as? Array<T> {
			if let _ = array.index(where: { $0.id == entity.id }){
				return true
			}
			return false
		}
		return false
	}

	func firstIndex<T: Entity>(entity: T) -> Int? {
		if let array = self as? Array<T> {
			if let index = array.index(where: { $0.id == entity.id }){
				return index
			}
			return nil
		}
		return nil
	}

	
}
